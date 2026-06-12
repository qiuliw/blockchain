// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/25.事件event.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/25.event.sol";

contract Adv25EventTest is ForgeTest {
    // payable 收款 + event 记录映射
    function testPlay() public {
        Test t = new Test();
        t.paly{value: 100}();
        assertEq(t.getBalance(), 100);
        assertEq(t.personToMoney(address(this)), 100);
    }
}
