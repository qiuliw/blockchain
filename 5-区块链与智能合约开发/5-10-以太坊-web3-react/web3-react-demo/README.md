# web3-react-demo

Foundry 合约 + web3.js 4.x API 演示 + React 前端。

## 环境

- Node.js 18+
- [Foundry](https://book.getfoundry.sh/)
- Anvil :8545

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

# web3 API 演示脚本（需 Anvil）
node client/web3TestDemo/01-eth相关.js
node client/web3TestDemo/02-bignumber.js
# ... 共 7 个 demo 文件

npm run client:start     # http://localhost:3000
```

## web3 演示脚本

| 文件 | 内容 |
|------|------|
| `01-eth相关.js` | 连接节点、获取账户 |
| `02-bignumber.js` | 大数运算 |
| `03-bignumber加减乘除.js` | 大数四则运算 |
| `04-utils单位转换.js` | wei ↔ ether |
| `05-utils转成16进制.js` | 十六进制转换 |
| `06-fromAscii.js` | 字符串编码 |
| `07-sha3.js` | 哈希（keccak256） |
