// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FundMe} from "../src/FundMe.sol";
import {Script, console} from "../lib/forge-std/src/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentDeployedAddress) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedAddress)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Account Funded");
    }

    function run() external {
        address mostRecentDeployedAddress = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentDeployedAddress);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployedAddress) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedAddress)).withdrawCheaper();
        vm.stopBroadcast();
        console.log("Funds Withdrawn");
    }

    function run() external {
        address mostRecentDeployedAddress = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentDeployedAddress);
        vm.stopBroadcast();
    }
}
