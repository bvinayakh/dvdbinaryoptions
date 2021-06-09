// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.8.0;

import "./Pausable.sol";
import "./Oracle.sol";
import "./interfaces/IBinaryOptions.sol";

contract BinaryOptions is Owner, Pausable, Oracle {
    uint256 totalCount;
    uint256 positiveCount;
    uint256 negativeCount;
    //1 ticket is always 1 xUSD
    uint256 minTicket = 1;
    uint256 criteria;

    //will be init during contract creation/deployment
    //will determine when this contract will expire
    uint256 contractExpiryTime;
    uint256 bidPeriodTime;

    string public constant tokenName = "DVD Binary Options";
    string public constant tokenSymbol = "xUSD";

    constructor(
        uint256 _contractExpiryTime,
        uint256 _criteria,
        uint256 _bidPeriod
    ) public {
        contractExpiryTime = _contractExpiryTime;
        criteria = _criteria;
        bidPeriodTime = _bidPeriod;
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

    function votePositive(address participant) public payable isContractPaused {
        //if current time is lesser than the bidding time limit then allow voting
        require(now < bidPeriodTime, "Bidding Period has ended");
        require(msg.value >= 1000, "Need 1000 wei to bid");
        totalCount++;
        // lets assume every vote is 1000 wei
        positive[participant] = 1000;
        voted[participant] = true;
        positiveCount++;
    }

    function voteNegative(address participant) public payable isContractPaused {
        //if current time is lesser than the bidding time limit then allow voting
        require(now < bidPeriodTime, "Bidding Period has ended");
        require(msg.value >= 1000, "Need 1000 wei to bid");
        totalCount++;
        // assume every vote is 1000 wei
        negative[participant] = 1000;
        voted[participant] = true;
        negativeCount++;
    }

    function announceResult() public ownerOnly isContractPaused {
        //invoke oracle and get ETH price
        //eth price - lets assume options bid is for eth > 4000
        //if current time is more than the end time specified during contract creation then allow announce result
        emit announce(
            "Announcing Result at ",
            now,
            " option expiry time marked as ",
            contractExpiryTime
        );
        require(now >= contractExpiryTime, "Option Not Expired");
        emit logUint(currentPrice);
        if (currentPrice > criteria) {
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

    function getCriteria() external view returns (uint256) {
        return criteria;
    }

    function getBidPeriodLimit() external view returns (uint256) {
        return bidPeriodTime;
    }

    receive() external payable {}
}
