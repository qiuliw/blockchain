// 测试命令: forge test --match-path "test/basic/11.memoryVsStorage.t.sol" -vv
pragma solidity ^0.8.26;


contract MemoryVsStorage {
    string public name = "lily";
    uint256 public num = 10;
    
    function call1() public {
        setName(name);    
    }
    
    //对于引用类型数据，作为函数参数时，默认是memory类型（值传递）
    //function setName(string memory input) private {
    function setName(string memory input) private {
        num = 20;
        bytes(input)[0] = "L";
    }
    
    function call2() public {
        setName2(name);
    }
    
    //2. 如果想引用传递，那么需要明确指定为storage类型
    function setName2(string storage input) private {
        num = 30;
        bytes(input)[0] = "L";
    }
    
    //局部引用类型必须显式写 memory 或 storage，不能省略
    function localTest() public {
        //string tmp = name;
        string storage tmp = name;
        num = 40;
        bytes(tmp)[0] = "L";
    }
    
    function localTest1() public {
        
        //也可以明确设置为memory类型
        string memory tmp = name;
        num = 50;
        bytes(tmp)[0] = "L";
    }
}