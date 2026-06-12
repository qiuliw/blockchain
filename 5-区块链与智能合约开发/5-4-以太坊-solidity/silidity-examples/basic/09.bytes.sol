// 测试命令: forge test --match-path "test/basic/09.bytes.t.sol" -vv
pragma solidity ^0.8.26;


contract Bytes {

    bytes public name;
    
    function getLen() public view returns(uint256) {
        return name.length;
    }

    //1. 可以不分空间，直接进行字符串赋值，会自动分配空间
    function setValue(bytes memory input) public {
        name = input;
    }
    
    //2. 如果未分配过空间，使用下标访问会访问越界报错
    function getByIndex(uint256 i) public view returns (bytes1) {
        return name[i];
    }
    
    //3. 0.8 中不能直接 name.length = len，用 push/pop 调整 storage bytes 长度
    function setLen(uint256 len) public {
        while (name.length < len) {
            name.push(0);
        }
        while (name.length > len) {
            name.pop();
        }
    }
    
    //4.可以通过下标进行数据修改
    function setValue2(uint256 i) public {
        name[i] = "h";
    } 
    
    //5. 支持push操作，在bytes最后面追加元素
    function pushData() public {
        name.push('h');
    }
    
}