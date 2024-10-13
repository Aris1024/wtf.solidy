// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// 选择器冲突的例子
// 去掉注释后，合约不会通过编译，因为两个函数有着相同的选择器
contract Foo {
    bytes4 public selector1 = bytes4(keccak256("burn(uint256)"));
    bytes4 public selector2 =
        bytes4(keccak256("collate_propagate_storage(bytes16)"));
    // function burn(uint256) external {}
    // function collate_propagate_storage(bytes16) external {}
}

contract TransparentProxy {
    address implementation; // logic合约地址
    address admin;
    string public words;

    constructor(address _implementation) {
        admin = msg.sender;
        implementation = _implementation;
    }

    // fallback函数，将调用委托给逻辑合约
    // 不能被admin调用，避免选择器冲突引发意外
    fallback() external payable {
        require(msg.sender != admin, "Caller must not be admin!");
        (bool success, bytes memory data) = implementation.delegatecall(
            msg.data
        );
    }

    receive() external payable {}

    // 升级函数，改变逻辑合约地址，只能由admin调用
    function upgrade(address newImplementation) external {
        if (msg.sender != admin) revert();
        implementation = newImplementation;
    }
}

contract Logic1 {
    // 状态变量和proxy合约一致，防止插槽冲突
    address implementation;
    address admin;
    string public words;

    // 改变proxy中状态变量，选择器：0xc2985578
    function foo() public {
        words = "old";
    }
}

contract Logic2 {
    // 状态变量和proxy合约一致，防止插槽冲突
    address implementation;
    address admin;
    string public words;

    // 改变proxy中状态变量，选择器：0xc2985578
    function foo() public {
        words = "new";
    }
}
