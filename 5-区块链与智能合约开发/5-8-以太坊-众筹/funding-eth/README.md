# funding-eth 众筹 DApp

React + web3.js 众筹前端，对接 `Funding.sol`。

## 环境

- Node.js 18+
- Ganache（端口 **7545**）
- 浏览器 MetaMask

## 安装

```bash
npm install --ignore-scripts
```

## 运行

```bash
npm start
```

浏览器打开 http://localhost:3000

## 联调准备

1. 启动 Ganache（7545）
2. MetaMask 连接本地链，导入 Ganache 账户
3. 在前端创建众筹项目、投资、发起/投票花费请求

## 目录

```
funding-eth/
├── contracts/     # 合约 ABI 等
├── src/           # React 页面与 web3 调用
├── demo/          # 演示数据
└── public/
```
