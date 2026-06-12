// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/24.时间单位.t.sol" -vv
pragma solidity ^0.8.26;

contract TimeUnit{

    function f1() pure public returns (bool) {
        return 1 == 1 seconds;
    }
    
    function f2() pure public returns (bool) {
        return 1 minutes == 60 seconds;
    }
    
    function f3() pure public returns (bool) {
        return 1 hours == 60 minutes;
    }
    
    function f4() pure public returns (bool) {
        return 1 days == 24 hours;
    }
    
    function f5() pure public returns (bool) {
        return 1 weeks == 7 days;
    }
    
    function f6() pure public returns (bool) {
        return 365 days == 365 days;  // 0.8 已移除 years（闰年不确定）
    }
}