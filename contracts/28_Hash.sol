// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Hash {
    bytes32 _msg = keccak256(abi.encodePacked("Aris"));

    function hash(
        uint _num,
        string memory _string,
        address _addr
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_num, _string, _addr));
    }

    function weak(string memory _str) public view returns (bool) {
        return keccak256(abi.encodePacked(_str)) == _msg;
    }

    function strong(
        string memory _str1,
        string memory _str2
    ) public pure returns (bool) {
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }
}
