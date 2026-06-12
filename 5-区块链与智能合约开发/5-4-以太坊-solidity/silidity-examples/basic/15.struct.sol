// 测试命令: forge test --match-path "test/basic/15.struct.t.sol" -vv
pragma solidity ^0.8.26;
//pragma experimental ABIEncoderV2;

contract Struct {
    //定义结构之后无分号，与枚举一致
    struct Student {
        string name;
        uint age;
        uint score;
        string sex;
    }

    Student[] public Students; // 状态属性长度可变
        
    //两种赋值方式
    Student public stu1 = Student("lily", 18, 90, "girl"); // 按顺序
    Student public stu2 = Student({name:"Jim", age:20, score:80, sex:"boy"}); // 不按照顺序，但注明赋值属性
    
    function assign() public {
        Students.push(stu1);
        Students.push(stu2);
        
        stu1.name = "Lily";
    }
    
    // function returnStudent() public view returns(Student) {
    //     return stu1;
    // }
    
    //使用圆括号包裹起来的类型叫做元组“tuple”
    //特性：1.  不可修改，2.可以容纳不同类型的数据
    function returnStudent() public view returns (string memory, uint, uint, string memory) {
        return (stu1.name, stu1.age, stu1.score, stu1.sex);
    }
}