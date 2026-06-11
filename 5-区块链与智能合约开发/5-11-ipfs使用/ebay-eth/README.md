# ebay-eth 电商拍卖 DApp

基于 `EcommerceStore.sol` 的 Webpack + React 电商拍卖前端（day11）。

## 环境

- Node.js 18+
- Ganache（7545）
- MetaMask

## 安装

```bash
npm install --ignore-scripts
```

## 运行

```bash
# 编译合约
npm run compile

# 启动 Webpack 开发服务器
npm run dev
```

浏览器按 webpack-dev-server 提示的地址打开（通常 http://localhost:8080）。

## 合约

- `contracts/EcommerceStore.sol` — 商品上架、拍卖、Reveal、Finalize

## 目录

```
ebay-eth/
├── contracts/
├── app/              # 前端入口（index.html + scripts/）
├── migrations/
├── webpack.config.js
└── build/            # 编译/打包产物
```

## WSL 提示

```bash
export PATH="/usr/bin:$PATH"
npm run compile
```

若 webpack 报 OpenSSL 错误，脚本已内置 `NODE_OPTIONS=--openssl-legacy-provider`。
