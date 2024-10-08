// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract OtherContract {
    uint256 private _x = 0;
    event Log(uint amount, uint gas);

    fallback() external payable {}

    receive() external payable {}

    function getBalanace() public view returns (uint) {
        return address(this).balance;
    }

    function setX(uint256 x) external payable {
        _x = x;
        if (msg.value > 0) {
            emit Log(msg.value, gasleft());
        }
    }

    function getX() external view returns (uint x) {
        x = _x;
    }
}

contract Call {
    // 定义Response事件，输出call返回的结果success和data
    event Response(bool success, bytes data);

    // call setX()，同时可以发送ETH
    function callSetX(address payable _addr, uint256 x) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value}(
            abi.encodeWithSignature("setX(uint256)", x)
        );
        emit Response(success, data);
    }

    // call getX()
    function callGetX(address _addr) external returns (uint256) {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("getX()")
        );
        emit Response(success, data);
        return abi.decode(data, (uint256));
    }

    // call 不存在的函数
    function callNotExist(address _addr) external {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("foo(uint256)")
        );
        emit Response(success, data);
    }
}
