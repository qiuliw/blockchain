// 测试命令: forge test --match-path "test/basic/03.viewConstantPure.t.sol" -vv
pragma solidity ^0.8.26;


// 示例：view / constant / pure
contract ViewConstantPure {
    //状态变量
    //类型不匹配时需要显式转换类型
    //返回值需要使用returns描述
    
    //public/private 可以修饰状态变量
    //状态变量默认是私有的
    uint256 public ui = 100;
    
    int8 private i10 = 10;

    // constant 修饰状态变量：编译期常量，值写入字节码，不占 storage 槽位，部署后不可改
    // 必须在声明时赋值，且只能是编译期可确定的值（字面量、表达式、其他 constant 等）
    uint256 public constant MAX_VALUE = 1000;
    string public constant VERSION = "1.0.0";
    
    
    // 函数修饰符（view / pure / constant）：
    // 1. 不读不写状态变量 → pure（纯自我内部运行，无外部属性交互）
    // 2. 读了但没写 → view（单向视图）
    // 3. 写了 → 不加修饰符
    // 注：constant 曾是 view 的别名（Solidity 0.4），0.5 起已废弃，0.8 请用 view
    
    // 只读 view
    function add() public view returns(uint256) {
        return ui + uint256(int256(i10));
    }
    
    // 不读不写 pure
    function test() public pure returns (string memory) {
        return "hello";
    }

    // 只读 constant 状态变量：值在编译期嵌入字节码，不访问 storage，可用 pure
    function getMax() public pure returns (uint256) {
        return MAX_VALUE;
    }

    // constant + 普通状态变量：读了 ui（storage），需 view
    function getMaxPlusUi() public view returns (uint256) {
        return MAX_VALUE + ui;
    }
    
    // 写（读）
    function setValue(uint256 num) public {
        ui = num;
    }
    
    // 若给此函数加上 view，因修改 ui 会编译报错
    function setValue1(uint256 num) public {
        ui = num;
    }
    
    function isEqueal() public view returns(bool) {
        return ui == uint256(int256(i10));
    }

}
