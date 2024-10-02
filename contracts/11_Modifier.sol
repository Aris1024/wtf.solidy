// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
contract Owner {
    address public owner;
    constructor (address initailOwner) {
        owner = initailOwner;
    }
    modifier onlyOwner {
        require(msg.sender == owner, "Invalid msg.sender"); // 校验不通过报错
        _; // 继续运行
    }
    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}