// 测试命令: forge test --match-path "test/basic/02.publicPrivate.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/02.publicPrivate.sol";

contract Basic02PublicPrivateTest is ForgeTest {
    // public 函数外部可调用，100+10=110
    function testAdd() public {
        Test t = new Test();
        assertEq(t.Add(), 110);
    }

    // public isEqueal()：100 != 10，返回 false
    function testIsEqual() public {
        Test t = new Test();
        assert(!t.isEqueal());
    }
    
}
