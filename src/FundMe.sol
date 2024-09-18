// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant minimumUSD = 5e18;
    address private immutable i_owner;
    address[] private s_allFundersAddress;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    modifier ownerOnly() {
        require(msg.sender == i_owner, FundMe__NotOwner());
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    constructor(address _priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function fund() public payable {
        require(
            msg.value.convertPrice(s_priceFeed) >= minimumUSD,
            "Insufficient funds transferred"
        );
        s_allFundersAddress.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdrawCheaper() public ownerOnly {
        uint256 fundersLength = s_allFundersAddress.length;
        for (uint256 i = 0; i < fundersLength; i++) {
            address funder = s_allFundersAddress[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_allFundersAddress = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Withdraw Failed Using Call Method");
    }

    function withdraw() public ownerOnly {
        for (uint256 i = 0; i < s_allFundersAddress.length; i++) {
            address funder = s_allFundersAddress[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_allFundersAddress = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Withdraw Failed Using Call Method");
    }

    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / pure Functions for testing getter Functions
     */

    function getAmountUsingAddress(
        address _address
    ) external view returns (uint256) {
        return s_addressToAmountFunded[_address];
    }

    function getFunderAddress(uint256 index) external view returns (address) {
        return s_allFundersAddress[index];
    }

    function onlyOwner() external view returns (address) {
        return i_owner;
    }
}
