// 测试命令: forge test --match-path "test/basic/13.fixedArray.t.sol" -vv
pragma solidity ^0.8.26;


contract  Test {
    
    //Type[Len] name
    
    uint256[10] public numbers = [1,2,3,4,5,6,7,8,9, 10];
    
    uint256 public sum;
    
    // - 类型T，长度K的数组定义为T[K]，例如：uint [5] numbers,  byte [10] names;
    // - 内容可变
    // - 长度不可变，不支持push
    // - 支持length方法

    function total() public returns(uint256) {
        for (uint256 i = 0; i < numbers.length; i++) {
            sum += numbers[i];
        }
        
       return sum; 
    }
    
    function setLen() public {
        //numbers.length = 10;
    }
    
    function changeValue(uint256 i , uint256 value) public {
        numbers[i] = value;
    }
    
    //++++++++++++++++++++++++++++++++++
    
    bytes10 public helloworldFixed = 0x68656c6c6f776f726c64;
    
    bytes1[10] public helloworldDynamic = [bytes1(0x68), 0x65, 0x6c, 0x6c, 0x6f, 0x77, 0x6f, 0x72, 0x6c, 0x64];
    
    bytes public b10;
    
    function setToBytes() public  returns (string memory){
        for (uint256 i=0; i< helloworldDynamic.length; i++) {
            bytes1 b1 = helloworldDynamic[i];
            b10.push(b1);
        }
        
        return string(b10);
    }
}