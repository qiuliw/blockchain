// 测试命令: forge test --match-path "test/basic/01.integer.t.sol" -vv
pragma solidity ^0.8.26;


contract  Test {
    //状态变量

    //类型不匹配时需要显式转换类型

    //返回值需要使用returns描述
    
    uint256 ui256 = 100;
    
    int8 i10 = -10;
    
    function add() public view returns(uint256) {
        // 先转有符号运算，再转回 uint256
        return uint256(int256(ui256) + int256(i10));
    }
    
    function isEqueal() public view returns(bool) {
        // 100 != uint256(-10)，返回 false
        return ui256 == uint256(int256(i10));
    }
}