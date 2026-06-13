# 5-7 以太坊彩票

React 前端 + Foundry 彩票合约 DApp。

## 环境

- Node.js 18+（前端）
- [Foundry](https://book.getfoundry.sh/)（合约编译 / 测试 / 部署）
- Anvil :8545（链上联调）
- 浏览器 MetaMask

## 合约（Solidity 0.8.26）

```bash
cd lottery-eth
forge install   # 首次需安装 lib/forge-std

forge test
forge build

# 本地 Anvil 部署
anvil
forge script script/DeployLottery.s.sol:DeployLottery \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

或使用 npm 快捷命令（需先启动 Anvil）：

```bash
npm run test:contract
npm run deploy:local
```

## 前端

```bash
npm install --ignore-scripts
npm start                  # http://localhost:3000
```

部署后把合约地址写入 `src/eth/lotteryInstance.js`。

## 联调

1. 启动 Anvil（8545）
2. MetaMask 导入测试账户，网络指向 `http://127.0.0.1:8545`
3. 部署合约并更新前端地址
4. 在前端参与彩票 / 开奖

## 目录

```
lottery-eth/
├── src/Lottery.sol       # 合约源码
├── test/Lottery.t.sol    # Foundry 测试
├── script/               # 部署脚本
├── src/                  # React 前端（与合约 src 同名，注意区分路径）
└── public/
```
