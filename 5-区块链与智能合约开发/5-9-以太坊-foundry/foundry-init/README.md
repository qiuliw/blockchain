# foundry-init

Foundry + Solidity **0.8.26** 入门项目（SimpleStorage）。

## 环境

- [Foundry](https://book.getfoundry.sh/)
- Anvil（端口 **8545**）

## 运行

```bash
cd foundry-init
forge install
forge test
forge build

anvil
forge script script/DeploySimpleStorage.s.sol:DeploySimpleStorage --rpc-url http://127.0.0.1:8545 --broadcast
```

## 合约

- `src/SimpleStorage.sol` — 存取整数示例

## 目录

```
foundry-init/
├── src/
├── test/
├── script/
└── foundry.toml
```
