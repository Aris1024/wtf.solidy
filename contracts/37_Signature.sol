// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./34_ERC721.sol";

library ECDSA {
    function verify(
        bytes32 _msgHash,
        bytes memory _signature,
        address _signer
    ) internal pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    function recoverSigner(
        bytes32 _msgHash,
        bytes memory _signature
    ) internal pure returns (address) {
        // 检查签名长度，65是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
        assembly {
            /*
            前32 bytes存储签名的长度 (动态数组存储规则)
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32 bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        // 使用ecrecover(全局函数)：利用 msgHash 和 r,s,v 恢复 signer 地址
        return ecrecover(_msgHash, v, r, s);
    }

    function toEthSignedMessageHash(
        bytes32 _hash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
            );
    }
}

contract SignatureNFT is ERC721 {
    address public immutable signer;
    mapping(address => bool) public mintedAddress;

    constructor(
        string memory _name,
        string memory _symbol,
        bytes memory _signer
    ) ERC721(_name, _symbol) {
        signer = _signer;
    }

    function mint(
        address _account,
        uint256 _tokenId,
        bytes memory _signature
    ) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId);
        bytes32 _ethHash = ECDSA.toEthSignedMessageHash(_msgHash);
        require(verify(_ethHash, _signature), "Invalid signature");
        require(!mintedAddress[_account], "Already minted");
        mintedAddress[_account] = true;
        _mint(_account, _tokenId);
    }

    function getMessageHash(
        address _account,
        uint256 _tokenId
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    function verify(
        bytes32 _msgHash,
        bytes memory _signature
    ) public view returns (bool) {
        return ECDSA.verify(_msgHash, _signature, signer);
    }
}
