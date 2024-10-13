// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
// UUPS的Proxy，跟普通的proxy像。
// 升级函数在逻辑函数中，管理员可以通过升级函数更改逻辑合约地址，从而改变合约的逻辑。
// 教学演示用，不要用在生产环境
contract UUPSProxy {
    address public implementation;
    address public admin;
    string public words;
    constructor(address _impl) {
        admin = msg.sender;
        implementation = _impl;
    }
    // fallback函数，将调用委托给逻辑合约
    fallback() external payable {
        /* 
            A 角色: msg.sender;
            B 角色: 当前合约
            C 角色: 逻辑可约
            过程: 
                - A使用"低级交互(low level interactions)调用 B"
                - B 的 fallback 收到消息,然后执行 C.delegatecall(msg.data)
                    - 语境: 合约 B
                    - msg.sender = A msg.value = A合约的
                - C合约的方法被执行
                    - 具体是哪个方法,取决于msg.data 包含调用函数的选择器和参数。
                    - 语境: 合约 B
                    - msg.sender = A msg.value = A合约的
        
        在线编码地址: https://abi.hashex.org/
            - Function 选择 "your function", 输入 upgrade
            - Argument 选择 "Address",输入 UUPS2 合约地址
            - 拷贝 Encoded data 0900f010000000000000000000000000e2899bddfd890e320e643044c6b95b9b0b84157a
         */
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }
    receive() external payable {}
}
contract UUPS1 {
    address public implementation;
    address public admin;
    string public words;
    // 改变proxy中状态变量，选择器： 0xc2985578
    function foo() public{
        words = "old";
    }
    // 升级函数，改变逻辑合约地址，只能由admin调用。选择器：0x0900f010
    // UUPS中，逻辑函数中必须包含升级函数，不然就不能再升级了。
    function upgrade(address newImpl) external {
        require(msg.sender == admin, "The caller must be an administrator.");
        implementation = newImpl;
    }
}
contract UUPS2 {
    address public implementation;
    address public admin;
    string public words;
    // 改变proxy中状态变量，选择器： 0xc2985578
    function foo() public{
        words = "new";
    }
    // 升级函数，改变逻辑合约地址，只能由admin调用。选择器：0x0900f010
    // UUPS中，逻辑函数中必须包含升级函数，不然就不能再升级了。
    function upgrade(address newImpl) external {
        require(msg.sender == admin, "The caller must be an administrator.");
        implementation = newImpl;
    }
}