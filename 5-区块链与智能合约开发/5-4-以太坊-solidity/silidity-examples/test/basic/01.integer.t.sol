// 测试命令: forge test --match-path "test/basic/01.integer.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/01.integer.sol";

contract IntegerTest is ForgeTest {
    // 整数类型转换后相加，期望 90
    function testAdd() public {
        Integer t = new Integer();
        assertEq(t.add(), 90);
    }

    // uint 与 int 比较，结果不等
    function testIsEqual() public {
        Integer t = new Integer();
        assert(!t.isEqueal());
    }
}
