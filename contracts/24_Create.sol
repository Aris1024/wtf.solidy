// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Pair {
    address public factory;
    address public token0;
    address public token1;

    constructor() payable {
        factory = msg.sender;
    }

    function init(address _token0, address _token1) external {
        require(msg.sender == factory, "forbidden");
        token0 = _token0;
        token1 = _token1;
    }
}

contract PairFactory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pairAddr) {
        Pair pair = new Pair();
        pair.init(tokenA, tokenB);
        pairAddr = address(pair);
        allPairs.push(pairAddr);
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
    }
}
// WBNB地址: 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
// BSC链上的PEOPLE地址: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
