// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.0;

contract Owner {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier ownerOnly {
        require(msg.sender == owner, "Unauthorized Access");
        _;
    }
}
