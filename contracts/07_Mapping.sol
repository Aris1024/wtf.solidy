// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
contract Mapping {
    mapping (uint => address) public idToAddress;
    mapping (address => address) public swapPair;
    function writeMap(uint _key, address _value) public {
        idToAddress[_key] = _value;
    }
}