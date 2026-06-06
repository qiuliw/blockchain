package main

// go run . addBlock --data "hello"
// go run . printChain
func main() {
	// 创建或读出区块链
	bc := NewBlockChain()

	// 程序退出时关闭数据库
	defer bc.db.Close()

	// 创建命令行对象
	cli := CLI{
		bc: bc,
	}

	// 运行命令行
	cli.Run()
}
