// SPDX-Licence_Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol"; // https://github.com/smartcontractkit/chainlink#readme
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public owner;

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10**18; // $50
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        /*AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );*/
        // redundant due to constructor parameter & priceFeed initialisation
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        /*AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );*/
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        //return uint256(answer);  // 195817234690 = $1,958.17234690 * 10**8
        return uint256(answer * 10**10); // return answer to 18 decimal places (1eth = 10**18 wei)
    }

    // 1 gwei = 1,000,000,000=1000000000 wei
    // 1 eth  = 1,000,000,000=1000000000 gwei
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        // ethAmount is in gwei
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1000000000000000000; //(10**18);
        return ethAmountInUSD; // 1949775974400
        // actual number 1949775974400 / (10**18) = 0.000001949775974400
        // so 1 gwei = $0.000001949775974400 => 1 eth = $1949.775974400
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Someone else tried to withdraw!");
        _;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance); // return all funds
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0; // set value in mapping to 0
        }
        funders = new address[](0); // re-initialise funders array
    }

    function getEntranceFee() public view returns (uint256) {
        //minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }
}
