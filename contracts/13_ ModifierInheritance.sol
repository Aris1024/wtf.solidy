// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Base1 {
    modifier exactDividedBy2And3(uint _a) virtual {
        require(_a % 2 == 0 && _a % 3 == 0);
        _;
    }
}

contract Identifier is Base1 {
    function getExactDividedBy2And3(
        uint _divdend
    ) public pure exactDividedBy2And3(_divdend) returns (uint, uint) {
        return getExactDividedBy2And3WithoutModifier(_divdend);
    }

    //计算一个数分别被2除和被3除的值
    function getExactDividedBy2And3WithoutModifier(
        uint _divdend
    ) public pure returns (uint, uint) {
        uint div2 = _divdend / 2;
        uint div3 = _divdend / 3;
        return (div2, div3);
    }

    //重写Modifier,故意去掉检查
    // modifier exactDividedBy2And3(uint _a) override {
    //     _;
    // }
}
