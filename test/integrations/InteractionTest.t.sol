// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {FundMe} from "../../src/FundMe.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";
import {DeployFundMeWScript} from "../../script/FundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 private constant VALUE_FUNDED_TO_ACCOUNT = 10 ether;
    uint256 private constant NEW_USER_STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMeWScript deploy = new DeployFundMeWScript();
        fundMe = deploy.run();
        vm.deal(USER, NEW_USER_STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        vm.prank(USER);
        vm.deal(USER, 1e18);
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
