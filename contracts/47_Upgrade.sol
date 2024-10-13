// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract SimpleUpgrade {
    address public implementation;
    address public admin;
    string public words;

    constructor(address _implementation) {
        admin = msg.sender;
        implementation = _implementation;
    }

    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(
            msg.data
        );
    }

    receive() external payable {}

    function upgrade(address _newImplementation) external {
        require(msg.sender == admin);
        implementation = _newImplementation;
    }
}

contract Logic1 {
    // 状态变量和proxy合约一致，防止插槽冲突
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "old";
    }
}

contract Logic2 {
    // 改变proxy中状态变量，选择器：0xc2985578
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "new";
    }
}
