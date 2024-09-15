// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant minimumUSD = 5e18;
    address public immutable i_owner;
    address[] public allFundersAddress;
    mapping(address => uint256) public amountFunded;
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
        allFundersAddress.push(msg.sender);
        amountFunded[msg.sender] += msg.value;
    }

    function withdraw() public ownerOnly {
        for (uint256 i = 0; i < allFundersAddress.length; i++) {
            address funder = allFundersAddress[i];
            amountFunded[funder] = 0;
        }
        allFundersAddress = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Withdraw Failed Using Call Method");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
