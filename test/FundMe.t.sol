// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {FundMe} from "../src/FundMe.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol";
import {DeployFundMeWScript} from "../script/FundMe.s.sol";

contract TestFundMeContract is Test {
    FundMe fundMe;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMeWScript deployFundMe = new DeployFundMeWScript();
        fundMe = deployFundMe.run();
    }

    function testMinimumUSD() public view {
        assertEq(fundMe.minimumUSD(), 5e18);
    }

    function testOwnerMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
