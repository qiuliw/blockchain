# IPFS 知识点

IPFS（InterPlanetary File System，星际文件系统）是一种分布式文件存储与内容寻址网络。在以太坊 DApp 中，它常用来存放图片、文档等大体积数据，智能合约里只保存对应的哈希（CID），从而避免把大量数据直接写入链上。

课程示例使用本地 IPFS 节点，通过 JavaScript 库 **ipfs-api**（v26.x）调用 HTTP API 与节点通信。

---

## 一、IPFS 是什么

传统 HTTP 是「按地址找内容」：你访问 `https://example.com/a.jpg`，服务器决定返回什么。IPFS 是「按内容找地址」：文件内容经过哈希运算后得到唯一标识 **CID**（Content Identifier，内容标识符），形如 `Qm...` 或 `bafy...`。只要内容不变，CID 就不变；内容一变，CID 就变。

可以把 IPFS 理解为一个去中心化的文件网络：每个节点既可以从别人那里拉取文件，也可以把自己拥有的文件提供给他人。本地开发时通常只跑一个本机节点，上传和读取都在本机完成。

---

## 二、为什么和区块链结合

以太坊链上存储昂贵且容量有限，不适合直接存图片、长文本、视频。常见做法是：

1. 把文件上传到 IPFS，得到 CID（哈希）
2. 把 CID 作为字符串写入智能合约
3. 前端从合约读出 CID，再通过 IPFS 网关访问实际文件

这样链上只存几十字节的哈希，链下存完整内容，既节省 Gas，又保留可追溯性。

---

## 三、安装与启动

### 3.1 安装 Kubo（原 go-ipfs）

[Kubo](https://docs.ipfs.tech/install/) 是 IPFS 的参考实现，安装后命令行工具为 `ipfs`。

```bash
# 首次使用需初始化（生成 ~/.ipfs 配置目录）
ipfs init

# 启动本地节点
ipfs daemon
```

`ipfs daemon` 启动后，终端会显示 API 和 Gateway 地址，开发时主要用这两个端口。

### 3.2 本地端口

| 端口 | 用途 | 典型地址 |
|------|------|----------|
| **5001** | HTTP API，程序上传/读取文件 | `http://127.0.0.1:5001` |
| **8080** | Gateway，浏览器直接访问文件 | `http://127.0.0.1:8080/ipfs/{CID}` |

- 写代码（`ipfs.add`、`ipfs.cat`）走 **5001**
- 在网页 `<img src="...">` 里展示图片走 **8080** 网关

部分环境 Gateway 端口可能是 8848，以 `ipfs daemon` 启动日志为准。

---

## 四、核心概念

### 4.1 CID（内容哈希）

上传文件后 IPFS 返回的 `hash` 字段就是 CID，例如：

```
QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG
```

CID 是内容的「指纹」。合约里通常用 `string` 类型保存它。

### 4.2 内容寻址

同一份文件无论上传多少次，只要内容相同，CID 就相同。这与 HTTP 的「同一 URL 内容可能被替换」形成对比，更适合需要防篡改、可验证的场景。

### 4.3 节点与网络

- **本地节点**：`ipfs daemon` 启动的进程，负责接收 API 请求、存储和提供文件
- **公共网关**：如 `https://ipfs.io/ipfs/{CID}`，无需本地节点即可在浏览器访问已广播到网络的文件
- 开发阶段用本地节点即可；生产环境常配合 Pinning 服务（如 Pinata、web3.storage）保证文件长期在线

---

## 五、一句话理解

- **磁力** ≈ 更简单的文件共享协议
- **IPFS** ≈ 升级版的分布式文件系统框架

---

## 六、底层架构与网络

### 6.1 协议栈分层

Kubo（go-ipfs）的底层可以分成以下几层：

```
应用层     HTTP API (5001) / Gateway (8080)
           ↓
IPFS 层    块存储、DAG、CID、Pinning
           ↓
交换层     Bitswap（按块请求和交换数据）
           ↓
网络层     libp2p（TCP / QUIC / WebRTC 等传输）
           ↓
发现层     DHT（Kademlia）+ mDNS + Bootstrap 节点
```

- **DHT**：负责「找谁有」——在全网定位持有某个 CID 的节点（Provider Record）
- **Bitswap**：负责「拿数据」——节点之间实际交换文件块
- DHT 本身**不存储文件内容**，只存路由信息；真正传数据走 Bitswap

### 6.2 DHT（分布式哈希表）

IPFS 默认使用 **libp2p Kademlia DHT** 做节点与内容提供者发现。

DHT 主要承担两类查询：

1. **节点发现**：网络里还有哪些 peer 可以连接
2. **内容提供者发现**：哪些节点本地持有某个 CID 对应的块

新节点首次入网时，通过 **Bootstrap 节点**（IPFS 内置公共引导节点列表）接入 DHT，之后即可在全网查找内容提供者。

局域网内还可通过 **mDNS** 自动发现邻居节点，无需经过公网 DHT。

### 6.3 是否依赖公网 IP

**IPFS 不严格依赖公网 IP**，但公网可达性影响「别人能不能主动连上你」。

| 场景 | 是否需要公网 IP |
|------|----------------|
| 本机开发（`127.0.0.1:5001` 上传/读取） | 不需要 |
| 同一局域网两台机器互传 | 不需要（mDNS 可发现） |
| 跨公网、节点在 NAT/路由器后面 | 不必须，但连入会困难 |
| 作为长期公共种子节点 | 需要公网 IP 或端口映射 |

NAT 后面的节点通常可以**主动连出去**拉取内容，但其他节点**不一定能主动连进来**。常见解决方案：

- **NAT 穿透**（hole punching）：能穿透则无需公网 IP
- **Relay 中继**（libp2p circuit relay）：经第三方节点转发流量
- **Pinning 服务**：由有公网可达性的服务商固定存储 CID
- **公共 Gateway**：如 `ipfs.io`，通过 HTTP 访问已广播到网络的内容

课程示例中的 `ipfs daemon` 跑在本机，上传和读取都走 `127.0.0.1`，**不涉及公网 P2P**，也几乎用不到 DHT。部署到生产、需要全球用户访问时，才需要考虑节点可达性、Pinning 和 DHT 传播。

---

## 七、JavaScript 接入：ipfs-api

### 7.1 安装与创建客户端

```bash
npm i ipfs-api
```

```javascript
const ipfsAPI = require('ipfs-api')

// 连接本机节点（API 端口 5001）
const ipfs = ipfsAPI('localhost', '5001', { protocol: 'http' })

// 等价写法（对象参数）
const ipfs = ipfsAPI({
  ip: 'localhost',
  port: '5001',
  protocol: 'http',
})
```

**注意**：调用任何 API 前必须先启动 `ipfs daemon`，否则会连接失败。

### 7.2 上传内容：add / files.add

上传文本或二进制数据，得到 CID：

```javascript
async function uploadText() {
  const content = ipfs.types.Buffer.from('Hello IPFS')
  const results = await ipfs.files.add(content)
  const hash = results[0].hash   // CID
  console.log('CID:', hash)
}
```

上传图片等二进制文件时，先把 `FileReader` 读成 `ArrayBuffer`，再转成 `Buffer`：

```javascript
async function uploadBuffer(arrayBuffer) {
  const buffer = Buffer.from(arrayBuffer)
  const results = await ipfs.add(buffer)
  return results[0].hash
}
```

`ipfs.add` 与 `ipfs.files.add` 在课程示例中都有使用，返回值结构类似，取 `results[0].hash` 即可。

### 7.3 读取内容：cat

根据 CID 取回原始数据：

```javascript
async function readContent(cid) {
  const data = await ipfs.cat(cid)
  console.log(data.toString())   // 文本内容
}
```

`cat` 返回的是 Buffer/流，文本需 `.toString()`，图片等二进制可直接用于展示或进一步处理。

### 7.4 列出目录：ls

查看某个 CID 下的文件列表（目录型 CID）：

```javascript
async function listDir(cid) {
  const files = await ipfs.ls(cid)
  files.forEach((file) => {
    console.log(file.name, file.hash)
  })
}
```

---

## 八、与智能合约结合

### 8.1 合约侧：存字符串哈希

合约不存文件本身，只存 CID 字符串：

```solidity
pragma solidity ^0.8.26;

contract SimpleStorage {
    string private storedData;

    function set(string memory x) public {
        storedData = x;
    }

    function get() public view returns (string memory) {
        return storedData;
    }
}
```

更复杂的业务（如电商拍卖）会在结构体里放多个 `string` 字段，分别对应图片 CID 和描述文本 CID。

### 8.2 应用侧：完整流程

```
用户选择文件
    ↓
上传到 IPFS（ipfs.add）→ 得到 picHash
    ↓
调用合约 set(picHash)（web3 发交易）
    ↓
需要展示时：合约 get() → 得到 picHash
    ↓
浏览器访问 http://127.0.0.1:8080/ipfs/{picHash}
```

上传 IPFS 和写链是两步独立操作：IPFS 成功不代表已上链，必须再发一笔交易把哈希写入合约。

---

## 九、前端展示

### 9.1 图片：通过 Gateway

合约返回的是 CID，前端拼出网关 URL 即可显示：

```html
<img src="http://127.0.0.1:8080/ipfs/QmXXXXXXXX" />
```

React 中动态拼接：

```jsx
<img src={`http://127.0.0.1:8080/ipfs/${picHash}`} />
```

### 9.2 文本描述：cat 后渲染

商品详情等长文本可以上传为独立 CID，展示时用 `ipfs.cat` 取回再插入页面：

```javascript
const content = await ipfs.cat(descHash)
document.getElementById('desc').innerText = content.toString()
```

图片走 Gateway 更直观；文本走 `cat` 便于在页面内嵌显示，无需跳转。

---

## 十、电商场景的存储拆分

拍卖类 DApp 通常把商品信息拆成两部分存储：

| 数据 | 存储位置 | 链上字段 |
|------|----------|----------|
| 商品图片 | IPFS（二进制 Buffer） | `imageLink` |
| 商品描述（长文本） | IPFS（UTF-8 文本 Buffer） | `descLink` |
| 名称、价格、时间等结构化字段 | 直接写入合约 | `name`、`startPrice` 等 |

上传描述时注意编码：

```javascript
const buffer = Buffer.from(productDesc, 'utf-8')
const results = await ipfs.add(buffer)
const descHash = results[0].hash
```

添加商品时把 `imageHash` 和 `descHash` 一并传入合约的 `addProduct` 类方法。

---

## 十一、ipfs CLI 常用命令

| 命令 | 作用 |
|------|------|
| `ipfs init` | 初始化本地配置（仅首次） |
| `ipfs daemon` | 启动节点 |
| `ipfs add <file>` | 命令行上传文件，输出 CID |
| `ipfs cat <CID>` | 命令行读取内容 |
| `ipfs id` | 查看本节点信息 |
| `ipfs swarm peers` | 查看已连接节点 |

---

## 十二、常见问题

**连接失败 / ECONNREFUSED**

先确认 `ipfs daemon` 是否在运行，API 端口是否为 5001。

**上传成功但浏览器图片裂了**

检查 Gateway 端口（默认 8080，部分环境为 8848），URL 格式应为 `http://127.0.0.1:8080/ipfs/{CID}`，不要漏掉 `/ipfs/` 路径段。

**合约写入后 get 为空**

确认部署后已将合约地址配置到前端；确认 `set` 交易已成功上链（不是只上传了 IPFS）。

**重启节点后文件找不到了**

本地节点未 Pin 的文件，重启后可能丢失。开发时上传后尽快测试；生产环境应使用 Pinning 服务固定 CID。

**ipfs-api 还能用吗**

`ipfs-api` 已不再积极维护，官方推荐 [kubo RPC 客户端](https://www.npmjs.com/package/kubo-rpc-client) 或 [Helia](https://github.com/ipfs/helia)。课程示例仍使用 `ipfs-api`，概念与 API 名称（`add`、`cat`、`ls`）在新库中大体一致，迁移时主要换连接方式。

---

## 十三、与 web3.js、Foundry 的关系

| 工具 | 职责 |
|------|------|
| **IPFS** | 链下存文件，返回 CID |
| **Foundry** | 编译、测试、部署存 CID 的合约 |
| **web3.js** | 前端/脚本调用合约 `set` / `get`，读写链上哈希 |

三者配合构成完整的 DApp 数据流：IPFS 管内容，以太坊管索引与业务逻辑，web3.js 负责与链交互。
