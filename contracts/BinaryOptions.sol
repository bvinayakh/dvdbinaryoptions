// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./Oracle.sol";

contract BinaryOptions is Ownable, Pausable, Oracle {
    uint256 totalCount;
    uint256 positiveCount;
    uint256 negativeCount;
    //1 ticket is always 1 xUSD
    uint256 minTicket = 1;
    uint256 strikePrice;

    //will be init during contract creation/deployment
    //will determine when this contract will expire
    uint256 contractExpiryTime;
    uint256 bidPeriodTime;

    address aggregator;

    string public constant tokenName = "DVD Binary Options";
    string public constant tokenSymbol = "xUSD";

    //options expiry timestamp in unix format, options strike price in uint256, bid price,
    //chainlink aggregator address
    constructor(
        uint256 _contractExpiryTime,
        uint256 _strikePrice,
        uint256 _bidPeriod,
        address _aggregator
    ) public {
        contractExpiryTime = _contractExpiryTime;
        strikePrice = _strikePrice;
        bidPeriodTime = _bidPeriod;
        aggregator = _aggregator;
    }

    event logString(string message);
    event announce(
        string message1,
        uint256 currentTime,
        string message2,
        uint256 expiryTime
    );
    event logUint(uint256 value);

    struct Participant {
        mapping(uint256 => address) positive;
        uint256 amount;
        uint256 timestamps;
    }

    mapping(address => uint256) positive;
    mapping(address => uint256) negative;
    mapping(address => bool) voted;

    function votePositive(address participant) public payable whenNotPaused {
        //if current time is lesser than the bidding time limit then allow voting
        require(block.timestamp < bidPeriodTime, "Bidding Period has ended");
        require(msg.value >= 1000, "Need 1000 wei to bid");
        totalCount++;
        // lets assume every vote is 1000 wei
        positive[participant] = 1000;
        voted[participant] = true;
        positiveCount++;
    }

    function voteNegative(address participant) public payable whenNotPaused {
        //if current time is lesser than the bidding time limit then allow voting
        require(block.timestamp < bidPeriodTime, "Bidding Period has ended");
        require(msg.value >= 1000, "Need 1000 wei to bid");
        totalCount++;
        // assume every vote is 1000 wei
        negative[participant] = 1000;
        voted[participant] = true;
        negativeCount++;
    }

    function announceResult() public onlyOwner whenNotPaused {
        //invoke oracle and get ETH price
        //eth price - lets assume options bid is for eth > 4000
        //if current time is more than the end time specified during contract creation then allow announce result
        emit announce(
            "Announcing Result at ",
            block.timestamp,
            " option expiry time marked as ",
            contractExpiryTime
        );
        uint256 currentPrice = uint256(getPrice(aggregator));
        require(block.timestamp >= contractExpiryTime, "Option Not Expired");
        emit logUint(currentPrice);
        if (currentPrice > strikePrice) {
            //positive won
            // amountperwinner = address(this).balance/positiveCount;
            emit logString("Positive Options Bid Win");
            // enable withdrawals based on number of tickets
        } else {
            //negative won
            // amountperwinner = address(this).balance/negativeCount;
            emit logString("Negative Options Bid Win");
            // enable withdrawals based on number of tickets
        }

        //clearing unnecessary space on smart contract
        positiveCount = 0;
        negativeCount = 0;
        totalCount = 0;

        //clear mappings
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getPositive() external view returns (uint256) {
        return positiveCount;
    }

    function getNegative() external view returns (uint256) {
        return negativeCount;
    }

    function getTotal() external view returns (uint256) {
        return totalCount;
    }

    function getContractExpiry() external view returns (uint256) {
        return contractExpiryTime;
    }

    function getStrikePrice() external view returns (uint256) {
        return strikePrice;
    }

    function getBidPeriodLimit() external view returns (uint256) {
        return bidPeriodTime;
    }
}
