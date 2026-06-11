# 5-2 Go 语言与区块链开发

简易 PoW 区块链 CLI 示例（Go）。

## 环境

- Go 1.18+

## 安装

```bash
cd 5-2-Go语言与区块链开发
go mod download
```

## 运行

```bash
# 添加区块
go run . addBlock --data "hello"

# 打印整条链
go run . printChain

# 创建钱包
go run . createWallet

# 查看所有钱包地址
go run . listAddresses

# 转账（需先有区块和钱包）
go run . send -from <地址> -to <地址> -amount 10
```

## 测试

```bash
go test ./...
```
