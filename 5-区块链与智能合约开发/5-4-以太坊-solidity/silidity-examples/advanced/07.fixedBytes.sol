// 测试命令: forge test --match-path "test/basic/07.fixedBytes.t.sol" -vv
pragma solidity ^0.8.26;


contract FixedBytes {

    bytes1 b1 ="h";
    
    bytes20 b10 = "helloworld";

    function getLen() public view returns(uint256) {
        return b10.length;
    }
    
    function setValue() private pure {
        //1. 固定长度数组可以通过下标访问
        //2. 只能读取，不能写
        //b10[0] = v;
    }
    
    //3. 存储的时候是ascii值存储
    function getValue(uint256 i) public view returns (bytes1) {
        return b10[i];
    }
}