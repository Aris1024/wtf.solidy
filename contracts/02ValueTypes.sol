// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract ValueTypes {
    // 布尔值
    bool public _bool = true;

    bool public _bool1 = !_bool; // 取非
    bool public _bool2 = _bool && _bool1; // 与
    bool public _bool3 = _bool || _bool1; // 或
    bool public _bool4 = _bool == _bool1; // 相等
    bool public _bool5 = _bool != _bool1; // 不相等

    // 整数
    int public _int = -1;
    uint public _uint = 1;
    uint256 public _number = 123123;
    // 整数运算
    uint256 public _number1 = _number + 1; // 加减乘除
    uint256 public _number2 = 2 ** 2; // 指数
    uint256 public _number3 = 7 % 2; // 取余数
    bool public _numberbool = _number2 > _number3; // 比大小

    // 地址
    address public _address = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    address payable public _address1 = payable(_address); // payable address
    // 地址成员类型
    uint256 public blance = _address1.balance; // blance of address

    // 定长字节数组
    bytes32 public _bytes32 = "MiniSolidity"; // 变量以字节的方式存进变量 _bytes32  0x4d696e69536f6c69646974790000000000000000000000000000000000000000
    bytes1 public _bytes1 = _bytes32[0]; // 0x4d

    // 枚举
    // 从 0 开始, uint 0,1,2
    enum ActionSet {
        Buy,
        Hold,
        Sell
    }
    ActionSet action = ActionSet.Sell;
    // 枚举与 uint 显式转换
    function enumToUint() external view returns (uint) {
        return uint(action);
    }
}
