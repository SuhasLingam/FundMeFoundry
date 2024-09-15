// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public acticeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            acticeNetworkConfig = getSepoliaPriceFeed();
        } else if (block.chainid == 1) {
            acticeNetworkConfig = getEthMainnetPriceFeed();
        } else {
            acticeNetworkConfig = getOrCreateAnvilPriceFeed();
        }
    }

    function getSepoliaPriceFeed() public pure returns (NetworkConfig memory) {
        // Sepolia price feed
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getOrCreateAnvilPriceFeed() public returns (NetworkConfig memory) {
        if (acticeNetworkConfig.priceFeed != address(0)) {
            return acticeNetworkConfig;
        }

        // Anvil price feed
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }

    function getEthMainnetPriceFeed()
        public
        pure
        returns (NetworkConfig memory)
    {
        // Eth mainnet price feed
        return
            NetworkConfig({
                priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
    }
}
