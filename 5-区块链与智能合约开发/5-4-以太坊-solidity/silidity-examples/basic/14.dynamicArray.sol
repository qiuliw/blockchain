// 测试命令: forge test --match-path "test/basic/14.dynamicArray.t.sol" -vv
pragma solidity ^0.8.26;


contract DynamicArray {
    
    //第一种创建方式，直接赋值
    uint8[] numbers = [1,2,3,4,5,6,7,8,9,10];
    
    function pushData(uint8 num) public {
        numbers.push(num);
    }
    
    function getNumbers() public view returns (uint8[] memory) {
        return numbers;
    }
    
    
    //使用new关键字进行创建，赋值给storage变量数组
    uint8[] numbers2;
    
    function setNumbers2() public {
        numbers2 = new uint8[](7);
        // 0.8 中不能直接 numbers2.length = 20，用 push 扩展
        while (numbers2.length < 20) {
            numbers2.push(0);
        }
        numbers2.push(10);
    }
    
    function getNumbers2() public view returns (uint8[] memory) {
        return numbers2;
    }
    
    function setNumbers3() public {
        //使用new创建的memory类型数组，无法改变长度
        //uint8[] memory numbers3 = new uint8[](7);
        uint8[] memory numbers3;
        
        //numbers3.push(10);
        
    }
}