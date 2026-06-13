# web3-scripts

Foundry 合约 + web3.js 脚本链上交互示例（`SimpleStorage`）。

## 快速开始

```bash
forge install
forge test
forge build

anvil
npm run deploy:local
# 将地址写入 instance.js

npm run interact
```

## 脚本

| 文件 | 作用 |
|------|------|
| `instance.js` | 创建 web3 合约实例 |
| `interaction.js` | 读写演示 |
