// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract DataStorage {
    uint[] public x = [1, 2, 3]; // 默认 存储在 storage 上
    uint[] public x2 = x; // storage 赋值给 storage(函数外部),创建独立副本,修改其中一个不会影响另一个.

    function fStorage() public {
        // 声明一个 storage 变量 xStorage,指向 x, 修改 xStorage 也会影响 x
        // storage 赋值给 storage(函数内)会创建引用,改变函数内变量会影响原变量
        uint[] storage xStorage = x;
        xStorage[0] = 100;
    }

    function fMemory() public view {
        // storage赋值给 memory,会创建一个独立副本,修改其中一个不会影响另一个;反之亦然
        uint[] memory xMemory = x;
        xMemory[0] = 100;
        xMemory[1] = 200;
        uint[] memory xMemory2 = x;
        xMemory2[0] = 300;
    }

    function fCalldata(
        uint[] calldata _x
    ) public pure returns (uint[] calldata) {
        // 数据存储位置为calldata,函数内部不能对其修改
        // _x[0] = 123; // 报错: Calldata arrays are read-only.solidity(6182)
        return (_x);
    }
}

contract Variables {
    /**
     * 变量作用域有 3 种
     * 1. 状态变量
     * 2. 局部变量
     * 3. 全局变量
     *
     */
    uint public x = 1;
    uint public y;
    string public z;

    // 可以在函数内部修改状态变量的值
    function foo() external {
        x = 5;
        y = 2;
        z = "Aris";
    }

    function bar() external pure returns (uint) {
        uint xx = 1;
        uint yy = 2;
        uint zz = xx + yy;
        return (zz);
    }
    function global() external view returns(address, uint, bytes memory) {
        address sender = msg.sender;
        uint blockNum = block.number;
        bytes memory data  = msg.data;
        return (sender, blockNum, data);
    }
    function weiUnit() external pure returns(uint) {
        assert(1 wei == 1e0);
        assert(1 wei == 1);
        return  1 wei;
    }
    function gweUnit() external pure returns(uint) {
        assert(1 gwei == 1e9);
        assert(1 gwei == 1000000000);
        return 1 gwei;
    }
    function etherUnit() external pure returns(uint) {
        assert(1 ether == 1e18);
        assert(1 ether == 1000000000000000000);
        return 1 ether;
    }
    function secondUnit() external pure returns(uint) {
        assert(1 seconds == 1);
        return 1 seconds;
    }
    function hoursUnit() external pure returns(uint) {
        assert(1 hours == 3600);
        assert(1 hours == 60 minutes);
        return 1 hours;
    }
    function daysUnit() external pure returns(uint) {
        assert(1 days == 86400);
        assert(1 days == 24 hours);
        return 1 days;
    }
    function weekUnit() external pure returns(uint) {
        assert(1 weeks == 604800);
        assert(1 weeks == 7 days);
        return 1 weeks;
    }
}
