// 测试命令: forge test --match-path "test/basic/Basic10String.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../smartContracts/10.string.sol";

contract Basic10StringTest is ForgeTest {
    // string 初始值 lily，长度 4
    function testInitialName() public {
        Test t = new Test();
        assert(keccak256(bytes(t.name())) == keccak256("lily"));
        assertEq(t.getLength(), 4);
    }
}
