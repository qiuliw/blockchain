// 测试命令: 无对应 Foundry 测试（课件演示，可用 FOUNDRY_PROFILE=advanced forge build 编译检查）
pragma solidity ^0.8.26;


contract  Test {

    address public owner;
    uint256 a;
    address public caller;
    
    constructor() {
        //在部署合约的时候，设置一个全局唯一的合约所有者，后面可以使用权限控制
        owner = msg.sender;
    }
    
    //1. msg.sender是一个可以改变的值，并不一定是合约的创造者
    //2. 任何人调用了合约的方法，那么这笔交易中的from就是当前msg.sender
    function setValue(uint256 input) public {
        a = input;
        caller = msg.sender;
    }
}