// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 0x694AA1769357215DE4FAC081bf1f309aDC325306 -> Price Feed Address of Sepolia ETH/USD
library priceConverter {
    // refactored getPrice and getConversionRate functions to take the AggregatorV3Interface as the input instead of hardcoding the addresses
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // priceFeed is an instance of the interface
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUSD;
    }
}
