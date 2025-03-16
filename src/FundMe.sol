/* What we want this contract to do
1. Let anyone send funds to this contract
2. Set the minimum USD funding value  
3. Let the owner of the contract (deployer) withdraw the funds */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {priceConverter} from "./PriceConverter.sol";

contract FundMe {
    // enables any uint256 value in the contract to use functions from the priceConverter library as if they were native functions of uint256.
    using priceConverter for uint256;
    // setting the minimum USD amount that can be funded
    // 5e18 = 5*1e18 ==> $5
    uint256 public constant MINIMUM_USD = 5e18;
    // storage varibles generally prefix s_ is used
    // private varibles are more gas efficient than public ones
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    // creating an instance of this interface -> that fetches data from the address provided  in the constructor
    AggregatorV3Interface private s_priceFeed;
    //Immutable variables are like constants. Values of immutable variables can be set inside the constructor but cannot be modified afterwards.
    // i_ prefix generally used to declare immutable varibales
    address private immutable i_owner;
    // defining a custom error
    // Error which tells the user that only the owner of the contract can access a particular function
    error FundMe_notOwner();
    // Error that tells the user that the user has insufficient balance to make the function call
    error InsufficientBalance(uint256 required, uint256 available);

    // we need to send the priceFeed address to the constructor
    constructor(address priceFeed) {
        i_owner = msg.sender;
        // set the owner of this contract to the deployer
        // i_owner is immutable -> set inside the constructor but cannot be modified
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function getVersion() public view returns (uint256) {
        // refactoring this -> we dont wanna hard code the address here
        /*                 AggregatorV3Interface priceFeed = AggregatorV3Interface(
            // 0x694AA1769357215DE4FAC081bf1f309aDC325306
        ); */
        return s_priceFeed.version();
    }

    function fund() public payable {
        uint256 amountSentInUSD = priceConverter.getConversionRate(
            msg.value,
            s_priceFeed
        );
        require(
            amountSentInUSD >= MINIMUM_USD,
            InsufficientBalance(MINIMUM_USD, amountSentInUSD)
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function cheaperWithdraw() public onlyOwner {
        // we read from the storage once and then use this fundersLength (memory) for comparison in every iteration
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funderAddress = s_funders[funderIndex];
            s_addressToAmountFunded[funderAddress] = 0;
        }
        s_funders = new address[](0);
        (bool callSucess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSucess, "Withdrawal Failed");
    }

    function withdraw() public onlyOwner {
        // we wanna set the mapping back to zero when we withdraw our funding
        // iterating throught the s_funders array and setting the amountFunded to zero in the s_addressToAmountFunded mapping

        // here the s_funders is a storage varibale and everytime we iterate through the loop we are reading from the storage variable
        // reading & writing to storage variables => 100 GAS
        // reading & writing to memory varibles => 3 GAS
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            // even here we are reading from storage (s_funders) in every iteration
            address funderAddress = s_funders[funderIndex];
            s_addressToAmountFunded[funderAddress] = 0;
        }
        // reset the array
        s_funders = new address[](0);

        // Now we actually wanna transfer the ETH from the contract address to the contract owner (deployer's) address
        // for this we need to typecast the (msg.sender) address (i.e the owner address into a payable)
        // there are three ways to send ETH - transfer , send , call
        // most recommended -> call
        // call forwards all or set gas, and returns bool
        (bool callSucess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSucess, "Withdrawal Failed");
    }

    modifier onlyOwner() {
        // for the functions marked as onlyOwner , first the below if condition is checked and then the remaining code executes
        if (msg.sender != i_owner) {
            revert FundMe_notOwner();
        }
        // remaining code below
        _;
    }

    // to handle any fundings made not via the fund function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    // these recive and fallback function call the fund function in them
    // receive / fallback functions are called when the contract recieves any ETHER -> so if someone sends the ETH directly to the contract address without calling the fund function , fallback / recieve function will be triggered (below conditions are given) ,which in turn call the fund function  , which has checks for the minimum funding amount

    /* 
    view / pure functions (getters) */

    // we dont need to cal the getter functions inside the contract
    // hence we use the external visibilty -> slighlty more gas efficient than public
    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return (i_owner);
    }
    /*
    Which function is called, fallback() or receive()?
           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
    receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
    */
}
