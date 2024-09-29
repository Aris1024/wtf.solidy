// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
contract Constant {
    // constant 必须在声明的时候初始化,之后不能改变
    uint256 public constant CONST_NUM = 10;
    string public constant CONST_STRING = "Aris";
    bytes public constant CONST_BYTES = "WTF";
    address public constant CONST_ADDRESS = 0x0000000000000000000000000000000000000000;

    // immutable变量可以在 constructor 中初始化,之后不能变
    uint256 public immutable IMM_NUM = 9999;
    address public immutable IMM_ADDRESS;
    uint256 public immutable IMM_BLOCK;
    uint256 public immutable IMM_TEST;
    constructor () {
        IMM_ADDRESS = address(this);
        IMM_NUM = 12123;
        IMM_TEST = test();
    }
    function test() public pure returns(uint256) {
        uint256 what = 9;
        return (what);
    }
}