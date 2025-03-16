// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // creating an instance of the FundMe contract called fundMe
    FundMe fundMe;

    // gives us an address
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 0.0001 ether;

    // price of the GAS

    // Setting up an instance of the FundMe contract to run our tests
    function setUp() external {
        /*         fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); */
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    // testing if the Minimum funding amount in USD is indeed $5
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // testing if the contract owner (FundMe) is the deployer
    function testOwnerIsMsgSender() public view {
        // in our setUp function FundMeTest is the contract that deployed our FundMe contract -> Contract FundMe test is the owner of the fundMe,
        // we are calling the FundMeTest -> msg.sender == we
        // hence we should check if the owner is the deployer of the fundMe (in this case - our FundMeTest contract)
        /*         console.log(msg.sender);
        console.log(fundMe.i_owner()); */
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // testing if the priceFeed version is accureate
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    // testing if the fund function reverts if minimumUSD funding requirement isnt met
    function testFundFailsWithoutEnoughETH() public {
        // vm.expectRevert() expects the next line to revert
        vm.expectRevert();
        // this test will fail if this is the next line coz the vm.expectRevert() ,expects it to revert but the below line doesnt revert
        /* uint256 cat = 1; */
        fundMe.fund(); // send 0 value
    }

    function testFundUpdatesDataStructures() public {
        vm.prank(USER); // The next tx will be sent by USER (address)
        // we created the user above but the above user doesnt have any funds

        // hence we can use another cheatcode to send the user some money

        // we wanna check if a successfull fund updates the data structures
        // the mapping addressToAmountFunded and possible the funders[]

        fundMe.fund{value: SEND_VALUE}(); // sending 10ETH (>$5)

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        // address(this) -> this contract FundMeTest is the contract that calls the fundMe.fund() function
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public funded {
        // we wanna check if the funder is added to the funders array
        // we only have one funder and that should be USER
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        // we expect a revert when the USER tries to withdraw, coz the user is not the owner
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        // Act
        // Assert
        // -> methodology for working with tests

        // Arrange
        address contractOwner = fundMe.getOwner();
        uint256 startingOwnerBalance = contractOwner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // we wanna set the sender of the next tx (withdraw) to be the owner of the contract
        vm.prank(contractOwner);

        fundMe.withdraw();

        // Assert
        uint256 endingOwnerbalance = contractOwner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // we want the endingOwnerBalance == startingOwnerBalance + startingFundMeBalance
        // and we want the endingFundMeBalance == 0
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerbalance
        );
    }

    function testWithdrawFromMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        // Arrange
        // we start from address(1) -> because the address(0) reverts (sanity checks)
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // we create addresses (funders) , give them balance and fund the contract using them
            // vm.prank();
            // vm.deal(account, newBalance);
            // forge-std hoax gives us addresses that have some ether, so we can directly use that

            hoax(address(i), STARTING_BALANCE);
            // fund the contract

            fundMe.fund{value: SEND_VALUE}();
        }

        address contractOwner = fundMe.getOwner();
        uint256 startingOwnerBalance = contractOwner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // we wanna set the sender of the next tx (withdraw) to be the owner of the contract
        vm.prank(contractOwner);

        fundMe.withdraw();

        // Assert
        uint256 endingOwnerbalance = contractOwner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // we want the endingOwnerBalance == startingOwnerBalance + startingFundMeBalance
        // and we want the endingFundMeBalance == 0
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerbalance
        );

        // we can also use ->

        // vm.startPrank(msgSender);
        /*       Anything here in between (all the transactions) are sent by the msgSender */
        // vm.stopPrank();
    }

    function testWithdrawFromMultipleFundersCheaper() public {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        // Arrange
        // we start from address(1) -> because the address(0) reverts (sanity checks)
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // we create addresses (funders) , give them balance and fund the contract using them
            // vm.prank();
            // vm.deal(account, newBalance);
            // forge-std hoax gives us addresses that have some ether, so we can directly use that

            hoax(address(i), STARTING_BALANCE);
            // fund the contract

            fundMe.fund{value: SEND_VALUE}();
        }

        address contractOwner = fundMe.getOwner();
        uint256 startingOwnerBalance = contractOwner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // we wanna set the sender of the next tx (withdraw) to be the owner of the contract
        vm.prank(contractOwner);

        fundMe.cheaperWithdraw();

        // Assert
        uint256 endingOwnerbalance = contractOwner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // we want the endingOwnerBalance == startingOwnerBalance + startingFundMeBalance
        // and we want the endingFundMeBalance == 0
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerbalance
        );

        // we can also use ->

        // vm.startPrank(msgSender);
        /*       Anything here in between (all the transactions) are sent by the msgSender */
        // vm.stopPrank();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    /* 
     
     
     SOME ENDING NOTES 
     
     
     
     */

    /* 
    
    When working with anvil the gas price defaults to zero 
    To simulate transactions to use actual Gas price
    we need to tell our test to pretend to use actual gas
    We can use another cheatcode -> txGasPrice

     */

    // Modular deployment
    // Modular testing
    // -> without hard coding any address values

    /* What we can do to work with addresses outside our system ? 
    1. Unit :
    - Testing a specific part of our code 
    2. Integration
    - Testing how our code works with other parts of our code 
    3. Forked
    - Testing our code in a simulated real environment 
    4. Staging 
    - Testing our code in real environment that is not production  */
}
