# 5-4 以太坊 Solidity

Solidity **0.8.26** 语法示例 + **Foundry / forge-std** 单元测试。

| 目录 | 内容 |
|------|------|
| `basic/` | 基础语法（16 个示例） |
| `advanced/` | 进阶语法（继承、事件、modifier 等） |
| `test/basic/` | 基础示例 Foundry 测试 |
| `test/advanced/` | 进阶示例 Foundry 测试 |
| `lib/forge-std/` | Foundry 标准库（`forge install` 安装） |

## 环境

- [Foundry](https://book.getfoundry.sh/getting-started/installation)（`forge` 命令）

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup

cd 5-4-以太坊-solidity/silidity-examples
forge install   # 若 lib/forge-std 缺失
```

编译器版本在 `foundry.toml` 中固定为 **solc 0.8.26**。

## 运行测试

```bash
cd 5-4-以太坊-solidity/silidity-examples

# 基础示例（20 个测试）
forge test

# 进阶示例（22 个测试）
FOUNDRY_PROFILE=advanced forge test

# 跑单个文件
forge test --match-path "test/basic/Basic01Integer.t.sol" -vv

# 只看某个测试
forge test --match-test testAdd -vvv
```

## 仅编译

```bash
FOUNDRY_PROFILE=default forge build    # basic/
FOUNDRY_PROFILE=advanced forge build   # advanced/
```

## 目录与测试对应

| 示例文件 | 测试文件 |
|----------|----------|
| `basic/01.integer.sol` | `test/basic/Basic01Integer.t.sol` |
| `basic/16-mapping.sol` | `test/basic/Basic16Mapping.t.sol` |
| `advanced/22.修饰器modifier.sol` | `test/advanced/Adv22Modifier.t.sol` |
| `advanced/33.HTCoinERC20.sol` | `test/advanced/Adv33HTCoin.t.sol` |
| … | 其余文件同理 |

含中文文件名的示例提供了 **ASCII 符号链接**（如 `02.publicPrivate.sol`），供测试 `import` 使用。

## IDE 语法检查

若报 `Source file requires different compiler version`：

1. 重新打开 `advanced/00.template.sol`
2. 确认首行为 `pragma solidity ^0.8.26;`
3. 重载窗口（`Developer: Reload Window`）

推荐 [Solidity by Nomic Foundation](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity)，会读取本目录 `foundry.toml`。

## 说明

- 合约与测试均使用 **Solidity ^0.8.26**
- `advanced/17.不要使用var.sol`、`20.全局变量.sol` 等仅作语法演示，无对应测试
- 测试在本地 EVM 中验证函数返回值与状态变化
