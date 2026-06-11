// 测试命令: forge test --match-path "test/basic/Basic10String.t.sol" -vv
pragma solidity ^0.8.26;


contract  Test {

    string public name = "lily";   
    
    
    function setName() public {
        bytes(name)[0] = "L";   
    }
    
    function getLength() public view returns(uint256) {
        return bytes(name).length;
    }
    
    function setLength(uint256 i) public {
        bytes storage b = bytes(name);
        while (b.length < i) {
            b.push(0);
        }
        while (b.length > i) {
            b.pop();
        }
        b[i - 1] = "H";
    } 
}