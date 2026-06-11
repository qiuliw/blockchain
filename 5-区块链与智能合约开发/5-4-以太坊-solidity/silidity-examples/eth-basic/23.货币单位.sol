// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/Adv23EthUnit.t.sol" -vv
pragma solidity ^0.8.26;

contract EthUnit{
    uint  a = 1 ether;
    uint  b = 10 ** 18 wei;
    uint  c = 1000 * 10 ** 15;  // 1000 finney = 1 ether（0.8 已移除 finney 单位）
    uint  d = 1000000 * 10 ** 12;  // 1000000 szabo = 1 ether（0.8 已移除 szabo 单位）
    
    function f1() view public returns (bool){
        return a == b;
    }
    
    function f2() view public returns (bool){
        return a == c;
    }
    
    function f3() view public returns (bool){
        return a == d;
    }
    
    function f4() pure public returns (bool){
        return 1 ether == 100 wei;
    }
}