// 测试命令: forge test --match-path "test/basic/Basic05Address.t.sol" -vv
pragma solidity ^0.8.26;


contract  Test {


    address public addr1 = address(uint160(0x0014723a09acff6d2a60dcdf7aa4aff308fddc160c));

    //地址address类型本质上是一个160位的数字

    //可以进行加减，需要强制转换
    function add() public view returns(uint160) {
        return uint160(addr1) + 10;
    }
    
    
    //1. 匿名函数：没有函数名，没有参数，没有返回值的函数，就是匿名函数
    //2. 当调用一个不存在的方法时，合约会默认的去调用匿名函数
    //3. 匿名函数一般用来给合约转账，因为费用低
    receive() external payable {
        
    }
    
    
    function getBalance() public view returns(uint256) {
        return addr1.balance;
    }
    
    
    function getContractBalance() public view returns(uint256) {
        //this代表当前合约本身
        //balance方法，获取当前合约的余额
        return address(this).balance;
    }
    
}