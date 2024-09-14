// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


library PriceConverter {

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeeds = AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
        (, int256 answer, , , ) = priceFeeds.latestRoundData();
        return uint256(answer * 1e10); // Assuming the price feed has 8 decimals
    }

    function convertPrice(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // Convert ETH to USD
        return ethAmountInUsd;
    }

}