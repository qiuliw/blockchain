package main

import (
	"flag"
	"fmt"
	"os"
)

type CLI struct {
	bc *BlockChain
}

const Usage = `
addBlock --data DATA      "add data to blockchain"
printChain                "print all blockchain data"
`

// 接收参数的动作，我们放到一个函数中
func (cli *CLI) Run() {

	// 判断命令数量
	if len(os.Args) < 2 {
		fmt.Println(Usage)
		os.Exit(1)
	}

	// 创建命令集
	addBlockCmd := flag.NewFlagSet("addBlock", flag.ExitOnError)

	printChainCmd := flag.NewFlagSet("printChain", flag.ExitOnError)

	// addBlock参数
	addBlockData := addBlockCmd.String(
		"data",
		"",
		"block data",
	)

	// 获取命令
	switch os.Args[1] {

	case "addBlock":

		err := addBlockCmd.Parse(os.Args[2:])
		if err != nil {
			panic(err)
		}

	case "printChain":

		err := printChainCmd.Parse(os.Args[2:])
		if err != nil {
			panic(err)
		}

	default:

		fmt.Println(Usage)
		os.Exit(1)
	}

	// 执行 addBlock
	if addBlockCmd.Parsed() {

		if *addBlockData == "" {
			fmt.Println("please input data")
			os.Exit(1)
		}

		// cli.bc.AddBlock(*addBlockData)

		fmt.Println("add block success")
	}

	// 执行 printChain
	if printChainCmd.Parsed() {
		cli.bc.PrintChain()
	}
}
