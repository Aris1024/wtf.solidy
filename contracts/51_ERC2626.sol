// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IERC4626} from "./lib/IERC4626.sol";
import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC4626 is ERC20, IERC4626 {
    ERC20 private immutable _asset;
    uint8 private immutable _decimals;

    constructor(
        ERC20 _assetAddress,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        _asset = _assetAddress;
        _decimals = _asset.decimals();
    }

    /* ================ 存款/提款逻辑 ================ */
    // 金库的基础资产代币地址（用于存款，取款）
    function asset() public view virtual returns (address) {
        return address(_asset);
    }

    function decimals()
        public
        view
        virtual
        override(IERC20Metadata, ERC20)
        returns (uint8)
    {
        return _decimals;
    }

    // 存款
    function deposit(
        uint256 assets,
        address receiver
    ) public override returns (uint256 shares) {
        // 计算获得的份额
        shares = previewDeposit(assets);
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        // 释放 Deposit 事件
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    // 铸造
    function mint(
        uint256 shares,
        address receiver
    ) public override returns (uint256 assets) {
        // 计算存款的基础资产数额
        assets = previewMint(shares);
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        // 释放 Deposit 事件
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override returns (uint256 shares) {
        // 计算份额
        shares = previewWithdraw(assets);
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }
        _burn(owner, shares);
        _asset.transfer(receiver, assets);

        // 释放 Withdraw 事件
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public override returns (uint256 assets) {
        // 计算出基础资产的数额
        assets = previewRedeem(shares);
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }
        _burn(owner, shares);
        _asset.transfer(receiver, assets);

        // 释放 Withdraw 事件
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /* ================ 会计逻辑 ================ */
    // 返回合约中基础资产持仓
    function totalAssets()
        public
        view
        override
        returns (uint256 totalManagedAssets)
    {
        return _asset.balanceOf(address(this));
    }

    // 返回利用一定数额基础资产可以换取的金库额度
    function convertToShares(
        uint256 assets
    ) public view override returns (uint256 shares) {
        uint256 supply = totalSupply();
        // 如果 supply 为 0，那么 1:1 铸造金库份额
        // 如果 supply 不为0，那么按比例铸造
        return supply == 0 ? assets : (assets * supply) / totalAssets();
    }

    // 返回利用一定数额金库额度可以换取的基础资产
    function convertToAssets(
        uint256 shares
    ) public view override returns (uint256 assets) {
        uint256 supply = totalSupply();
        // 如果 supply 为 0，那么 1:1 赎回基础资产
        // 如果 supply 不为0，那么按比例赎回
        return supply == 0 ? shares : (shares * totalAssets()) / supply;
    }

    function previewDeposit(
        uint256 assets
    ) public view override returns (uint256 shares) {
        return convertToShares(assets);
    }

    function previewMint(
        uint256 shares
    ) public view override returns (uint256 assets) {
        return convertToAssets(shares);
    }

    function previewWithdraw(
        uint256 assets
    ) public view override returns (uint256 shares) {
        return convertToShares(assets);
    }

    function previewRedeem(
        uint256 shares
    ) public view override returns (uint256 assets) {
        return convertToAssets(shares);
    }

    /* ================ 存款/提款限额逻辑 ================ */
    function maxDeposit(
        address
    ) public pure override returns (uint256 maxAssets) {
        return type(uint256).max;
    }

    function maxMint(address) public pure override returns (uint256 maxShares) {
        return type(uint256).max;
    }

    function maxWithdraw(
        address owner
    ) public view override returns (uint256 maxAssets) {
        return convertToAssets(balanceOf(owner));
    }

    function maxRedeem(
        address owner
    ) public view override returns (uint256 maxShares) {
        return balanceOf(owner);
    }
}
