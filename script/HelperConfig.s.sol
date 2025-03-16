/* 1. Deploy mocks when we are on our local anvil chain 
2. Keep track of contract address across different chains */
// eg -> Sepolia ETH/USD
//    -> Mainnet ETH/USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil , we deploy mocks
    // Otherwise , grab the existing addresses from the live network
    NetworkConfig public activeNetworkConfig;

    // declaring macros
    uint8 public DECIMALS = 8;
    int256 public INITIAL_PRICE = 2000e8;
    uint256 public SEPOLIA_CHAIN_ID = 11155111;
    uint256 public ETH_MAINNET_CHAIN_ID = 1;
    // creating a custom structure for the return value (config) of the get Config functions , which return the configurations of the networks
    struct NetworkConfig {
        address priceFeed; // ETH/USD pricefeed address
    }

    constructor() {
        // every network has their own chain id
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else if (block.chainid == ETH_MAINNET_CHAIN_ID) {
            activeNetworkConfig = getMainnetETHConfig();
        } else {
            activeNetworkConfig = createAnvilEthConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        // we need the price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return ethConfig;
    }

    function getMainnetETHConfig() public pure returns (NetworkConfig memory) {
        // we need the price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return sepoliaConfig;
    }

    function createAnvilEthConfig() public returns (NetworkConfig memory) {
        // price feed addresses

        // check if we've already set the activeNetworkConfig
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // 1. Deploy the mocks
        // 2. Return the mock addresses

        // deploying mock contracts to the anvil chain
        vm.startBroadcast();
        // first input parameter -> decimals of ETH/USD =8
        // second input parameter -> initial Value
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );

        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
