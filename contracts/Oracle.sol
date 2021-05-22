// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "./Owner.sol";

contract Oracle is ChainlinkClient, Owner {
    uint256 public currentPrice;

    // 17 0s = 0.1 LINK
    // 18 0s = 1 LINK
    uint256 private constant ORACLE_PAYMENT = 100000000000000000;

    constructor() public {
        setPublicChainlinkToken();
        owner = msg.sender;
    }

    function getAPIResult() public returns (bytes32 requestId) {
        address oracleAddress = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
        string memory jobId = "29fa9aa13bf1468788b7cc4a500a45b8";
        Chainlink.Request memory req =
            buildChainlinkRequest(
                stringToBytes32(jobId),
                address(this),
                this.fulfill.selector
            );
        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD"
        );
        req.add("path", "USD");
        // Adds an integer with the key "times" to the request parameters
        // req.addInt("times", 100);
        return sendChainlinkRequestTo(oracleAddress, req, ORACLE_PAYMENT);
    }

    //will be invoked automatically
    function fulfill(bytes32 _requestId, uint256 _price)
        public
        recordChainlinkFulfillment(_requestId)
    {
        currentPrice = _price;
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public ownerOnly {
        cancelChainlinkRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
    }

    // withdrawLink allows the owner to withdraw any extra LINK on the contract
    function withdrawLink() public ownerOnly {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    // A helper funciton to make the string a bytes32
    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
