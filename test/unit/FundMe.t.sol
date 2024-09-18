// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {FundMe} from "../../src/FundMe.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";
import {DeployFundMeWScript} from "../../script/FundMe.s.sol";

contract TestFundMeContract is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    address USER2 = makeAddr("user2");

    uint256 private constant VALUE_FUNDED_TO_ACCOUNT = 10 ether;
    uint256 private constant VALUE_FUNDED_TO_ACCOUNT_ONE = 6 ether;
    uint256 private constant VALUE_FUNDED_TO_ACCOUNT_TWO = 8 ether;
    uint256 private constant NEW_USER_STARTING_BALANCE = 10 ether;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMeWScript deployFundMe = new DeployFundMeWScript();
        fundMe = deployFundMe.run();
        vm.deal(USER, NEW_USER_STARTING_BALANCE);
        vm.deal(USER2, NEW_USER_STARTING_BALANCE);
    }

    //Modifer for PRANK USER ACCOUNTS
    modifier funders() {
        vm.prank(USER);
        fundMe.fund{value: VALUE_FUNDED_TO_ACCOUNT}();
        _;
    }

    function testMinimumUSD() public view {
        assertEq(fundMe.minimumUSD(), 5e18);
    }

    function testOwnerMsgSender() public view {
        assertEq(fundMe.onlyOwner(), msg.sender);
    }

    function testTotalBalance() public view {
        assertEq(fundMe.checkBalance(), 0);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithLessEthSent() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructures() public funders {
        uint256 amountFunded = fundMe.getAmountUsingAddress(USER);
        assertEq(amountFunded, VALUE_FUNDED_TO_ACCOUNT);
    }

    function testFundIsGettingUpdatedWithMultipleUsers() public {
        vm.prank(USER);
        fundMe.fund{value: VALUE_FUNDED_TO_ACCOUNT_ONE}();
        vm.prank(USER2);
        fundMe.fund{value: VALUE_FUNDED_TO_ACCOUNT_TWO}();
        //getting  the amount funded by user1 and user2
        uint256 ammountFundedByUserOne = fundMe.getAmountUsingAddress(USER);
        uint256 ammountFundedByUserTwo = fundMe.getAmountUsingAddress(USER2);
        //Total
        uint256 totalAmountFunded = fundMe.checkBalance();
        // Expected Value
        uint256 expectedFundedValueByBothTheUsers = ammountFundedByUserOne +
            ammountFundedByUserTwo;
        // Checking
        assertEq(expectedFundedValueByBothTheUsers, totalAmountFunded);
    }

    function testFundersAddedToArray() public {
        vm.prank(USER);
        fundMe.fund{value: VALUE_FUNDED_TO_ACCOUNT}();
        vm.prank(USER2);
        fundMe.fund{value: VALUE_FUNDED_TO_ACCOUNT}();
        address funder = fundMe.getFunderAddress(0);
        address funder2 = fundMe.getFunderAddress(1);
        assertEq(USER, funder);
        assertEq(USER2, funder2);
    }

    //Test Withdraw

    function testWithdrawWithSingleFunder() public funders {
        uint256 startingOwnerBalance = fundMe.onlyOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.onlyOwner()); // acts as owner
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.onlyOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function testWithdrawWithMultipleUsers() public funders {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        uint256 STARTING_FUND_AMOUNT = 10 ether;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_FUND_AMOUNT);
            fundMe.fund{value: STARTING_FUND_AMOUNT}();
        }

        uint256 startingOwnerBalance = fundMe.onlyOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.onlyOwner());
        fundMe.withdraw();

        // uint256 endingOwnerBalance = fundMe.onlyOwner().balance;
        // uint256 endingFundMeBalance = address(fundMe).balance;

        // assertEq(endingFundMeBalance, 0);
        // assertEq(
        //     endingOwnerBalance,
        //     startingOwnerBalance + startingFundMeBalance
        // );

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.onlyOwner().balance
        );
    }

    function testWithdrawWithMultipleUsersCheaper() public funders {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        uint256 STARTING_FUND_AMOUNT = 10 ether;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_FUND_AMOUNT);
            fundMe.fund{value: STARTING_FUND_AMOUNT}();
        }

        uint256 startingOwnerBalance = fundMe.onlyOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.onlyOwner());
        fundMe.withdrawCheaper();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.onlyOwner().balance
        );
    }
}
