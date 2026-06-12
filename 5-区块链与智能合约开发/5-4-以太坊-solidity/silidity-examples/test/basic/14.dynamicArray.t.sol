// 测试命令: forge test --match-path "test/basic/14.dynamicArray.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/14.dynamicArray.sol";

contract Basic14DynamicArrayTest is ForgeTest {
    // 动态数组 push 后长度 11
    function testPush() public {
        Test t = new Test();
        t.pushData(11);
        assertEq(t.getNumbers().length, 11);
    }
}
