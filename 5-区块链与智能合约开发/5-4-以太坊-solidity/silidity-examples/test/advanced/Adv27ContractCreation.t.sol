// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/Adv27ContractCreation.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/27.contractCreation.sol";

contract Adv27ContractCreationTest is ForgeTest {
    // C2 内 new 创建子合约
    function testCreateViaC2() public {
        C2 c = new C2();
        assertEq(c.getValue2(), 20);
    }
}
