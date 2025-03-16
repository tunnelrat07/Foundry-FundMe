// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    // function run returns a fundMe contract -> we use this contract in the setUp function in the test , so that we dont have to manually make deployement changes in both the test and script

    // We are still hardcoding an address, and we still have to make APi call to sepolia (our test only work with sepolia)
    // We can create a mock contract ->
    // on our local anvil , we can create our own fake price feed and interact with that for the purpose of local testing
    function run() external returns (FundMe) {
        // Before vm.startBroadcast(); -> Not a 'real' tx
        HelperConfig helperConfig = new HelperConfig();
        address ethUSDPriceFeed = helperConfig.activeNetworkConfig();
        // After vm.startBroadcast(); -> 'real' tx
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUSDPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
