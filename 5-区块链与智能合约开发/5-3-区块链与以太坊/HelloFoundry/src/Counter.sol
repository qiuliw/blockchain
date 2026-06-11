// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 智能合约
contract Counter {
    // 当前存储在链上的计数值。
    // `public` 可见性会自动生成一个 getter 函数。
    uint256 public number;

    // 将计数器设置为指定值。
    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    // 将计数器加一。
    function increment() public {
        number++;
    }
}

// 读取是免费的
// 写入变更区块链是要手续费和确认的
