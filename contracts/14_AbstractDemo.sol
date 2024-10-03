// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

abstract contract Base {
    string public name = "Base";

    function getAlias() public pure virtual returns (string memory);
}

contract BaseImple is Base {
    function getAlias() public pure override returns (string memory) {
        return "BaseImple";
    }
}
