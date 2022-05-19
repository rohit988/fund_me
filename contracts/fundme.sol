// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract Fund {
    using SafeMathChainlink for uint256;
    mapping(address => uint256) public addresstomoney;
    address owner;
    AggregatorV3Interface pricefeed;
    address[] public funders;

    constructor(address _pricefeed) public {
        owner = msg.sender;
        pricefeed = AggregatorV3Interface(_pricefeed);
    }

    function fundmes() public payable {
        require(msg.value >= 0.0001 ether, "You need to spend more eth");
        addresstomoney[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function version_check() public view returns (uint256) {
        //AggregatorV3Interface pricefeed = AggregatorV3Interface(
        //    0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        // instead of doing the above, we will add this address in constructor and also assign a global variable to use in different function
        // we are doing this because loacl ganche chain will not work on the above address, as it is rinkeby address
        return pricefeed.version();
    }

    function price() public view returns (uint256) {
        // AggregatorV3Interface pricefeed = AggregatorV3Interface(
        //    0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (, int256 answer, , , ) = pricefeed.latestRoundData();
        return uint256(answer);
    }

    modifier youknow() {
        require(msg.sender == owner);
        _;
    }

    function transfer() public payable youknow {
        msg.sender.transfer(address(this).balance);
        for (
            uint256 funderindex = 0;
            funderindex < funders.length;
            funderindex++
        ) {
            address funder = funders[funderindex];
            addresstomoney[funder] = 0;
            funders = new address[](0);
        }
    }
}
