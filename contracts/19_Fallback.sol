// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/* 触发fallback() 还是 receive()?
            接收ETH
                |
            msg.data是空？
                /  \
            是    否
            /      \
    receive()存在?   fallback()
            / \
        是  否
        /     \
    receive()  fallback   
*/
contract Fallback {
    event receivedCalled(address sender, uint value);
    event fallbackCalled(address sender, uint value, bytes data);

    receive() external payable {
        emit receivedCalled(msg.sender, msg.value);
    }

    fallback() external payable {
        emit fallbackCalled(msg.sender, msg.value, msg.data);
    }
}
