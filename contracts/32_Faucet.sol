// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./lib/IERC20.sol";

contract Faucet {
    uint256 public amountAllowed = 100;
    address public tokenAddress;
    mapping(address => bool) public requestedAddress;
    event SendToken(address indexed receiver, uint256 indexed amount);

    constructor(address _token) {
        tokenAddress = _token;
    }

    function requestTokens() external {
        require(
            !requestedAddress[msg.sender],
            "Each address can only be collected once."
        );
        IERC20 token = IERC20(tokenAddress); // 创建合约对象
        bool valid = token.balanceOf(address(this)) >= amountAllowed;
        require(valid, "Faucet is Empty.");
        token.transfer(msg.sender, amountAllowed); // 领水
        requestedAddress[msg.sender] = true; // 记录
        emit SendToken(msg.sender, amountAllowed); // 释放事件
    }
}
