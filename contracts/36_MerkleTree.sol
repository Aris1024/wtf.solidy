// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./34_ERC721.sol";

library MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function processProof(
        bytes32[] memory proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        bytes32 _hash = leaf;
        for (uint i = 0; i < proof.length; i++) {
            _hash = _hashPair(_hash, proof[i]);
        }
        return _hash;
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return
            a < b
                ? keccak256(abi.encodePacked(a, b))
                : keccak256(abi.encodePacked(b, a));
    }
}

contract MerkleTree is ERC721 {
    bytes32 public immutable root;
    mapping(address => bool) public mintedAddress; // 记录

    constructor(
        string memory _name,
        string memory _symbol,
        bytes32 _root
    ) ERC721(_name, _symbol) {
        root = _root;
    }

    function mint(
        address account,
        uint256 tokenId,
        bytes32[] calldata proof
    ) external {
        require(_verify(_leaf(account), proof), "invalid proof");
        require(!mintedAddress[account], "Already minted");
        mintedAddress[account] = true;
        _mint(account, tokenId);
    }

    function _leaf(address _account) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(
        bytes32 leaf,
        bytes32[] memory proof
    ) internal view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }
}
/* 
    [
        "0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C",
        "0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB",
        "0x583031D1113aD414F02576BD6afaBfb302140225",
        "0xdD870fA1b7C4700F2BD7f44238821C26f7392148"
    ]
 */
