// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {FundMe} from "../src/FundMe.sol";
import {Test} from "forge-std/Test.sol";
import {DeployFundMeWScript} from "../script/FundMe.s.sol";

contract TestFundMeContract is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 private constant VALUE_FUNDED_TO_ACCOUNT = 10 ether;
    uint256 private constant NEW_USER_STARTING_BALANCE = 10 ether;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMeWScript deployFundMe = new DeployFundMeWScript();
        fundMe = deployFundMe.run();
        vm.deal(USER, NEW_USER_STARTING_BALANCE);
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

    function testFundFailsWithLessEthSent() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER); // create as new user and fund
        fundMe.fund{value: VALUE_FUNDED_TO_ACCOUNT}();
        uint256 amountFunded = fundMe.getAmountUsingAddress(USER);
        assertEq(amountFunded, VALUE_FUNDED_TO_ACCOUNT);
    }
}
