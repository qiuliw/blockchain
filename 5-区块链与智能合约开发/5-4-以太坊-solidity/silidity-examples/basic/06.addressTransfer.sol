// 测试命令: forge test --match-path "test/basic/06.addressTransfer.t.sol" -vv
pragma solidity ^0.8.26;


contract AddressTransfer {

    address public addr0 = address(uint160(0x00ca35b7d915458ef540ade6068dfe2f44e8fa733c));
    address public addr1 = address(uint160(0x0014723a09acff6d2a60dcdf7aa4aff308fddc160c));
    
    // receive：接收纯 ETH 转账的特殊函数（无 calldata，gas 较低）
    receive() external payable {
        
    }
    
    function getBalance() public view returns(uint256) {
        return addr1.balance;
    }
    
    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    //由合约向addr1 转账10以太币
    function transfer() public {
        //1. 转账的时候单位是wei
        //2. 1 ether = 10 ^18 wei （10的18次方）
        //3. 向谁转钱，就用谁调用tranfer函数
        //4. 花费的是合约的钱
        //5. 如果金额不足，transfer函数会抛出异常
        payable(addr1).transfer(10 * 10 **18);
    }
    
    //send转账与tranfer使用方式一致，但是如果转账金额不足，不会抛出异常，而是会返回false
    function sendTest() public {
        payable(addr1).send(10 * 10 **18);
    }
}