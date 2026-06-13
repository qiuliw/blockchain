# ebay-eth-final 电商拍卖完整版

day12 完整版：在 ebay-eth 基础上增加 IPFS 图片/描述上传。

## 环境

- Node.js 18+
- [Foundry](https://book.getfoundry.sh/)
- Anvil（本地链，默认 :8545）
- MetaMask
- IPFS daemon（5001，上传商品图片时需要）

## 环境配置

```bash
cp .env.example .env
# 部署后把合约地址写入 .env 的 CONTRACT_ADDRESS
```

| 变量 | 说明 |
|------|------|
| `RPC_URL` | Anvil RPC，默认 `http://127.0.0.1:8545` |
| `DEPLOYER_ADDRESS` | 部署账户，默认 Anvil 第一个账户 |
| `CONTRACT_ADDRESS` | `forge script` 部署后的合约地址 |
| `IPFS_*` | IPFS API 与网关地址 |

## 合约（Solidity 0.8.26）

```bash
cd ebay-eth-final
forge install foundry-rs/forge-std

forge test
npm run build:contract

anvil
npm run deploy:local
```

## 前端

```bash
npm install --ignore-scripts
npm run dev
```

浏览器打开 webpack-dev-server 提示的地址（通常 http://localhost:8080）。

## 与 ebay-eth 的区别

- 前端 `app/scripts/index.js` 集成 `ipfs-api` 上传
- 商品 `imageLink` / `descLink` 存 IPFS 哈希

## IPFS

```bash
ipfs daemon   # 端口 5001
```

## 目录

```
ebay-eth-final/
├── src/EcommerceStore.sol
├── test/EcommerceStore.t.sol
├── script/
├── app/eth/abi.json      # build:contract 生成
├── app/                  # 前端入口
└── webpack.config.js
```

## WSL 提示

若 webpack 报 OpenSSL 错误，脚本已内置 `NODE_OPTIONS=--openssl-legacy-provider`。
