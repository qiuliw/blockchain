// 测试命令: forge test --match-path "test/basic/09.bytes.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/09.bytes.sol";

contract BytesTest is ForgeTest {
    // bytes 赋值后 push 扩容
    function testSetAndPush() public {
        Bytes t = new Bytes();
        t.setValue("abc");
        assertEq(t.getLen(), 3);
        t.pushData();
        assertEq(t.getLen(), 4);
    }
}
