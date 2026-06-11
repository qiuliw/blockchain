# 以太坊开发入门全指南

以太坊开发是**基于以太坊区块链构建去中心化应用（DApp）**的技术体系，核心是用智能合约实现链上逻辑，搭配前端/后端完成链上交互，是当前Web3开发的核心方向。本文整合行业主流三大开发工具（Remix、Hardhat、Foundry），从核心概念、技术栈、开发框架对比、实操案例、环境搭建、学习路线等维度，提供一套完整、可落地的零基础入门教程。

## 本项目目录结构

```
HelloFoundry/
├── .github/                # GitHub Actions 工作流配置
│   └── workflows/
│       └── test.yml        # 自动化测试 CI 配置
├── .gitignore              # Git 忽略文件
├── .gitmodules             # 子模块配置，管理 forge-std 库
├── foundry.toml            # Foundry 项目配置
├── foundry.lock            # Foundry 依赖锁定文件
├── src/                    # 合约源码目录
│   └── Counter.sol         # 计数器合约
├── test/                   # Foundry 测试目录
│   └── Counter.t.sol       # 合约单元测试
├── script/                 # Foundry 脚本目录
│   └── Counter.s.sol       # 部署/交互脚本示例
├── broadcast/              # forge 脚本广播结果目录
│   └── Counter.s.sol/
├── cache/                  # forge 缓存文件目录
│   └── Counter.s.sol/
├── lib/                    # 依赖库目录
│   └── forge-std/          # Foundry 标准库
├── out/                    # 编译输出目录
│   └── ... compiled outputs ...
└── README.md               # 本项目说明文档
```

## 一、核心基础概念（必须掌握）

掌握基础概念是以太坊开发的前提，所有开发操作均围绕以下核心定义展开：

1. **以太坊**：开源去中心化公链，原生支持智能合约，是全球生态最完善、应用最广泛的DApp开发底层平台。

2. **智能合约**：部署并自动运行在以太坊链上的代码程序，由Solidity编写，具备不可篡改、自动执行、无需第三方干预的特性，是所有链上业务的核心载体。

3. **DApp（去中心化应用）**：区别于传统中心化应用，架构为**链上智能合约（后端逻辑）+ Web前端（用户交互）**，数据公开透明、权限去中心化。

4. **加密钱包**：以MetaMask为核心工具，用于管理以太坊账户、签名交易、授权DApp链上交互，是用户连接区块链的唯一入口。

仅提供**可视化交互中间件**能力：所有私钥/助记词等敏感凭证完全由用户本地持有、自主保管，钱包不触碰也不托管用户密钥。

5. **Gas费**：以太坊网络的交易手续费，用于奖励节点矿工，所有链上写入、修改数据的操作均需消耗ETH支付Gas，只读查询操作免费。

6. **开发网络分类**

主网（Mainnet）：正式生产网络，使用真实ETH，产生真实手续费，用于项目正式上线。

测试网（Sepolia/Holesky）：官方免费测试网络，可领取测试ETH，无真实资产风险，用于项目测试验证。

本地网络（Remix VM/Hardhat/Anvil）：离线本地模拟网络，无需联网、无手续费，用于本地开发调试。

## 二、以太坊开发必备技术栈

### 1. 核心编程语言

- **Solidity**：以太坊智能合约专属开发语言，语法接近JavaScript/Java，是链上逻辑开发的核心必备语言。

- **JavaScript/TypeScript**：用于DApp前端开发、链上交互脚本编写、Hardhat自动化测试与部署。

### 2. 三大主流开发框架（全覆盖）

以太坊开发框架分为新手在线框架、全栈JS框架、高性能合约框架，适配不同开发场景：

- **Remix IDE**：在线轻量化开发工具，零环境配置，新手入门首选，适合快速编写、编译、测试简单合约。

- **Hardhat**：Node.js生态主流全栈开发框架，社区生态最丰富、调试友好，适配DApp全栈开发，适合新手进阶、商业级DApp落地。

- **Foundry**：Paradigm推出的高性能Rust底层框架，Solidity原生测试、速度极致、内置安全测试，是DeFi开发、合约审计、专业协议开发的行业标配。

- **Truffle**：老牌传统开发框架，功能完整，目前市场使用率逐步降低。

### 3. 链上交互工具库

- **Ethers.js（推荐）**：轻量、高效、API简洁，主流DApp链上交互标准库，用于钱包连接、合约调用、交易签名。

- **Web3.js**：传统交互库，生态成熟，目前逐步被Ethers.js替代。

### 4. 必备辅助工具

- 钱包工具：MetaMask（Chrome插件，通用链上交互钱包）

- 浏览器工具：Etherscan（以太坊区块链浏览器，查询交易、合约、地址数据、验证合约）

- 代码工具：VS Code + Solidity Visual Auditor插件（语法高亮、代码校验、安全检测）

- 节点服务：Alchemy/Infura/QuickNode（提供公共RPC节点，无需自建节点即可部署交互）

- 测试水龙头：Alchemy/Infura水龙头（免费领取测试网ETH）

## 三、标准开发流程（通用五步）

所有以太坊DApp、智能合约开发，均遵循以下标准化流程：

1. **环境准备**：安装基础运行环境（Node.js、代码编辑器、MetaMask钱包）。

2. **合约开发**：使用Solidity编写智能合约，定义链上业务逻辑（代币、NFT、质押、交易逻辑等）。

3. **本地测试**：在本地模拟网络完成编译、部署、单元测试、边界测试，修复代码漏洞。

4. **测试网部署**：领取测试ETH，将合约部署至公共测试网，完成线上功能验证。

5. **线上落地**：对接前端页面、实现钱包交互，或优化合约后部署至主网正式上线。

## 四、新手极速实操：Remix IDE在线开发（零配置）

Remix IDE是新手入门最佳工具，无需搭建本地环境，浏览器直接完成合约全流程开发、编译、部署、测试。官网：[https://remix.ethereum.org/](https://remix.ethereum.org/)

### 1. 编写基础智能合约

在Remix中新建文件 `HelloEth.sol`，写入以下可直接运行的基础合约：

```
// SPDX-License-Identifier: MIT
// 指定Solidity编译器版本
pragma solidity ^0.8.20;

// 基础以太坊智能合约示例
contract HelloEth {
    // 链上永久存储的公共变量
    string public message;

    // 构造函数：合约部署时仅执行一次
    constructor() {
        message = "Hello Ethereum!";
    }

    // 写入方法：修改链上数据（消耗Gas）
    function setMessage(string memory _newMsg) public {
        message = _newMsg;
    }

    // 读取方法：查询链上数据（免费、无需Gas）
    function getMessage() public view returns (string memory) {
        return message;
    }
}
```

### 2. 完整操作步骤

1. 左侧菜单栏打开 **Solidity Compiler**，选择对应编译器版本，点击编译合约；

2. 切换至 **Deploy & Run Transactions** 模块；

3. 运行环境选择 **Remix VM**（本地虚拟测试网络）；

4. 点击 **Deploy** 完成合约部署；

5. 部署成功后，可直接调用 `getMessage` 读取数据、`setMessage` 修改链上数据。

该合约实现了最核心的链上能力：**数据存储、数据读取、数据修改**，是所有复杂合约的基础。

## 五、本地全栈开发：Hardhat环境搭建与实操

Hardhat适用于商业级DApp开发、复杂合约调试、前后端一体化项目，是新手进阶必学框架。

### 1. 项目初始化

```
# 创建项目文件夹
mkdir eth-demo
cd eth-demo

# 初始化npm项目
npm init -y

# 安装Hardhat核心依赖
npm install --save-dev hardhat
```

### 2. 创建标准Hardhat项目

```
npx hardhat init
```

根据提示选择：**Create a JavaScript project**，自动生成合约、测试、部署脚本模板。

### 3. 核心常用命令

```
# 编译所有智能合约
npx hardhat compile

# 执行自动化单元测试
npx hardhat test

# 部署合约到本地模拟网络
npx hardhat run scripts/deploy.js
```

### 4. 测试网部署

修改项目配置文件 `hardhat.config.js`，接入Sepolia测试网RPC节点、配置钱包私钥，执行部署命令即可完成公共测试网部署，实现线上可访问的智能合约。

## 六、专业级开发：Foundry高性能框架全解

Foundry是目前以太坊生态**DeFi开发、合约安全审计、高性能协议开发**的行业标配，由Paradigm团队开发，基于Rust底层，性能远超传统JS框架。

### 1. Foundry核心介绍

Foundry是一套原生Solidity开发工具链，无需依赖JS环境，核心包含四大工具：

- **forge**：核心工具，负责合约编译、单元测试、模糊测试、部署、合约验证；

- **anvil**：轻量化本地节点，速度远超Ganache、Hardhat本地网络，支持主网分叉、地址模拟；

- **cast**：链上命令行工具，可查询链数据、发送交易、编解码ABI、调试链上信息；

- **chisel**：Solidity交互式REPL，快速调试代码片段，即时验证语法和逻辑。

核心优势：**全流程Solidity开发、无语言切换、编译测试速度比Hardhat快5-10倍、内置工业级Fuzz模糊测试**。

### 2. Foundry安装与项目创建（macOS/Linux）

```
# 安装Foundry工具链
curl -L https://foundry.paradigm.xyz | bash

# 初始化完整环境（forge/cast/anvil/chisel）
foundryup

# 创建全新Foundry项目
forge init HelloFoundry
cd HelloFoundry
```

### 3. 实战合约+原生Solidity测试

合约文件 `src/Counter.sol`：

```
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
```

测试文件 `test/Counter.t.sol`（Solidity原生测试，无需JS）：

```
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
```

### 4. Foundry核心运行命令

```sh
# 编译合约
forge build

# 执行单元测试+模糊测试
forge test

# 启动高性能本地节点anvil
anvil

# 执行链上部署脚本（默认 dry run）
forge script script/Counter.s.sol:CounterScript --rpc-url http://127.0.0.1:8545 --private-key <key>
```

启动 `anvil` 后，它会打印出本地链信息，包括：

- `Listening on 127.0.0.1:8545`
- `Chain ID`（默认 `31337`）
- `Available Accounts`
- `Private Keys`

例子：

```
Foundry$ anvil


                             _   _
                            (_) | |
      __ _   _ __   __   __  _  | |
     / _` | | '_ \  \ \ / / | | | |
    | (_| | | | | |  \ V /  | | | |
     \__,_| |_| |_|   \_/   |_| |_|

    1.7.1 (4072e48705 2026-05-08T07:50:55.527285345Z)
    https://github.com/foundry-rs/foundry

Available Accounts
==================

(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000.000000000000000000 ETH)
(1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000.000000000000000000 ETH)
(2) 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC (10000.000000000000000000 ETH)
(3) 0x90F79bf6EB2c4f870365E785982E1f101E93b906 (10000.000000000000000000 ETH)
(4) 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 (10000.000000000000000000 ETH)
(5) 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc (10000.000000000000000000 ETH)
(6) 0x976EA74026E726554dB657fA54763abd0C3a0aa9 (10000.000000000000000000 ETH)
(7) 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955 (10000.000000000000000000 ETH)
(8) 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f (10000.000000000000000000 ETH)
(9) 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 (10000.000000000000000000 ETH)

Private Keys
==================

(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
(1) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
(2) 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
(3) 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
(4) 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a
(5) 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba
(6) 0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e
(7) 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356
(8) 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97
(9) 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

Wallet
==================
Mnemonic:          test test test test test test test test test test test junk
Derivation path:   m/44'/60'/0'/0/
```

### Foundry `forge script` 广播说明

- 本地 `anvil` 也是一个完整的链节点，它模拟了一条独立的本地链。
- `forge script` 默认不加 `--broadcast` 时，做的是“dry run”模拟：
  - 只是检查脚本是否能执行
  - 估算 gas
  - 生成交易数据
  - 不会真正发送交易到 `anvil`
- 因此“未广播”不会在本地链上写入状态，也不会影响任何节点。

加上 `--broadcast`：
- 会把交易真实发送给指定节点（本地 `anvil` 或远程 RPC）
- 该节点会将交易包含进区块，改变链状态
- 对于本地 `anvil`，这就是“影响整条本地链”

所以本地链的区别是：
- “不广播” = 只模拟，不产生实际链上变化。
- “广播” = 真正提交到本地节点，链上状态变化可查询、可复用。
- 本地链本身就是一条独立链，不连接到其他远程节点，影响的就是这条本地链。

你可以直接从 `anvil` 启动输出里复制对应账户的私钥，用于 `forge script` 的 `--private-key` 参数。

示例：
```bash
forge script script/Counter.s.sol:CounterScript --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

> 注意：如果你只想先测试脚本是否正常，可先运行不带 `--broadcast` 的 dry run；如果想真正部署到本地链，则需要加上 `--broadcast`。

## 七、Hardhat vs Foundry 核心对比（选型指南)

对比维度
Hardhat
Foundry

底层核心
Node.js（JS/TS）
Rust（高性能原生）

测试语言
JS/TS，需语言切换
Solidity原生，一套语言通吃

编译/测试速度
较快
极快（大项目提升10倍+）

安全测试能力
需第三方插件支持Fuzz测试
内置工业级Fuzz+不变量测试

主网分叉能力
支持，速度一般
原生支持，极速稳定

生态插件
极其丰富，全场景覆盖
生态持续完善，核心功能齐全

适用场景
新手入门、做DApp全栈开发
DeFi协议、合约审计、高性能、高安全需求项目

### 框架选型总结

- 零基础、做DApp全栈开发：优先 **Hardhat + Remix**

- 合约深度开发、安全审计、DeFi项目：优先 **Foundry**

- 专业团队主流方案：**Foundry写合约+测试，Hardhat做前端集成+部署**，强强互补

## 八、完整学习路线（零基础到实战）

1. **入门阶段**：掌握Solidity基础语法，通过Remix IDE开发简单合约、ERC20代币、NFT基础合约，熟悉链上读写逻辑。

2. **进阶阶段**：熟练使用Hardhat，掌握合约编译、自动化测试、测试网部署、Ethers.js链上交互，理解DApp全栈架构。

3. **专业阶段**：学习Foundry，掌握Solidity原生测试、Fuzz模糊测试、主网分叉测试、合约安全优化。

4. **实战阶段**：独立开发代币系统、NFT市场、质押挖矿、简易DEX等项目，学习Gas优化、合约漏洞防护、Oracle链下数据交互。

## 九、全文总结

1. 以太坊开发核心逻辑：**Solidity智能合约（链上逻辑）+ DApp前端交互（用户入口）**。

2. 工具分层使用：Remix用于快速验证、Hardhat用于全栈落地、Foundry用于专业合约开发与安全测试。

3. 标准化开发流程：编写→本地测试→测试网验证→主网上线，所有项目通用。

4. 新手学习核心：先掌握Solidity基础，再从Remix入门，逐步过渡到Hardhat、Foundry，兼顾实用性与专业性。

