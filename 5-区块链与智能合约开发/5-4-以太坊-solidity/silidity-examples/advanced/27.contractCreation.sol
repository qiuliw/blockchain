// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/27.contractCreation.t.sol" -vv
pragma solidity ^0.8.26;


// 合约类型与地址的转换
contract  C1 {
    
    uint256 public value ;
    
    constructor(uint256 input) {
        value = input;
    }

    function getValue() public view returns(uint256) {
        return value;
    }
}

contract C2 {
    C1 public c1;  //0x0000000000000
    C1 public c11;  //0x0000000000000
    C1 public c13;
    
    function getValue1() public returns(uint256) {
        
        //创建一个合约，返回地址
        address addr1 = address(new C1(10));  // 0.8 中 new 返回合约类型，需显式转 address
        //return addr1.getValue();
        
        //需要显示的转换为特定类型，才可以正常使用
        c1 = C1(addr1);
        
        return c1.getValue();
    }
    
    
    function getValue2() public returns(uint256) {
        
        //定义合约的时候，同时完成类型转换
        c11 = new C1(20);
        return c11.getValue();
    }
    
    
    function getValue3(address addr) public returns(uint256) {
        //传进来的地址必须是同类型的，如果是不是C1类型的，转换时报错
        c13 = C1(addr);
        return c13.getValue();
    }
}








