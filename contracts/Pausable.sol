// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.6.0;

import "./Owner.sol";

contract Pausable is Owner {
    uint256 public latestPausedTime;
    bool public isPaused;

    event logging(bool status);

    function setPaused(bool _paused) external ownerOnly {
        //if contract pause state is the same don't make any changes
        if (_paused == isPaused) {
            return;
        }

        isPaused = _paused;

        if (isPaused) {
            latestPausedTime = now;
        }

        emit logging(isPaused);
    }

    modifier isContractPaused {
        require(
            !isPaused,
            "Operation cannot be performed while the contract is paused"
        );
        _;
    }
}
