// 测试命令: 无对应 Foundry 测试（课件演示，可用 FOUNDRY_PROFILE=advanced forge build 编译检查）
pragma solidity ^0.8.26;

contract Test{
    
    function a() public view returns (uint, uint){
        uint count = 0;
        uint i = 0;  // 0.8 已移除 var，需显式声明类型
        
        for (; i < 257; i++) {
            count++;
            if(count >= 260){
                break;
            }
        }
        return (count, i);
    }
    
    
    //i ,  count
}