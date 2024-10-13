// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./lib/IERC721.sol";
import "./lib/IERC721Receiver.sol";
import "./34_ArisApe.sol";

contract NFTSwap is IERC721Receiver {
    event List(
        address indexed saller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event Purchase(
        address indexed buyer,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event Revoke(
        address indexed saller,
        address indexed nftAddr,
        uint256 indexed tokenId
    );
    event Update(
        address indexed saller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 newPrice
    );

    struct Order {
        address owner;
        uint256 price;
    }
    // NFT Order 映射
    mapping(address => mapping(uint256 => Order)) public nftList;

    receive() external payable {}

    fallback() external payable {}

    // 挂单: 卖家上架 NFT, _nftAddress:NFT 地址, _tokenId: 对应 ID, _price: 价格 (wei)
    function list(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _price
    ) public {
        require(_price > 0, "Invalid price");
        IERC721 nft = IERC721(_nftAddress);
        require(nft.getApproved(_tokenId) == address(this), "Need Approval");
        Order storage order = nftList[_nftAddress][_tokenId];
        order.owner = msg.sender;
        order.price = _price;
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        emit List(msg.sender, _nftAddress, _tokenId, _price);
    }

    // 购买: 买家购买 NFT, _nftAddress:NFT 地址, _tokenId: 对应 ID
    function purchase(address _nftAddress, uint256 _tokenId) public payable {
        Order storage order = nftList[_nftAddress][_tokenId];
        // 检查: 订单是否存在,可以换成 order.owner != address(0), 而不是判断价格(有点歪)
        require(order.price > 0, "Invalid price");
        // 检查: 发送的钱要足够购买
        require(msg.value > order.price, "Increse price");
        IERC721 nft = IERC721(_nftAddress);
        // 检查: 当前合约必须是持有者
        require(nft.ownerOf(_tokenId) == address(this), "Invalid Order");

        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        payable(order.owner).transfer(order.price); // 向卖家转账
        payable(msg.sender).transfer(msg.value - order.price); // 剩余的退回
        delete nftList[_nftAddress][_tokenId]; // 删除 order
        emit Purchase(msg.sender, _nftAddress, _tokenId, order.price);
    }

    // 撤单: 卖家取消挂单
    function revoke(address _nftAddress, uint256 _tokenId) public {
        Order storage order = nftList[_nftAddress][_tokenId];
        require(order.owner == msg.sender, "Not owner");

        IERC721 nft = IERC721(_nftAddress);
        require(nft.ownerOf(_tokenId) == address(this), "Invalid order");

        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddress][_tokenId];
        emit Revoke(msg.sender, _nftAddress, _tokenId);
    }

    // 更新: 卖家更新挂单价格
    function update(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _newPrice
    ) public {
        Order storage order = nftList[_nftAddress][_tokenId];
        // 检查: 订单是否存在,可以换成 order.owner != address(0), 而不是判断价格(有点歪)
        require(order.price > 0, "Invalid price");
        // 检查: 支持有人发起
        require(order.owner == msg.sender, "Not owner");

        IERC721 nft = IERC721(_nftAddress);
        require(nft.ownerOf(_tokenId) == address(this), "Invalid Order");

        order.price = _newPrice;
        emit Update(msg.sender, _nftAddress, _tokenId, _newPrice);
    }

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
