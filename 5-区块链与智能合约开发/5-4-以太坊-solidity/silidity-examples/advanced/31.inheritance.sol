// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/31.inheritance.t.sol" -vv
pragma solidity ^0.8.26;

// 继承 ==> 虚函数 ==> 重写
contract Base1{
  function data() public pure virtual returns(uint){
    return 1;
  }
}

contract Base2{
  function data() public pure virtual returns(uint){
    return 2;
  }
}


// 1. 使用is关键字进行继承，
// 2. 多个继承间使用逗号分隔，
// 3. 如果两个父合约含有相同方法，C3 线性化下右端父合约优先（0.8 需显式 override）

contract son1 is Base1, Base2{
    function data() public pure override(Base2, Base1) returns(uint) {
        return Base2.data();
    }
}

contract son2 is Base2, Base1{
    function data() public pure override(Base1, Base2) returns(uint) {
        return Base1.data();
    }
}

//4. 可以指定父合约，调用特定的方法
contract son3 is Base1, Base2{
    function data() public pure override(Base2, Base1) returns(uint) {
        return Base2.data();
    }
    function mydata() public pure returns(uint){
        return Base1.data();
    }
}
contract son4 is Base2, Base1{
    function data() public pure override(Base1, Base2) returns(uint) {
        return Base1.data();
    }
    function mydata() public pure returns(uint){
        return Base2.data();
    }
}



