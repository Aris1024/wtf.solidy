// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract C {
    // 注意B和C的数据存储布局必须相同！变量类型、声明的前后顺序要相同。
    uint public num;
    address public sender;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
    }
}

contract B {
    // 注意B和C的数据存储布局必须相同！变量类型、声明的前后顺序要相同。
    uint public num;
    address public sender;

    function callSetVars(address _addr, uint _num) external payable {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }

    function delegateCallVars(address _addr, uint _num) external payable {
        (bool success, bytes memory data) = _addr.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}
