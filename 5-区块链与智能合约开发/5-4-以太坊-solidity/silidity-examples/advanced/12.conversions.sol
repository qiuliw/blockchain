// 测试命令: forge test --match-path "test/basic/12.conversions.t.sol" -vv
pragma solidity ^0.8.26;


contract Conversions {
    
    bytes10 public b10 = 0x68656c6c6f776f726c64; //helloworld
    
    bytes public bs10 = new bytes(b10.length);
    
    //将固定长度数组的值赋值给不定长度数组
    function fixedByteToBytes() public {
        //bs10 = b10;
        for (uint256 i = 0; i < b10.length; i++) {
            bs10[i] = b10[i];
        }
    }
    
    
    
    
    //将bytes转成string
    string public str1;
    
    function bytesToString() public {
        fixedByteToBytes();
        str1 = string(bs10);
    }
    
    
    
    //将string转成bytes
    bytes public bs20;
    
    function stringToBytes() public {
        bytesToString();
        bs20 = bytes(str1);
    }
}