// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/Adv30Keccak256.t.sol" -vv
pragma solidity ^0.8.26;


contract Test {
    
    function test() public pure returns(bytes32){
        bytes memory v1 = abi.encodePacked("hello", "b", uint256(1), "hello");
        return keccak256(v1);
    }
    
    
    
    function test1() public pure returns(bytes32) {
        //bytes32 hash = sha3("hello", 1, "world", 2);
        //bytes32 hash = keccak256("hello", "b",  uint256(1), "hello");
        
        //return hash;
        return keccak256(abi.encodePacked("hello", "world"));  // 0.8 中 keccak256 只接受单个 bytes 参数
    }
}