# 5-6 以太坊 web3.js

使用 web3.js + solc 编译、部署、交互 `SimpleStorage` 合约。

项目代码在 [`web3-project/`](./web3-project/)。

## 环境

- Node.js 18+
- Ganache（本地链，端口 **7545**）

## 安装

```bash
cd web3-project
npm install --ignore-scripts
```

## 运行

```bash
# 1. 编译（无需链）
npm run compile

# 2. 启动 Ganache，修改 02-deploy.js 中的 account

# 3. 部署，记下合约 address
npm run deploy

# 4. 把 address 填入 03-instance.js
npm run interact
```

## 脚本

| 文件 | 作用 |
|------|------|
| `01-compile.js` | solc 编译 |
| `02-deploy.js` | 部署合约 |
| `03-instance.js` | 获取实例 |
| `04-interaction.js` | 读写数据 |
