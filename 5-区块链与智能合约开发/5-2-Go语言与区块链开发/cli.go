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
addBlock --data DATA              "add data to blockchain"
printChain                        "print all blockchain data"
getBalance --address ADDRESS      "get blockchain address balance"
`

// Run 入口
func (cli *CLI) Run() {

	if len(os.Args) < 2 {
		fmt.Print(Usage)
		os.Exit(1)
	}

	addBlockCmd := flag.NewFlagSet("addBlock", flag.ExitOnError)
	printChainCmd := flag.NewFlagSet("printChain", flag.ExitOnError)
	getBalanceCmd := flag.NewFlagSet("getBalance", flag.ExitOnError)

	// 参数定义
	addBlockData := addBlockCmd.String("data", "", "block data")
	getBalanceAddress := getBalanceCmd.String("address", "", "address balance")

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

	case "getBalance":
		err := getBalanceCmd.Parse(os.Args[2:])
		if err != nil {
			panic(err)
		}

	default:
		fmt.Print(Usage)
		os.Exit(1)
	}

	// =========================
	// addBlock
	// =========================
	if addBlockCmd.Parsed() {

		if *addBlockData == "" {
			fmt.Println("error: please input data")
			os.Exit(1)
		}

		cli.bc.AddBlock([]*Transaction{
			// to
			NewCoinbaseTX("cli-user", *addBlockData),
		})

		fmt.Println("add block success")
	}

	// =========================
	// printChain
	// =========================
	if printChainCmd.Parsed() {
		cli.bc.PrintChain()
	}

	// =========================
	// getBalance
	// =========================
	if getBalanceCmd.Parsed() {

		if *getBalanceAddress == "" {
			fmt.Println("error: please input address")
			os.Exit(1)
		}

		cli.GetBalance(*getBalanceAddress)
	}
}

func (cli *CLI) GetBalance(address string) {

	utxos := cli.bc.FindUTXOs(address)

	var balance int64

	for _, out := range utxos {
		balance += out.Value
	}

	fmt.Printf("Balance of %s: %d\n", address, balance)
}
