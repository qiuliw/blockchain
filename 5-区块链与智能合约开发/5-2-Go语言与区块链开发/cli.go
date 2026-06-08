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
addBlock --data DATA                                              "add data to blockchain"
printChain                                                        "print all blockchain data"
getBalance --address ADDRESS                                      "get blockchain address balance"
send --from FROM --to TO --amount AMOUNT --miner MINER [--data]   "send coin from one address to another"
`

// send [--data] coinbase 附带数据

// Run 入口
func (cli *CLI) Run() {

	if len(os.Args) < 2 {
		fmt.Print(Usage)
		os.Exit(1)
	}

	// 命令
	addBlockCmd := flag.NewFlagSet("addBlock", flag.ExitOnError)
	printChainCmd := flag.NewFlagSet("printChain", flag.ExitOnError)
	getBalanceCmd := flag.NewFlagSet("getBalance", flag.ExitOnError)
	sendCmd := flag.NewFlagSet("send", flag.ExitOnError)

	// 参数定义
	addBlockData := addBlockCmd.String("data", "", "block data")
	getBalanceAddress := getBalanceCmd.String("address", "", "address balance")
	sendFrom := sendCmd.String("from", "", "source address")
	sendTo := sendCmd.String("to", "", "destination address")
	sendAmount := sendCmd.Int64("amount", 0, "transfer amount")
	sendMiner := sendCmd.String("miner", "", "miner address")
	sendData := sendCmd.String("data", "", "miner data")

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

	case "send":
		err := sendCmd.Parse(os.Args[2:])
		if err != nil {
			panic(err)
		}

	default:
		fmt.Print(Usage)
		os.Exit(1)
	}

	// addBlock
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

	// printChain
	if printChainCmd.Parsed() {
		cli.bc.PrintChain()
	}

	// getBalance
	if getBalanceCmd.Parsed() {

		if *getBalanceAddress == "" {
			fmt.Println("error: please input address")
			os.Exit(1)
		}

		cli.GetBalance(*getBalanceAddress)
	}

	if sendCmd.Parsed() {

		if *sendFrom == "" ||
			*sendTo == "" ||
			*sendMiner == "" ||
			*sendAmount <= 0 {

			fmt.Println("error: invalid send arguments")
			os.Exit(1)
		}

		cli.Send(
			*sendFrom,
			*sendTo,
			*sendAmount,
			*sendMiner,
			*sendData,
		)
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

func (cli *CLI) Send(
	from string,
	to string,
	amount int64,
	miner string,
	data string,
) {

	// 普通转账交易
	tx := NewTransaction(
		from,
		to,
		amount,
		cli.bc,
	)

	if tx == nil {
		fmt.Println("transaction create failed")
		return
	}

	// 挖矿奖励交易(简化)
	coinbase := NewCoinbaseTX(
		miner,
		data,
	)

	// 打包新区块
	cli.bc.AddBlock([]*Transaction{
		coinbase,
		tx,
	})

	fmt.Println("send success")
}
