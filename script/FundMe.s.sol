// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19; 

import { FundMe } from "../src/FundMe.sol";
import {Script} from "../lib/forge-std/src/Script.sol";


contract DeployFundMeWScript is Script {
    function run() external payable returns(FundMe){
        vm.startBroadcast();
        FundMe fundMe = new FundMe();
        vm.stopBroadcast();
        return fundMe;
    }
}

