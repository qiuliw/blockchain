// 测试命令: forge test --match-path "test/basic/Basic08Enum.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/08.enum.sol";

contract Basic08EnumTest is ForgeTest {
    // 枚举 Day 默认值为 6
    function testDefaultDay() public {
        Test t = new Test();
        assertEq(t.getDefaultDay(), 6);
    }
}
