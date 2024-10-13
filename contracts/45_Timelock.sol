// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Timelock {
    // 事件： 交易取消
    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint executeTime
    );
    // 事件： 交易执行
    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint executeTime
    );
    // 事件： 交易创建，并加入队列
    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signagture,
        bytes data,
        uint excuteTime
    );
    // 事件： 修改管理员地址
    event NewAdmin(address indexed newAdmin);

    address public admin; // 管理员地址
    uint public constant GRACE_PERIOD = 7 days;
    uint public delay; // 交易锁定时间，单位：秒
    mapping(bytes32 => bool) public queuedTransactions; // txHash 到 bool，记录所有在时间锁队列中的交易

    modifier onlyOwner() {
        require(msg.sender == admin, "Timelock: Caller not admin");
        _;
    }

    modifier onlyTimelock() {
        require(msg.sender == address(this), "Timelock: Caller not Timelock");
        _;
    }

    /**
     * @dev 构造函数，初始化交易锁定时间 （秒）和管理员地址
     */
    constructor(uint _delay) {
        delay = _delay;
        admin = msg.sender;
    }

    /**
     * @dev 改变管理员地址，调用者必须是Timelock合约。
     */
    function changeAdmin(address _newAdmin) public onlyTimelock {
        admin = _newAdmin;
        emit NewAdmin(_newAdmin);
    }

    /**
     * @dev 创建交易并添加到时间锁队列中。
     * @param target: 目标合约地址
     * @param value: 发送eth数额
     * @param signature: 要调用的函数签名（function signature）
     * @param data: call data，里面是一些参数
     * @param executeTime: 交易执行的区块链时间戳
     *
     * 要求：executeTime 大于 当前区块链时间戳+delay
     */
    function queueTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 executeTime
    ) public onlyOwner returns (bytes32) {
        // 检查： 交易执行时间满足锁定时间
        require(
            executeTime >= getBlockTimestamp() + delay,
            "Timelock::queueTransaction: Estimated execution block must satisfy delay."
        );
        // 计算交易的唯一识别符：一堆东西的hash
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // 将交易添加到队列
        queuedTransactions[txHash] = true;

        return txHash;
    }

    /**
     * @dev 取消特定交易。
     *
     * 要求：交易在时间锁队列中
     */
    function cancelTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 executeTime
    ) public onlyOwner {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        require(
            queuedTransactions[txHash],
            "Timelock::CancelTransaction: Transaction has't been queued."
        );
        queuedTransactions[txHash] = false;
        emit CancelTransaction(
            txHash,
            target,
            value,
            signature,
            data,
            executeTime
        );
    }

    /**
     * @dev 执行特定交易。
     *
     * 要求：
     * 1. 交易在时间锁队列中
     * 2. 达到交易的执行时间
     * 3. 交易没过期
     */
    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 executeTime
    ) public payable onlyOwner returns (bytes memory) {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // 检查：交易是否在时间锁队列中
        require(
            queuedTransactions[txHash],
            "Timelock::executeTransaction: Transaction hasn't been queued."
        );
        // 检查：达到交易的执行时间
        require(
            getBlockTimestamp() >= executeTime,
            "Timelock::executeTransaction: Transaction hasn't surpassed time lock."
        );
        // 检查：交易没过期
        require(
            getBlockTimestamp() <= executeTime + GRACE_PERIOD,
            "Timelock::executeTransaction: Transaction is stale."
        );
        // 将交易移出队列
        queuedTransactions[txHash] = false;

        // 获取call data
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            // 这里如果采用encodeWithSignature的编码方式来实现调用管理员的函数，请将参数data的类型改为address。
            // 不然会导致管理员的值变为类似"0x0000000000000000000000000000000000000020"的值。
            // 其中的0x20是代表字节数组长度的意思.

            callData = abi.encodePacked(
                bytes4(keccak256(bytes(signature))),
                data
            );
            // callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), abi.decode(data, (address)));
        }
        (bool success, bytes memory returnData) = target.call{value: value}(
            callData
        );
        require(
            success,
            "Timelock::executeTransaction: Transaction execution reverted."
        );
        emit ExecuteTransaction(
            txHash,
            target,
            value,
            signature,
            data,
            executeTime
        );
        return returnData;
    }

    // 测试函数，获取最近执行时间（秒）
    function getTestLatestExecuteTime() public view returns (uint256) {
        return getBlockTimestamp() + delay;
    }

    /**
     * @dev 获取当前区块链时间戳
     */
    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    /**
     * @dev 将一堆东西拼成交易的标识符
     */
    function getTxHash(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint executeTime
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encode(target, value, signature, data, executeTime));
    }
}
