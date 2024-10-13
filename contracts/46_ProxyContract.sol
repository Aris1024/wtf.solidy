// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Proxy {
    address public implementation; // 逻辑合约地址. implementation合约同一个位置的状态变量类型必须和Proxy合约的相同，不然会报错。

    // 初始化逻辑合约地址
    constructor(address _implementation) {
        implementation = _implementation;
    }

    // 回调函数,调用'_delegate()'函数将本合约的调用委托给'implementation'合约
    fallback() external payable {
        _delegate();
    }

    receive() external payable {
        _delegate();
    }

    /**
     * @dev 将调用委托给逻辑合约运行
     */
    function _delegate() internal {
        assembly {
            // 读取位置为0的storage，也就是implementation地址。
            let _implementation := sload(0)
            calldatacopy(0, 0, calldatasize())

            // 利用delegatecall调用implementation合约
            // delegatecall操作码的参数分别为：gas, 目标合约地址，input mem起始位置，input mem长度，output area mem起始位置，output area mem长度
            // output area起始位置和长度位置，所以设为0
            // delegatecall成功返回1，失败返回0
            let result := delegatecall(
                gas(),
                _implementation,
                0,
                calldatasize(),
                0,
                0
            )
            // 将起始位置为0，长度为returndatasize()的returndata复制到mem位置0
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                // 如果delegate call失败，revert
                revert(0, returndatasize())
            }
            default {
                // 如果delegate call成功，返回mem起始位置为0，长度为returndatasize()的数据（格式为bytes）
                return(0, returndatasize())
            }
        }
    }
}

contract Logic {
    address public implementation; // 与Proxy保持一致,防止插槽冲突
    uint public x = 99;
    event LogicCalled();

    // 这个函数会释放 LogicCalled 并返回一个uint。
    // 函数selector: 0xd09de08a (这个是怎么出来的? 答: bytes4(keccak256("increment()"))) 计算出 0xd09de08a
    function increment() external returns (uint) {
        emit LogicCalled();
        return x + 1;
    }
}

contract Caller {
    address public proxy;

    constructor(address _proxy) {
        proxy = _proxy;
    }

    function increase() external returns (uint) {
        (, bytes memory data) = proxy.call(
            abi.encodeWithSignature("increment()")
        );
        return abi.decode(data, (uint));
    }
}
