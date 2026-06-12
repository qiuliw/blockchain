// 测试命令: forge test --match-path "test/basic/02.publicPrivate.t.sol" -vv
pragma solidity ^0.8.26;


contract PublicPrivate {
    //状态变量
    //类型不匹配时需要显式转换类型
    //返回值需要使用returns描述
    
    
    
    //public/private 可以修饰状态变量
    //状态变量默认是私有的
    uint256 public ui256 = 100;
    
    int8 private i10 = 10;
    
    
    //private 修饰的函数为私有的，只有合约内部可以调用
    function add() private view returns(uint256) {
        return ui256 + uint256(int256(i10));
    }
    
    //Public修饰的函数为共有的，合约内外都可以调用
    function isEqueal() public view returns(bool) {
        // 100 != 10，返回 false（public 可外部调用，与 private 无关）
        return ui256 == uint256(int256(i10));
    }
    
    function Add() public view returns(uint256){
        return add();
    }
}