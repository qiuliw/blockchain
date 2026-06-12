// 测试命令: forge test --match-path "test/basic/03.viewConstantPure.t.sol" -vv
pragma solidity ^0.8.26;


contract ViewConstantPure {
    //状态变量
    //类型不匹配时需要显式转换类型
    //返回值需要使用returns描述
    
    
    
    //public/private 可以修饰状态变量
    //状态变量默认是私有的
    uint256 public ui = 100;
    
    int8 private i10 = 10;
    
    
    // 1. 如果函数中没有用到状态变量：（既没有读也没有写），就修饰为pure
    // 2. 如果读了，但是没写，修饰为 view
    // 3. 如果写了，那么不修饰即可
    
    function add() public view returns(uint256) {
        return ui + uint256(int256(i10));
    }
    
    function test() public pure returns (string memory) {
        return "hello";
    }
    
    function setValue(uint256 num) public {
        ui = num;
    }
    
    // 若给此函数加上 view，因修改 ui 会编译报错
    function setValue1(uint256 num) public {
        ui = num;
    }
    
    function isEqueal() public view returns(bool) {
        return ui == uint256(int256(i10));
    }
    
    
    

}