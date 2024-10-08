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
        require(msg.sender == factory, "fobidden");
        token0 = _token0;
        token1 = _token1;
    }
}

contract PairFactory2 {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    function createPair2(
        address tokenA,
        address tokenB
    ) external returns (address pairAddr) {
        require(tokenA != tokenB, "identical address");
        // 排序
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        // salt
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        // create2 部署新合约
        Pair pair = new Pair{salt: salt}();
        pair.init(tokenA, tokenB);
        pairAddr = address(pair);
        allPairs.push(pairAddr);
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
    }

    function calculateAddr(
        address tokenA,
        address tokenB
    ) public view returns (address predicatedAddress) {
        require(tokenA != tokenB, "identical address");
        // 排序
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        // salt
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        predicatedAddress = address(
            uint160(
                uint(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            keccak256(type(Pair).creationCode)
                        )
                    )
                )
            )
        );
    }
}
// WBNB地址: 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
// BSC链上的PEOPLE地址: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
