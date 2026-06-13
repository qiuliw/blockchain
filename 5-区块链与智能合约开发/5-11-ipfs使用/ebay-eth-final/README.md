# ebay-eth-final 电商拍卖完整版

day12 完整版：在 ebay-eth 基础上增加 IPFS 图片/描述上传。

## 环境

- Node.js 18+
- [Foundry](https://book.getfoundry.sh/)
- Anvil（本地链，默认 :8545）
- MetaMask
- IPFS daemon（5001，上传商品图片时需要）

## 合约（Solidity 0.8.26）

```bash
cd ebay-eth-final
forge install foundry-rs/forge-std

forge test
npm run build:contract    # forge build + 生成 app/eth/abi.json

anvil
npm run deploy:local
# 将部署地址写入 app/scripts/index.js 的 storeAddress
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
