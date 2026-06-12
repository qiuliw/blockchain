// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/29.tuple.t.sol" -vv
pragma solidity ^0.8.26;

contract Tuple {
    
    struct Student {
        string name;
        uint age;
        uint score;
        string sex;
    }
    
    //两种赋值方式
    Student public stu1 = Student("lily", 18, 90, "girl");
    Student public stu2 = Student({name:"Jim", age:20, score:80, sex:"boy"});

    Student[] public Students;
    
    function assign() public {
        Students.push(stu1);
        Students.push(stu2);
        
        stu1.name = "Lily";
    }
    
    //1. 返回一个Student结构
    function getLily() public view returns (string memory, uint, uint, string memory) {
        require(Students.length != 0);
        
        Student memory lily = Students[0];
        
        //使用圆括号包裹的多个类型不一致的数据集合：元组
        return (lily.name, lily.age, lily.score, lily.sex);
    }
}