// 测试命令: forge test --match-path "test/basic/Basic05Address.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/05.address.sol";

contract Basic05AddressTest is ForgeTest {
    // address 转 uint160 后 +10
    function testAdd() public {
        Test t = new Test();
        assert(t.add() == uint160(t.addr1()) + 10);
    }
}
