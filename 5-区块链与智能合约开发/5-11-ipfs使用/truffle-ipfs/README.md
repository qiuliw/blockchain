# truffle-ipfs

Truffle 合约 + IPFS API 测试 + React 前端。

## 环境

- Node.js 18+
- Ganache（7545，前端需要）
- IPFS daemon（5001，IPFS 测试需要）

## 安装

```bash
npm install --ignore-scripts
npm run client:install
```

## 运行

```bash
# 编译合约
npm run compile

# IPFS API 测试（需先 ipfs daemon）
npm run ipfs:test

# React 前端
npm run client:install   # 首次
npm run client:start     # http://localhost:3000
```

## IPFS 启动

```bash
# 另开终端
ipfs daemon
# API: http://127.0.0.1:5001
```

## 目录

```
truffle-ipfs/
├── contracts/SimpleStorage.sol
├── client/                  # React 前端
│   ├── 01-ipfs-api-test.js  # IPFS 独立测试
│   └── src/
├── migrations/
└── truffle-config.js
```

## WSL 提示

```bash
export PATH="/usr/bin:$PATH"
npm run compile
```
