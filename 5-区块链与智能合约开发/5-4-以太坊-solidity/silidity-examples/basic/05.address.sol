// 测试命令: forge test --match-path "test/basic/05.address.t.sol" -vv
pragma solidity ^0.8.26;


contract Address {


    address public addr1 = address(uint160(0x0014723a09acff6d2a60dcdf7aa4aff308fddc160c));

    //地址address类型本质上是一个160位的数字

    //可以进行加减，需要强制转换
    function add() public view returns(uint160) {
        return uint160(addr1) + 10;
    }
    
    
    // receive：接收纯 ETH 转账的特殊函数（无 calldata，gas 较低）
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