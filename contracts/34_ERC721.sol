// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./lib/IERC165.sol";
import "./lib/IERC721.sol";
import "./lib/IERC721Receiver.sol";
import "./lib/IERC721Metadata.sol";
import "./lib/String.sol";

contract ERC721 is IERC721, IERC721Metadata {
    string public override name;
    string public override symbol;
    mapping(uint => address) private _owners; // tokenId 到 owner address
    mapping(address => uint) private _balances; // address 到 持仓数量
    mapping(uint => address) private _tokenApprovals; // tokenId 到 授权地址
    mapping(address => mapping(address => bool)) private _operatorApprovals; // owner 地址 到 operator 批量授权

    error ERC721InvalidReceiver(address receiver);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    // 实现IERC165接口supportsInterface
    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    // 实现IERC721的balanceOf，利用_balances变量查询owner地址的balance。
    function balanceOf(
        address owner
    ) external view override returns (uint256 balance) {
        require(owner != address(0), "owner can not be zero address");
        balance = _balances[owner];
    }

    // 实现IERC721的ownerOf，利用_owners变量查询tokenId的owner。
    function ownerOf(
        uint256 tokenId
    ) public view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "owner does't exist");
    }

    // 实现IERC721的setApprovalForAll，将持有代币全部授权给operator地址。
    function setApprovalForAll(
        address operator,
        bool _approved
    ) external override {
        _operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    // 实现IERC721的isApprovedForAll，利用_operatorApprovals变量查询owner地址是否将所持NFT批量授权给了operator地址。
    function isApprovedForAll(
        address owner,
        address operator
    ) external view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 授权函数。通过调整_tokenApprovals来，授权 to 地址操作 tokenId，同时释放Approval事件。
    function _approve(address owner, address to, uint tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 实现IERC721的approve，将tokenId授权给 to 地址。条件：to不是owner，且msg.sender是owner或授权地址。调用_approve函数。
    function approve(address to, uint256 tokenId) external override {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all!"
        );
        _approve(owner, to, tokenId);
    }

    // 实现IERC721的getApproved，利用_tokenApprovals变量查询tokenId的授权地址。
    function getApproved(
        uint256 tokenId
    ) external view override returns (address operator) {
        require(_owners[tokenId] != address(0), "token does't exist");
        operator = _tokenApprovals[tokenId];
    }

    // 查询 spender地址是否可以使用tokenId（需要是owner或被授权地址）
    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) private view returns (bool) {
        return (spender == owner || // 是 owner
            _tokenApprovals[tokenId] == spender || // 被授权
            _operatorApprovals[owner][spender]); // 被授权全部
    }

    /*
     * 转账函数。通过调整_balances和_owner变量将 tokenId 从 from 转账给 to，同时释放Transfer事件。
     * 条件:
     * 1. tokenId 被 from 拥有
     * 2. to 不是0地址
     */
    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner"); // ??
        require(to != address(0), "transfer to the zero address");
        _approve(owner, address(0), tokenId); // tokenId 授权给 0地址?
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    // 实现IERC721的transferFrom，非安全转账，不建议使用。调用_transfer函数
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        address owner = ownerOf(tokenId);
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "");
        _transfer(owner, from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external override {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {}

    function tokenURI(
        uint256 tokenId
    ) external view override returns (string memory) {}
}
