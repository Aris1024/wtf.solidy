// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract InitialValue {
    // value types
    bool public _bool; // false
    string public _string; // ""
    int public _int; // 0
    address public _address; // 0x0000000000000000000000000000000000000000

    enum ActionSet {
        Buy,
        Hold,
        Sell
    }
    ActionSet public _enum; // 0 (第一个元素)

    function fi() internal {}

    function fe() external {}

    // reference types
    uint[8] public _staticArray; // 所有成员设为其默认值的静态数组 [0,0,0,0,0,0,0,0]
    uint[] public _dynamicArray; // []
    mapping(uint => address) public _mapping; // value值的数据类型的默认值
    struct Student {
        uint256 id;
        uint256 score;
    }

    // delete
    bool public _bool2 = true;

    function d() external {
        delete _bool2; // delete操作符会让参数值变为其默认类型,即 fasle
    }
}
