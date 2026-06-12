# ebay-eth 电商拍卖 DApp

基于 `EcommerceStore.sol` 的 Webpack + React 电商拍卖前端。

## 环境

- Node.js 18+
- [Foundry](https://book.getfoundry.sh/)
- Anvil :8545
- MetaMask

## 合约（Solidity 0.8.26）

```bash
cd ebay-eth
forge install

forge test
npm run build:contract    # forge build + 同步 ABI 到 abi/

anvil
npm run deploy:local
# 将部署地址写入 app/contracts-config.js 的 contractAddress
```

## 前端

```bash
npm install --ignore-scripts
npm run dev
```

浏览器打开 webpack-dev-server 提示的地址（通常 http://localhost:8080）。

## 合约

- `src/EcommerceStore.sol` — 商品上架、拍卖、Reveal、Finalize、Escrow

## 目录

```
ebay-eth/
├── src/EcommerceStore.sol
├── test/EcommerceStore.t.sol
├── script/
├── abi/                  # sync-abi 生成，供前端引用
├── app/                  # 前端入口
└── webpack.config.js
```

## WSL 提示

若 webpack 报 OpenSSL 错误，脚本已内置 `NODE_OPTIONS=--openssl-legacy-provider`。
