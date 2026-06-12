// 测试命令: forge test --match-path "test/basic/11.memoryVsStorage.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/11.memoryVsStorage.sol";

contract MemoryVsStorageTest is ForgeTest {
    // storage 引用修改 name 和 num
    function testCall2ChangesName() public {
        MemoryVsStorage t = new MemoryVsStorage();
        t.call2();
        assert(keccak256(bytes(t.name())) == keccak256("Lily"));
        assertEq(t.num(), 30);
    }
}
