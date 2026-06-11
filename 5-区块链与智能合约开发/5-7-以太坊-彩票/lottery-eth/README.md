# 5-7 以太坊彩票

React 前端 + `Lottery.sol` 彩票 DApp。

## 环境

- Node.js 18+
- Ganache（端口 **7545**）
- 浏览器 MetaMask

## 安装

```bash
cd lottery-eth
npm install --ignore-scripts
```

## 运行

```bash
npm run compile:contract   # 编译 Lottery.sol
npm start                  # 前端 http://localhost:3000
```

## 联调

1. 启动 Ganache（7545）
2. MetaMask 导入 Ganache 账户，网络指向 `http://127.0.0.1:7545`
3. 在前端创建/参与彩票

## 目录

```
lottery-eth/
├── contracts/Lottery.sol
├── src/              # React 前端
├── 01-compile.js
└── public/
```
