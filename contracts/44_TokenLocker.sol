// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./lib/IERC20.sol";
import "./31_ERC20.sol";

contract TokenLocker {
    event TokenLockStart(
        address indexed beneficiary,
        address indexed token,
        uint256 startTime,
        uint256 lockTime
    );
    event Release(
        address indexed beneficiary,
        address indexed token,
        uint256 releaseTime,
        uint256 amount
    );
    IERC20 public immutable token;
    address public immutable beneficiary;
    uint256 public immutable lockTime;
    uint256 public immutable startTime;

    constructor(IERC20 _token, address _beneficiary, uint256 _lockTime) {
        require(_lockTime > 0, "TokenLock: lock time should greater than 0");
        token = _token;
        beneficiary = _beneficiary;
        lockTime = _lockTime;
        startTime = block.timestamp;
        emit TokenLockStart(
            _beneficiary,
            address(_token),
            startTime,
            _lockTime
        );
    }

    function release() public {
        require(
            block.timestamp > startTime + lockTime,
            "TokenLock: current time is before releas time"
        );
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no tokens to release");
        token.transfer(beneficiary, amount);
        emit Release(beneficiary, address(token), block.timestamp, amount);
    }
}
