// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./34_ERC721.sol";

contract ArisApe is ERC721 {
    uint public MAX = 10000;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }

    function mint(address to, uint tokenId) external {
        require(tokenId >= 0 && tokenId < MAX, "tokenId out of range");
        _mint(to, tokenId);
    }
}
