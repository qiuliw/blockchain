# Funding.sol 众筹合约

Solidity 0.4.x 众筹合约：投资、投票、花费请求、退款。

## 环境

- Node.js 18+

## 安装与编译

```bash
npm install --ignore-scripts
npm run compile
```

成功输出：

```
OK Funding.sol:Funding
abi items: 18
bytecode length: ...
```

## 合约功能概览

- `invest()` — 投资人参与众筹
- `createRequest()` — 管理员发起花费请求
- `approveRequest()` — 投资人投票
- `finalizeRequest()` — 执行已通过的请求
- `refund()` — 项目失败退款

部署与前端交互见 [funding-eth](../funding-eth/README.md)。
