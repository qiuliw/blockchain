// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/23.货币单位.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/23.ethUnit.sol";

contract Adv23EthUnitTest is ForgeTest {
    // 1 ether == 10^18 wei
    function testEtherEqualsWei() public {
        EthUnit u = new EthUnit();
        assert(u.f1());
    }

    // 1 ether != 1 wei
    function testOneEtherNotOneWei() public {
        EthUnit u = new EthUnit();
        assert(!u.f4());
    }
}
