# ebay-eth-final 电商拍卖完整版

day12 完整版：在 ebay-eth 基础上增加 IPFS 图片/描述上传。

## 环境

- Node.js 18+
- Ganache（7545）
- MetaMask
- IPFS daemon（5001，上传商品图片时需要）

## 安装

依赖与 `ebay-eth` 相同。若安装失败，可从 ebay-eth 复制 node_modules：

```bash
# 在 5-11-ipfs使用/ 目录下
cp -a ebay-eth/node_modules ebay-eth-final/node_modules
```

或：

```bash
npm install --ignore-scripts
```

## 运行

```bash
npm run compile
npm run dev
```

## 与 ebay-eth 的区别

- 前端 `app/scripts/index.js` 集成 `ipfs-api` 上传
- 商品 `imageLink` / `descLink` 存 IPFS 哈希

## IPFS

```bash
ipfs daemon   # 端口 5001
```

## WSL 提示

```bash
export PATH="/usr/bin:$PATH"
npm run compile
```
