// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./lib/IERC20.sol";

contract Aridrop {
    mapping(address => uint) failTransferList;

    function getSum(uint256[] calldata _arr) public pure returns (uint sum) {
        for (uint i = 0; i < _arr.length; i++) {
            sum = sum + _arr[i];
        }
    }

    // 多个地址转账 ERC20 代币
    function multiTransferToken(
        address _token,
        address[] calldata _addresses,
        uint256[] calldata _amounts
    ) external {
        // 1. 检查 二者长度
        require(_addresses.length == _amounts.length, "Addresses and amounts arrays are not equal in length.");
        // 2. 检查 授权额度
        IERC20 token = IERC20(_token);
        uint sum = getSum(_amounts);
        require(token.allowance(msg.sender, address(this)) >= sum, "ERC20 token authorization amount is insufficient.");
        // 3. 遍历转账代币(空投 代币)
        for (uint i = 0; i < _addresses.length; i++) {
            token.transferFrom(msg.sender, _addresses[i], _amounts[i]);
        }
        
    }

    // 多个地址转账 ETH (payable)
    function multiTransferETH(
        address[] calldata _addresses,
        uint256[] calldata _amounts
    ) external payable {
        // 1. 检查 二者长度
        require(_addresses.length == _amounts.length, "Addresses and amounts arrays are not equal in length.");
        // 2. 检查 转入 ETH数量与要发送的 ETH 总数量 是否相等 (少了不行,多了浪费)
        uint sum = getSum(_amounts);
        require(msg.value == sum, "Transfer amount error");
        // 3. 遍历 转入 ETH (空投 EHT)
        for (uint i = 0; i < _addresses.length; i++) {
            // 转账ETH 的方法有 transfer,send,call 推荐用 call (第 20 节课 SendETH)
            (bool success, ) = _addresses[i].call{value: _amounts[i]}("");
            if (!success) {
                failTransferList[_addresses[i]] = _amounts[i]; // 记录转账失败的地址 (人性化一点!!!)
            }
        }

    }

    function withdrawFromFailList(address _to) public {
        uint amount = failTransferList[msg.sender];
        require(amount > 0, "You are not in failed list");
        failTransferList[msg.sender] = 0; // 先标记 0
        (bool success, ) = _to.call{value: amount}("");
        if (!success) { // 真背,又没领成功,哈哈哈,还加回去
            failTransferList[msg.sender] = amount;
        }
        require(success, "Withdraw failed!");
    }
}

/*  
    ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
    ["0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678", "0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7"]
    [100, 200]
*/
