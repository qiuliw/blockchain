# web3-scripts

Foundry 合约 + web3.js 脚本链上交互示例（`SimpleStorage`）。

## 快速开始

```bash
forge install
forge test
npm run build:contract

anvil
npm run deploy:local
# 将地址写入 config.js

npm run interact
```

## 配置

- `config.js` — RPC、合约地址、默认账户
- `abi/SimpleStorage.json` — 由 `npm run build:contract` 生成

## 脚本

| 文件 | 作用 |
|------|------|
| `scripts/sync-abi.js` | 同步 Foundry 编译 ABI |
| `03-instance.js` | 创建 web3 合约实例 |
| `04-interaction.js` | 读写演示 |
