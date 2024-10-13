// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// 新版本路径发生了变化, 跟教程中不一样了
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// 使用 sepolia 网络部署 !!!!
contract RandomNumberConsumer is VRFConsumerBaseV2Plus {
    // 申请的 ID 103026944717955717774495637441281979486253044879036274305372049437453709684695
    uint256 s_subId; // 这个 ID 变长了,需要使用 uint256;
    // 存放得到的 requestId 和 随机数
    uint256 public requestId;
    uint256[] public randomWords;
    // 数据从这里获取: https://docs.chain.link/vrf/v2-5/supported-networks#sepolia-testnet
    // VRF Coordinator 合约地址 (sepolia)
    address vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    // 500 gwei Key Hash
    bytes32 s_keyHash =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint16 s_minimumRequestConfirmations = 3;
    uint32 s_callbackGasLimit = 200_000;
    uint32 s_numWords = 3;

    constructor(uint256 _subId) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_subId = _subId;
        // s_coordinator 不用声明,父合约中有该状态变量,直接使用即可 
    }

    function requestRandomWords() external {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subId,
                requestConfirmations: s_minimumRequestConfirmations,
                callbackGasLimit: s_callbackGasLimit,
                numWords: s_numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal virtual override {
        randomWords = _randomWords;
    }
}
