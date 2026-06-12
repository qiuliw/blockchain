// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/21.errorHandling.t.sol" -vv
pragma solidity ^0.8.26;


contract ErrorHandling {

    address public owner;
    uint256 public a;
    
    constructor() {
        //在部署合约的时候，设置一个全局唯一的合约所有者，后面可以使用权限控制
        owner = msg.sender;
    }
    
    //限定只有管理员owner才能够修改a的值
    function setValue(uint256 input) public {
        
        // if (msg.sender != owner) {
        //     revert();
        // }
        
        //Require（）要求里面的返回值是true，true继续执行，false抛出异常返回
        //require(msg.sender == owner, "exception 1111");
        
        //assert(msg.sender == owner);
        
        if (msg.sender != owner) {
            revert();
        }
        //revert();
        
        a = input;
    }
}