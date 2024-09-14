// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19; 

import { FundMe } from "../src/FundMe.sol";
import {Test , console} from "../lib/forge-std/src/Test.sol";


contract TestFundMeContract is Test {
    FundMe fundMe;
    PriceConverter priceConverter;

    function setUp() external {
        fundMe = new FundMe();
       
    }

    function testMinimumUSD() public {
        assertEq(fundMe.minimumUSD(), 5e18);
    }

    function testOwnerMsgSender() public {
        assertEq(fundMe.i_owner(), address(this));
    }

    function testconvertPrice() public {
        
    }
}
