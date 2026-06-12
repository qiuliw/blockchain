// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

// 部署智能合约
contract CounterScript is Script {
    Counter public counter; // counter 变量存储的不是数据，而是部署后合约的地址

    function setUp() public {} // 可选初始化函数

    function run() public {

        // startBroadcast() 标记 后面的交易需要被发送到广播。
        // --broadcast 表示自动将标记的交易发送到链上，还是只模拟测试
        vm.startBroadcast(); 

        counter = new Counter(); // new 是部署操作，不只是变量赋值

        vm.stopBroadcast(); // 停止广播交易，表示脚本的交易发送阶段结束。
    }
}
