// 测试命令: forge test --match-path "test/basic/Basic11MemoryStorage.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/11.memoryVsStorage.sol";

contract Basic11MemoryStorageTest is ForgeTest {
    // storage 引用修改 name 和 num
    function testCall2ChangesName() public {
        Test t = new Test();
        t.call2();
        assert(keccak256(bytes(t.name())) == keccak256("Lily"));
        assertEq(t.num(), 30);
    }
}
