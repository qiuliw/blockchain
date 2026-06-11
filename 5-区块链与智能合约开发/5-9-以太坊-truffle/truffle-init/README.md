# 5-9 以太坊 Truffle

Truffle 5 + Solidity 0.4.25 入门项目（SimpleStorage）。

## 环境

- Node.js 18+
- Ganache（部署时，端口 **7545**）

## 安装

```bash
cd truffle-init
npm install --ignore-scripts
```

## 运行

```bash
npm run compile     # 编译合约
npm run migrate     # 部署（需 Ganache）
npm run test        # 运行测试
```

## 合约

- `contracts/Migrations.sol` — 迁移记录
- `contracts/SimpleStorage.sol` — 存取整数示例

## WSL 提示

```bash
export PATH="/usr/bin:$PATH"
npm run compile
```

## 目录

```
truffle-init/
├── contracts/
├── migrations/
├── test/
└── build/contracts/
```
