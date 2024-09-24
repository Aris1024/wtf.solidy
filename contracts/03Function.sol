// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
contract FunctionTypes {
    uint256 public number = 5;
    constructor() payable {}
    // 函数类型
    // function <function name>(<parameter typers>)  {internal | external | public | private} [pure | view | payable] [returns( <return types>)]

    function add() external {
        number = number + 1;
    }

    // pure: 不能读且不能写状态变量
    function addPure(uint256 _number) external pure returns(uint256 new_number) {
        // new_number = number; // 读报错: Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
        // number = 2; // 写报错: Function cannot be declared as pure because this expression (potentially) modifies the state.solidity(8961)
        new_number = _number + 1;
    }
    // view: 能读不能写状态变量
    function addView() external view returns(uint256 new_number) {
        // number = 1; // 写操作报错: Function cannot be declared as view because this expression (potentially) modifies the state.solidity(8961)
        new_number = number + 1;
    }
    // internal: 内部函数
    function minus() internal {
        number = number - 1;
    }
    // 合约内的函数可以调用内部函数
    function minusCall() external {
        minus();
    }
    // payable: 可以接收转账的函数
    function minusPayable() external payable returns(uint256 balance) {
        minus();
        balance = address(this).balance;
    }
}