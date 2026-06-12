// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/28.合约间转账.t.sol" -vv
pragma solidity ^0.8.26;

contract InfoFeed {
    
    function info() public payable returns (uint ret) {
        return 42; 
    }
    
    function getBlance() public view returns(uint256) {
        return address(this).balance;
    }
}

contract Consumer {
    
    InfoFeed public feed; //0x0000000000000
    
    function setFeed(address addr) public { 
        feed = InfoFeed(addr);  //0xfeabcdf......
    }
    
    function callFeed() public { 
        //合约间转账语法，
        feed.info{value: 10, gas: 800}(); 
    }
    
    receive() external payable {
        
    }
    
    function getBlance() public view returns(uint256) {
        return address(this).balance;
    }
}