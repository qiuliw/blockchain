// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/22.修饰器modifier.t.sol" -vv
pragma solidity ^0.8.26;


contract  Test {
    
    uint256 public value ;
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(address caller)  {
        //require(msg.sender == owner);
        require(caller == owner);
        
        //_；代表这个修饰器所修饰函数的代码
        _;
    }


    //使用修饰器，将仅管理员可以执行的限定放到函数外面
    function changeValue(uint256 _value) onlyOwner(msg.sender) public {
        
        //require(msg.sender == owner);
        
        value = _value;
    }

}