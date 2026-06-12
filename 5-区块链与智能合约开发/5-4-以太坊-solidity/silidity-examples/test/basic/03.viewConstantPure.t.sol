// 测试命令: forge test --match-path "test/basic/03.viewConstantPure.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/03.viewConstantPure.sol";

// 测试：view / constant / pure
contract ViewConstantPureTest is ForgeTest {
    // view 读状态变量 ui+i10
    function testAdd() public {
        ViewConstantPure t = new ViewConstantPure();
        assertEq(t.add(), 110);
    }

    // pure 不碰状态，返回 hello
    function testPureString() public {
        ViewConstantPure t = new ViewConstantPure();
        assert(keccak256(bytes(t.test())) == keccak256("hello"));
    }

    // constant 状态变量，getMax 为 pure
    function testConstantMax() public {
        ViewConstantPure t = new ViewConstantPure();
        assertEq(t.getMax(), 1000);
        assertEq(t.MAX_VALUE(), 1000);
    }

    // constant + ui，getMaxPlusUi 为 view
    function testConstantPlusUi() public {
        ViewConstantPure t = new ViewConstantPure();
        assertEq(t.getMaxPlusUi(), 1100);
    }
}
