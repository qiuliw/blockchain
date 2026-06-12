// 测试命令: forge test --match-path "test/basic/04.payable.t.sol" -vv
pragma solidity ^0.8.26;


contract  Test {
    
    string public str ;
    
    //修饰为payable的函数才可以接收转账
    //不指定payable无法接收
    function test1(string memory src) public payable {
        str = src;
    }
    
    function test2(string memory src) public {
        str = src;
    }
    
    function getbalance() public view returns(uint256) {
        //this代表当前合约本身
        //balance方法，获取当前合约的余额
        return address(this).balance;
    }
}