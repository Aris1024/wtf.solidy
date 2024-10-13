// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract MultisigWallet {
    event ExecutionSuccess(bytes32 txHash); // 交易成功事件
    event ExecutionFailure(bytes32 txHash); // 交易失败事件

    address[] public owners; // 多签持有人数组

    mapping(address => bool) public isOwner; // 记录一个地址是否为多签

    uint256 public ownerCount; // 多签持有人数量
    uint256 public threshold; // 多签执行门槛,交易至少有 n 个多人签名才能被执行.
    uint256 public nonce; // nonce,随机数

    receive() external payable {}

    constructor(address[] memory _owners, uint256 _threshold) {
        _setupOwners(_owners, _threshold);
    }

    function _setupOwners(
        address[] memory _owners,
        uint256 _threshold
    ) internal {
        // 检查: threshold未初始化
        require(threshold == 0, "WTF5000");
        // 检查: 门槛至少为 1
        require(_threshold >= 1, "WTF5001");
        // 检查: 门槛小于等于多签人数
        require(_threshold <= _owners.length, "WTF5002");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(
                owner != address(0) &&
                    owner != address(this) &&
                    !isOwner[owner],
                "WTF5002"
            );
            owners.push(owner);
            isOwner[owner] = true;
        }
        ownerCount = owners.length;
        threshold = _threshold;
    }

    function execTransaction(
        address to,
        uint256 _value,
        bytes memory data,
        bytes memory signatures
    ) public payable virtual returns (bool success) {
        bytes32 txHash = encodeTransactionData(
            to,
            _value,
            data,
            nonce,
            block.chainid
        );
        nonce++;
        checkSignatures(txHash, signatures);
        (success, ) = to.call{value: _value}(data);
        if (success) {
            emit ExecutionSuccess(txHash);
        } else {
            emit ExecutionFailure(txHash);
        }
    }

    function checkSignatures(
        bytes32 dataHash,
        bytes memory signatures
    ) public view {
        uint256 _threshold = threshold;
        require(_threshold > 0, "WTF5005");
        require(signatures.length >= _threshold * 65, "WTF5006");
        /** 
        通过一个循环,检查收集的签名是否有效
        大致思路: 
        1. 使用ecdsa 先验证签名是否有效
        2. 利用 currentOwner > lastOwner 确定签名来自不同多签(多签地址递增)
        3. 利用 isOwner[currentOwner] 确定签名者为多签持有人
        */
        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        for (uint256 i = 0; i < _threshold; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            // 利用 ecrecover 检查签名是否有效
            currentOwner = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n32",
                        dataHash
                    )
                ),
                v,
                r,
                s
            );
            require(
                currentOwner > lastOwner && isOwner[currentOwner],
                "WTF5007"
            );
            lastOwner = currentOwner;
        }
    }

    function signatureSplit(
        bytes memory signatures,
        uint256 pos
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        // 签名的格式：{bytes32 r}{bytes32 s}{uint8 v}
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }

    function encodeTransactionData(
        address to,
        uint256 value,
        bytes memory data,
        uint256 _nonce,
        uint256 chainId
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encode(to, value, keccak256(data), _nonce, chainId));
    }
}
