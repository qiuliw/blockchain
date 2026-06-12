pragma solidity ^0.8.26;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SimpleStorage.sol";

//合约名字要Test开头
contract TestSimpleStorage {
    //测试函数，小写test开头
    function testSet() public {
        SimpleStorage ss = SimpleStorage(DeployedAddresses.SimpleStorage());

        ss.set(1000);

        uint256 res = ss.get();

        Assert.equal(res, 1000, "res should be 1000");
    }
}
