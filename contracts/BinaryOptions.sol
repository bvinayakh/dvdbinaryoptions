// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.0;

import "./Owner.sol";
import "./Provable.sol";
import "./Pausable.sol";

contract BinaryOptions is Owner, Provable {
    uint256 totalCount;
    uint256 positiveCount;
    uint256 negativeCount;
    //1 ticket is always 1 xUSD
    uint256 minTicket = 1;

    string public constant tokenName = "DVD Binary Options";
    string public constant tokenSymbol = "xUSD";

    constructor() public {
        provable_setProof(proofType_Android | proofStorage_IPFS);
    }

    struct Participant {
        mapping(uint256 => address) positive;
        uint256 amount;
        uint256 timestamps;
    }

    mapping(address => uint256) positive;
    mapping(address => uint256) negative;
    mapping(address => bool) voted;

    function votePositive(address participant) public payable isContractPaused {
        require(!voted[participant], "You have voted already");
        {
            require(msg.value >= 1000, "Need 1000 wei to participate");
            {
                totalCount++;
                // lets assume every vote is 1000 wei
                positive[participant] = 1000;
                // mapping(uint => address) storage positive;
                // positive[positiveCount] = participant;
                // Participant();

                voted[participant] = true;
                positiveCount++;
            }
        }
    }

    function voteNegative(address participant) public payable {
        require(!voted[participant], "You have voted already");
        {
            require(msg.value >= 1000, "Need 1000 wei to participate");
            {
                totalCount++;
                // assume every vote is 1000 wei
                negative[participant] = 1000;
                voted[participant] = true;
                negativeCount++;
            }
        }
    }

    // view has to be removed when we delete values
    function announceResult(uint256 result)
        public
        view
        ownerOnly
        returns (uint256)
    {
        uint256 amountperwinner;
        if (result == 1) {
            //positive won
            amountperwinner = address(this).balance / positiveCount;
            for (uint256 counter = 0; counter < positiveCount; counter++) {}
            // delete positiveCount;
            // delete totalCount
            // delete positive
        } else if (result == 0) {
            //negative won
            amountperwinner = address(this).balance / negativeCount;
            for (uint256 counter = 0; counter < negativeCount; counter++) {}
            // delete negativeCount
            // delete totalCount
            // delete negative
        }
        return amountperwinner;
    }

    function getContractBalance() public view ownerOnly returns (uint256) {
        // require(msg.sender == owner, "Unauthorized Smart Contract Owner");
        return address(this).balance;
    }

    function getPositive() public view ownerOnly returns (uint256) {
        return positiveCount;
    }

    function getNegative() public view ownerOnly returns (uint256) {
        return negativeCount;
    }

    function getTotal() public view returns (uint256) {
        return totalCount;
    }

    function() external payable {}
}
