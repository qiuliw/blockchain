// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/21.errorHandling.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/21.errorHandling.sol";

contract ErrorHandlingTest is ForgeTest {
    // owner 调用 setValue 成功
    function testSetValueAsOwner() public {
        ErrorHandling t = new ErrorHandling();
        t.setValue(42);
        assertEq(t.a(), 42);
    }
}
