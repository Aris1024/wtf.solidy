// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract OtherContract {
    uint256 private _x = 0;
    event Log(uint amount, uint gas);

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function setX(uint256 x) external payable {
        _x = x;
        if (msg.value > 0) {
            emit Log(msg.value, gasleft());
        }
    }

    function getX() external view returns (uint x) {
        x = _x;
    }
}

contract CallContract {
    function callSetX(address _address, uint256 x) external {
        OtherContract(_address).setX(x);
    }

    function callGetX(OtherContract _address) external view returns (uint x) {
        x = _address.getX();
    }

    function callGetX2(address _address) external view returns (uint x) {
        OtherContract oc = OtherContract(_address);
        x = oc.getX();
    }

    function setXTrasnferETH(
        address otherContract,
        uint256 x
    ) external payable {
        OtherContract(otherContract).setX{value: msg.value}(x);
    }
}
