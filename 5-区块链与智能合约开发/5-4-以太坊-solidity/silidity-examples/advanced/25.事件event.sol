// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/25.事件event.t.sol" -vv
pragma solidity ^0.8.26;


contract  Test {

    //uint256 public money;
    
    mapping(address=> uint256) public personToMoney;
    
    // 1. 定义一个事件，使用圆括号，后面加上分号
    // 2. 需要使用emit关键字
    // 3. 在web3调用时可以监听到事件
    event playEvent(address, uint256, uint256);
    
    
    
    function paly() public payable {

        require(msg.value == 100);
        personToMoney[msg.sender] = msg.value;
        
        emit playEvent(msg.sender, msg.value, block.timestamp);
        
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

}