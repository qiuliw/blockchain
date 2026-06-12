// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/28.contractTransfer.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/28.contractTransfer.sol";

contract Adv28ContractTransferTest is ForgeTest {
    // 跨合约调用返回值 42
    function testInfoFeedReturns42() public {
        InfoFeed feed = new InfoFeed();
        assertEq(feed.info{value: 0}(), 42);
    }

    // 合约间转账后调用 feed
    function testConsumerCanCallFeed() public {
        InfoFeed feed = new InfoFeed();
        Consumer consumer = new Consumer();
        consumer.setFeed(address(feed));
        (bool ok,) = address(consumer).call{value: 100 wei}("");
        require(ok, "fund consumer");
        consumer.callFeed();
        assertEq(feed.getBlance(), 10);
    }
}
