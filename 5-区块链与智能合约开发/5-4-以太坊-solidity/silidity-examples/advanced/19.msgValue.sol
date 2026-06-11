// 测试命令: 无对应 Foundry 测试（课件演示，可用 FOUNDRY_PROFILE=advanced forge build 编译检查）
pragma solidity ^0.8.26;


contract  Test {

    //uint256 public money;
    
    mapping(address=> uint256) public personToMoney;
    
    //函数里面使用了msg.value，那么函数要修饰为payable
    function paly() public payable {
        
        // 如果转账不是100wei，那么参与失败
        // 否则成功，并且添加到维护的mapping中
        // if (msg.value != 100) {
        //     revert();
        // }
        
        require(msg.value == 100);
        personToMoney[msg.sender] = msg.value;
        
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

}