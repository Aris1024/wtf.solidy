// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface Base {
    function getFristName() external pure returns (string memory);

    function getLastName() external pure returns (string memory);
}

contract BaseImpl is Base {
    function getFristName() external pure override returns (string memory) {
        return "Frist";
    }

    function getLastName() external pure override returns (string memory) {
        return "Last";
    }
}
