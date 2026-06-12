// 测试命令: forge test --match-path "test/basic/04.payable.t.sol" -vv
pragma solidity ^0.8.26;


contract Payable {
    
    string public str ;
    
    // 修饰为payable的函数才可以接收转账，转入合约
    // 不指定payable无法接收

    // string memory src 类型 存储位置 参数名
    // 引用类型（string、bytes、数组、结构体等）作为函数参数时，必须标明数据放在哪
    // • memory：临时内存，函数结束后释放，适合函数内部读写、传参
    // • calldata：只读，来自外部调用的 calldata，更省 gas（常用于 external 函数参数）
    // 状态变量上的 string 不用写 memory/storage，因为它们默认在 storage（链上持久存储）。

    // 可见性（public/private/internal/external）和数据位置（storage/memory/calldata）
    // 是两个独立维度：
    //
    // 1. 可见性决定谁能调用函数。
    // 2. 数据位置决定数据存放在哪里。
    //
    // 编译器会结合函数可见性、参数类型以及是否需要内部调用，
    // 选择允许的数据位置组合，并影响参数传递方式和 Gas 消耗。
    //
    // 一般来说：
    // external + calldata  => 避免参数拷贝，Gas 更低
    // public/internal + memory => 通常需要拷贝参数，Gas 更高
    //
    // 因此可见性不直接决定存储位置，但会间接影响数据位置的选择和 Gas 成本。
    function test1(string memory src) public payable {
        str = src;
    }
    
    function test2(string memory src) public {
        str = src;
    }
    
    function getbalance() public view returns(uint256) {
        //this代表当前合约本身
        //balance方法，获取当前合约的余额
        return address(this).balance;
    }
}