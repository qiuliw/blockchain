import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SimpleStorage.sol";

//合约名字要Test开头
contract TestSimpleStorage {

    //测试函数，小写test开头
    function testSet() public {
        //        MetaCoin meta = MetaCoin(DeployedAddresses.MetaCoin());
        SimpleStorage ss = SimpleStorage(DeployedAddresses.SimpleStorage());

        ss.set(1000);

        uint res = ss.get();

        Assert.equal(res, 1000, "res should be 1000");
    }
}
