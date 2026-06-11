// 测试命令: forge test --match-path "test/basic/Basic07FixedBytes.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/07.fixedBytes.sol";

contract Basic07FixedBytesTest is ForgeTest {
    // bytes1[5] 索引 0 取字符 h
    function testGetValue() public {
        Test t = new Test();
        assertEq(t.getValue(0), "h");
    }
}
