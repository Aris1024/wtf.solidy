// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./lib/IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    mapping(address => uint) private _nonces;
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    constructor(
        string memory name_,
        string memory symbol_
    ) EIP712(name_, "1") ERC20(name_, symbol_) {}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override {
        // 检查过期时间
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _userNonce(owner),
                deadline
            )
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s);
        require(owner == signer, "ERC20Permit: invalid signature");
        
        _approve(owner, spender, value);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner];
    }

    function _userNonce(
        address owner
    ) internal virtual returns (uint256 current) {
        current = _nonces[owner];
        _nonces[owner] += 1;
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function mint(uint amount) external {
        _mint(msg.sender, amount);
    }

    function getTimestamp() public view returns(uint256) {
        return block.timestamp;
    }
}
