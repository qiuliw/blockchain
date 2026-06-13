# ipfs-demo

Foundry 合约 + IPFS API 测试 + React 前端。

## 环境

- Node.js 18+
- [Foundry](https://book.getfoundry.sh/)
- Anvil :8545
- IPFS daemon（5001，IPFS 测试需要）

## 安装

```bash
npm install --ignore-scripts
npm run client:install
```

## 运行

```bash
forge install
forge test
forge build

anvil
npm run deploy:local
# 将地址写入 client/src/eth/instance.js 的 storageAddress

# IPFS API 测试（需先 ipfs daemon）
npm run ipfs:test

# React 前端
npm run client:start     # http://localhost:3000
```

## IPFS 启动

```bash
ipfs daemon
# API: http://127.0.0.1:5001
```

## 目录

```
ipfs-demo/
├── src/SimpleStorage.sol
├── client/                  # React 前端
│   ├── 01-ipfs-api-test.js  # IPFS 独立测试
│   └── src/
├── script/
└── foundry.toml
```
