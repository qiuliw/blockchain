# funding-eth 众筹 DApp

React + web3.js 众筹前端，对接 Foundry 版 `FundingFactory.sol`。

## 环境

- Node.js 18+（前端）
- [Foundry](https://book.getfoundry.sh/)
- Anvil :8545
- 浏览器 MetaMask

## 合约（Solidity 0.8.26）

```bash
cd funding-eth
forge install

forge test
forge build

anvil
forge script script/DeployFundingFactory.s.sol:DeployFundingFactory \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

或使用 npm 快捷命令：

```bash
npm run test:contract
npm run deploy:local
```

## 前端

```bash
npm install --ignore-scripts
npm start
```

浏览器打开 http://localhost:3000。部署后把工厂合约地址写入 `src/eth/instance.js`。

## 目录

```
funding-eth/
├── src/FundingFactory.sol   # 合约源码
├── test/FundingFactory.t.sol
├── script/
├── src/                     # React 页面与 web3 调用
├── demo/
└── public/
```
