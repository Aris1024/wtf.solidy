// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// 这个合约会把收到的ETH按事先定好的份额分给几个账户。
// 收到ETH会存在分账合约中，需要每个受益人调用release()函数来领取。
contract PaymentSplit {
    // 事件
    event PayeeAdded(address account, uint256 shares); // 增加受益人
    event PaymentReleased(address to, uint256 amount); // 受益人提款
    event PaymentReceived(address from, uint256 amount); // 合约收款

    uint256 public totalShares; // 总份额
    uint256 public totalReleased; // 总支付

    mapping(address => uint256) public shares; // 每个受益人的份额
    mapping(address => uint256) public released; // 支付给每个受益人的金额

    address[] public payees; // 受益人数组
    /**
     * @dev 初始化受益人数组_payees和分账份额数组_shares
     * 数组长度不能为0，两个数组长度要相等。_shares中元素要大于0，_payees中地址不能为0地址且不能有重复地址
     */
    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        // 检查_payees和_shares数组长度相同，且不为0
        require(
            _payees.length == _shares.length,
            "PaymentSplitter: payees and shares length mismatch"
        );
        require(_payees.length > 0, "PaymentSplitter: no payees");
        // 调用_addPayee，更新受益人地址payees、受益人份额shares和总份额totalShares
        for (uint256 i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    function _addPayee(address _account, uint256 _accountShares) private {
        // 检查: _account不为0地址; _accountShares 大于 0; _account不能重复
        require(
            _account != address(0),
            "PaymentSplitter: account is the zero address"
        );
        require(_accountShares > 0, "PaymentSplitter: shares are 0");
        require(
            shares[_account] == 0,
            "PaymentSplitter: account already has shares"
        );
        // 更新payees,shares,totalShares
        payees.push(_account);
        shares[_account] = _accountShares;
        totalShares += _accountShares;
        // 释放事件:增加受益人
        emit PayeeAdded(_account, _accountShares);
    }

    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function release(address payable _account) public virtual {
        // account必须是有效受益人
        require(shares[_account] > 0, "PaymentSplitter: account has no shares");
        // 计算应得的ETH
        uint256 payment = releasable(_account);
        // 应得的ETH不能为0
        require(payment != 0, "PaymentSplitter: account is not due payment");
        totalReleased += payment;
        released[_account] += payment;
        _account.transfer(payment);
        emit PaymentReleased(_account, payment);
    }

    function releasable(address _account) public view returns (uint256) {
        uint256 totalReceived = address(this).balance + totalReleased;
        return pendingPayment(_account, totalReceived, released[_account]);
    }

    function pendingPayment(
        address _account,
        uint256 _totalReceived,
        uint256 _alreadyReleased
    ) public view returns (uint256) {
        // account应得的ETH = 总应得ETH - 已领到的ETH
        return
            (_totalReceived * shares[_account]) /
            totalShares -
            _alreadyReleased;
    }
}
