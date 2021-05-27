// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.8.0;

import "./Pausable.sol";
import "./Oracle.sol";

contract BinaryOptions is Owner, Pausable, Oracle {
    uint256 totalCount;
    uint256 positiveCount;
    uint256 negativeCount;
    //1 ticket is always 1 xUSD
    uint256 minTicket = 1;

    uint256 public criteria;

    string public constant tokenName = "DVD Binary Options";
    string public constant tokenSymbol = "xUSD";

    constructor() public {}

    event logString(string message);
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
        // require(!voted[participant], "You have voted already");
        require(msg.value >= 1000, "Need 1000 wei to bid");
        totalCount++;
        // lets assume every vote is 1000 wei
        positive[participant] = 1000;
        voted[participant] = true;
        positiveCount++;
    }

    function voteNegative(address participant) public payable isContractPaused {
        // require(!voted[participant], "You have voted already");
        require(msg.value >= 1000, "Need 1000 wei to bid");
        totalCount++;
        // assume every vote is 1000 wei
        negative[participant] = 1000;
        voted[participant] = true;
        negativeCount++;
    }

    // function announceResult(uint256 result) public ownerOnly view returns(uint256)
    // function will be triggered automatically by time oracle
    function announceResult() public ownerOnly isContractPaused {
        //connect to time oracle and trigger requestEthereumPrice on set time
        //invoke oracle and get ETH price
        //eth price - lets assume options bid is for eth > 4000
        // if(result == 1)
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

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPositive() public view returns (uint256) {
        return positiveCount;
    }

    function getNegative() public view returns (uint256) {
        return negativeCount;
    }

    function getTotal() public view returns (uint256) {
        return totalCount;
    }

    receive() external payable {}

    function setCriteria(uint256 _criteria) public ownerOnly isContractPaused {
        criteria = _criteria;
    }
}
