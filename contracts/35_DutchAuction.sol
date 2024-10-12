// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./34_ERC721.sol";

contract DutchAuction is Ownable, ERC721 {
    uint256 public constant COLLECTION_SIZE = 10000; // NFT 总数
    uint256 public constant AUCTION_START_PRICE = 1 ether; // 起始价格
    uint256 public constant AUCTION_END_PRICE = 0.1 ether; // 结束价格
    uint256 public constant AUCTION_TIME = 10 minutes;
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes;
    uint256 public constant AUCTION_DROP_PER_STEP =
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
            (AUCTION_TIME / AUCTION_DROP_INTERVAL); // 价格衰减步长

    uint256 public auctionStartTime;
    string private _baseTokenURI;
    uint256[] private _allTokens;

    constructor(
        string memory _name,
        string memory _symbol
    ) Ownable(msg.sender) ERC721(_name, _symbol) {
        auctionStartTime = block.timestamp;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    function _addToken(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

    // 拍卖 mint 函数
    function auctionMint(uint256 quantity) external payable {
        uint256 _saleStartTime = uint256(auctionStartTime);
        // 1. 检查拍卖时间是否已经开始
        require(
            _saleStartTime != 0 && block.timestamp >= _saleStartTime,
            "The auction hasn't started yet!"
        );
        // 2. 检查是否超过 NFT 数量上限
        require(
            totalSupply() + quantity <= COLLECTION_SIZE,
            "The remaining quota is insufficient."
        );
        uint256 totalCost = getAuctionPrice() * quantity; // mint 成本
        require(msg.value >= totalCost, "Need to send more ETH.");
        for (uint i = 0; i < quantity; i++) {
            uint256 mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addToken(mintIndex);
        }
        // 剩余 ETH 退款
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    //获取排名价格
    function getAuctionPrice() public view returns (uint256) {
        if (block.timestamp < auctionStartTime) {
            // 未开始
            return AUCTION_START_PRICE;
        } else if (block.timestamp - auctionStartTime >= AUCTION_TIME) {
            // 已结束
            return AUCTION_END_PRICE;
        } else {
            // 进行中
            uint256 steps = (block.timestamp - auctionStartTime) /
                AUCTION_DROP_INTERVAL; // 上取整?
            return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}
