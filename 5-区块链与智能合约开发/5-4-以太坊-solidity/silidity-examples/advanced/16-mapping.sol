// 测试命令: 无对应 Foundry 测试（课件演示，可用 FOUNDRY_PROFILE=advanced forge build 编译检查）
pragma solidity ^0.8.26;


contract Mapping {
    //id -> name
    mapping(uint => string) public id_names;
    
    
    
    //构造函数：
    //1. 对象在创建的时候，自动执行的函数，完成对象的初始化工作
    //2. 构造函数仅执行一次
    
    // function Mapping() public {
        
    // }

    constructor() {
        id_names[1] = "lily";
        id_names[2] = "Jim";
        id_names[3] = "Lily";
        id_names[3] = "Tom";
    }
    
    function getNameById(uint id)  public returns (string memory){
        //加上storage如何赋值？
        string memory name = id_names[id];
        return name;
    }
    
    function setNameById(uint id) public {
        id_names[id] = "Hello";
    }
    
    
    // function getMapLength() public returns (uint){
    //     return id_names.length;
    // }
    
}