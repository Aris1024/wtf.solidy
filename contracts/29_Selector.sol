// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract DemoContract {}

contract Selector {
    event Log(bytes data);
    event SelectorEvent(bytes4);

    struct User {
        uint256 uid;
        bytes name;
    }

    enum School {
        SCHOOL1,
        SCHOOL2,
        SCHOOL3
    }

    function mint(address /*to*/) external {
        emit Log(msg.data);
    }

    function mintSelector() external pure returns (bytes4 mSelector) {
        return bytes4(keccak256("mint(address)")); // 0x6a627842
    }
    function transferSelector() external pure returns (bytes4 mSelector) {
        return bytes4(keccak256("transfer(address,uint256)")); 
    }

    // selector: 无参数 0x62cb45a6
    function selectorNoParm() external returns (bytes4) {
        emit SelectorEvent(this.selectorNoParm.selector);
        return bytes4(keccak256("selectorNoParm()"));
    }

    // selector: 基础参数 0xce503639 (fuck!参数类型间不要有空格!!!)
    function selectorElementaryParam(
        uint256 _p1,
        bool _p2
    ) external returns (bytes4) {
        emit SelectorEvent(this.selectorElementaryParam.selector);
        return bytes4(keccak256("selectorElementaryParam(uint256,bool)"));
    }

    // selector: 固定长度 0xd382d1ab (fuck!参数类型间不要有空格!!!)
    function selectorFixedSizeParam(
        uint256[3] memory _p1
    ) external returns (bytes4) {
        emit SelectorEvent(this.selectorFixedSizeParam.selector);
        return bytes4(keccak256("selectorFixedSizeParam(uint256[3])"));
    }

    // selector: 无固定长度 0x124fdc1b (fuck!参数类型间不要有空格!!!)
    function selectorNoFixedSizeParam(
        uint256[] memory _p1,
        string memory _p2
    ) external returns (bytes4) {
        emit SelectorEvent(this.selectorNoFixedSizeParam.selector);
        return bytes4(keccak256("selectorNoFixedSizeParam(uint256[],string)"));
    }

    // selector: 映射 0x91c8b55c (fuck!参数类型间不要有空格!!!)
    // (参数 DemoContract合约部署地址 0xa2e9669fC58d055D0aF1BaEd20dcF10A9e0DCb97)
    function selectorMappingParam(
        DemoContract _demo,
        User memory _user,
        uint256[] memory count,
        School _shool
    ) external returns (bytes4) {
        emit SelectorEvent(this.selectorMappingParam.selector);
        return
            bytes4(keccak256("selectorMappingParam(address,(uint256,bytes),uint256[],uint8)"));
    }

    // 使用 selector 调用函数
    function callWithSignature() external {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;

        User memory user;
        user.uid = 1;
        user.name = "0xa0b1";

        // selector: 无参数 0x62cb45a6
        // selector: 基础参数 0xce503639 (fuck!参数类型间不要有空格!!!)
        // selector: 固定长度 0xd382d1ab (fuck!参数类型间不要有空格!!!)
        // selector: 无固定长度 0x124fdc1b (fuck!参数类型间不要有空格!!!)
        // selector: 映射 0x91c8b55c (fuck!参数类型间不要有空格!!!)
        // (参数 DemoContract合约部署地址 0xa2e9669fC58d055D0aF1BaEd20dcF10A9e0DCb97)
        (bool success0, bytes memory data0) = address(this).call(
            abi.encodeWithSelector(0x62cb45a6)
        );
        require(success0, "0: failed");
        (bool success1, bytes memory data1) = address(this).call(
            abi.encodeWithSelector(0xce503639, 1, false)
        );
        require(success1, "1: failed");
        (bool success2, bytes memory data2) = address(this).call(
            abi.encodeWithSelector(0xd382d1ab, [1, 2, 3])
        );
        require(success2, "2: failed");
        (bool success3, bytes memory data3) = address(this).call(
            abi.encodeWithSelector(0x124fdc1b, arr, "aris")
        );
        require(success3, "3: failed");
        (bool success4, bytes memory data4) = address(this).call(
            abi.encodeWithSelector(
                0x91c8b55c,
                0xa2e9669fC58d055D0aF1BaEd20dcF10A9e0DCb97,
                user,
                arr,
                2
            )
        );
        require(success4, "4: failed");

        require(
            success0 && success1 && success2 && success3 && success4,
            "please check your code!"
        );
    }
}
