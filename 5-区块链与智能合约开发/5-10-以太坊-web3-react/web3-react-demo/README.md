# web3-react-demo

Truffle 合约 + web3.js API 演示 + React 前端。

## 环境

- Node.js 18+
- Ganache（端口 **7545**，前端和 demo 脚本需要）

## 安装

```bash
# 根目录（Truffle + web3 demo）
npm install --ignore-scripts

# React 前端
npm run client:install
# 或：cd client && npm install --ignore-scripts
```

## 运行

```bash
# 1. 编译合约（产物输出到 client/src/contracts/）
npm run compile

# 2. web3 API 演示脚本（需 Ganache）
node client/web3TestDemo/01-eth相关.js
node client/web3TestDemo/02-bignumber.js
# ... 共 7 个 demo 文件

# 3. 启动 React 前端
npm run client:install   # 首次：安装 client 依赖
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
| `07-sha3.js` | 哈希 |

## WSL 提示

```bash
export PATH="/usr/bin:$PATH"
npm run compile
```
