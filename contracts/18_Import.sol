// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import { Baba } from "./13_Inheritance.sol";
// 通过网址引用
// import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol';
// 引用OpenZeppelin合约
// import '@openzeppelin/contracts/access/Ownable.sol';

contract Import {
    Baba baba = new Baba();
    function test() external {
        baba.hip();
    }
}