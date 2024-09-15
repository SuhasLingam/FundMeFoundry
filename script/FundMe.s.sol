// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMeWScript is Script {
    function run() external returns (FundMe) {
        HelperConfig setNetworkConfig = new HelperConfig();
        address getEthUsdPriceFeedAddress = setNetworkConfig
            .acticeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(getEthUsdPriceFeedAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}
