// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/24.时间单位.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/24.timeUnit.sol";

contract Adv24TimeUnitTest is ForgeTest {
    // minutes 时间单位换算
    function testMinutes() public {
        TimeUnit u = new TimeUnit();
        assert(u.f2());
        assert(u.f4());
    }
}
