# 链信租房（HKZF）

基于 Hyperledger Fabric 的区块链租房可信办理平台：管理端维护权威认证数据，用户端按序完成身份核验、房产核验与合同存证。

## 业务模型

完整流程、角色分工、链码与接口说明见：

**[docs/业务模型.md](docs/业务模型.md)**

## 快速开始

```bash
./deploy.sh up
```

访问 http://127.0.0.1:30888/

演示数据与用例见 [hkzf-front/samples/README.md](hkzf-front/samples/README.md)。

## 常用命令

| 命令 | 说明 |
|------|------|
| `./deploy.sh up` | 全栈部署 |
| `./deploy.sh chain` | 仅 Fabric + 链码 |
| `./deploy.sh app` | 仅业务应用 |
| `./deploy.sh build-app` | 构建 API / Web 镜像 |
| `./deploy.sh forward` | 启动 Web port-forward |
| `./deploy.sh stop` | 停止 port-forward |

## 目录结构

```
chaincode/          # authentication、certification、contract 链码
hkzf-back/          # Beego API
hkzf-front/         # Vue 静态前端
deploy/             # K8s 清单、构建与部署脚本
docs/               # 业务与架构文档
deploy.sh           # 统一部署入口
```
