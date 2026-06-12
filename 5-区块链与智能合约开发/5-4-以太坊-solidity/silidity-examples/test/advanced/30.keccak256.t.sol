// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/30.keccak256.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/30.keccak256.sol";

contract Adv30Keccak256Test is ForgeTest {
    // keccak256 哈希结果非零
    function testKeccak() public {
        Test t = new Test();
        bytes32 h = t.test1();
        assert(h != bytes32(0));
    }
}
