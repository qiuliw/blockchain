# 5-区块链与智能合约开发

从 `docs/` 课程资料整理的可运行代码。每个可运行目录自带 README，直接进项目看即可。

## 项目索引

| 章节 | 项目 | 文档 |
|------|------|------|
| 5-2 | Go 区块链 CLI | [README](./5-2-Go语言与区块链开发/README.md) |
| 5-3 | HelloFoundry | [README](./5-3-区块链与以太坊/HelloFoundry/README.md) |
| 5-4 | Solidity 示例 + Foundry 测试 | [README](./5-4-以太坊-solidity/silidity-examples/README.md) |
| 5-5 | Node.js 示例 | [README](./5-5-以太坊-nodejs/README.md) |
| 5-6 | web3.js 脚本 | [README](./5-6-以太坊-web3/README.md) |
| 5-7 | 彩票 DApp | [README](./5-7-以太坊-彩票/README.md) |
| 5-8 | 众筹合约 | [contracts/README](./5-8-以太坊-众筹/contracts/README.md) |
| 5-8 | 众筹 DApp | [funding-eth/README](./5-8-以太坊-众筹/funding-eth/README.md) |
| 5-9 | Truffle 入门 | [README](./5-9-以太坊-truffle/truffle-init/README.md) |
| 5-10 | web3.js 框架 | [README](./5-10-web3.js框架/truffle-react-web3/README.md) |
| 5-11 | IPFS 入门 | [truffle-ipfs/README](./5-11-ipfs使用/truffle-ipfs/README.md) |
| 5-11 | 电商拍卖 | [ebay-eth/README](./5-11-ipfs使用/ebay-eth/README.md) |
| 5-11 | 电商完整版 | [ebay-eth-final/README](./5-11-ipfs使用/ebay-eth-final/README.md) |

## 一键安装（可选）

```bash
chmod +x setup.sh && ./setup.sh
```

## 环境

| 工具 | 需要它的项目 |
|------|----------------|
| Node.js 18+ | 5-5 ~ 5-11 |
| Go 1.18+ | 5-2 |
| Foundry | 5-3、5-4（`silidity-examples`） |
| Ganache :7545 | 5-6 ~ 5-11 |
| MetaMask | 5-7 ~ 5-11 前端 |
| IPFS :5001 | 5-11 |

WSL 下 Truffle 编译失败时：`export PATH="/usr/bin:$PATH"`
