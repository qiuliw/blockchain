// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/Adv26Accessors.t.sol" -vv
pragma solidity ^0.8.26;


contract  Test {
    
    // 加了public 的转态变量，solidity会自动的生成一个同名个访问函数。
    // 在合约内部使用这个状态变量的时候，直接当初变量使用即可
    // 如果在合约外面向访问这个public变量（data），就需要使用xx.data()形式
    uint256 public data = 200;
    
    
    function getData() public view returns(uint256) {
        return data;
    }
    
    //This代表合约本身，如果在合约内部使用this自己的方法的话，相当于外部调用
    function getData1() public view returns(uint256) {
        //return this.data;   //不能使用.data形式
        return this.data();
    }
}

contract Test1 {
    
    function getValue() public returns(uint256) {
        Test t1 = new Test();
        return t1.data();
    }
}