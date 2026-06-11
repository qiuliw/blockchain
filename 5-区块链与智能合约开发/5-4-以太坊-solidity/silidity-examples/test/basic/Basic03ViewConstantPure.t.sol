// 测试命令: forge test --match-path "test/basic/Basic03ViewConstantPure.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/03.viewConstantPure.sol";

contract Basic03ViewConstantPureTest is ForgeTest {
    // view 读状态变量 ui+i10
    function testAdd() public {
        Test t = new Test();
        assertEq(t.add(), 110);
    }

    // pure 不碰状态，返回 hello
    function testPureString() public {
        Test t = new Test();
        assert(keccak256(bytes(t.test())) == keccak256("hello"));
    }
}
