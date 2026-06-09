package main

import (
	"flag"
	"fmt"
	"os"
)

type CLI struct {
	bc *Blockchain
}

const Usage = `
addBlock --data DATA                                              "add data to blockchain"
printChain                                                        "print all blockchain data"
getBalance --address ADDRESS                                      "get blockchain address balance"
send --from FROM --to TO --amount AMOUNT --miner MINER [--data]   "send coin from one address to another"

newWallet                                                         "create wallet"
listAddresses                                                     "show all wallet addresses"

`

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

	newWalletCmd := flag.NewFlagSet("newWallet", flag.ExitOnError)
	listAddressesCmd := flag.NewFlagSet("listAddresses", flag.ExitOnError)

	// 参数
	addBlockData := addBlockCmd.String(
		"data",
		"",
		"block data",
	)

	getBalanceAddress := getBalanceCmd.String(
		"address",
		"",
		"wallet address",
	)

	sendFrom := sendCmd.String(
		"from",
		"",
		"source address",
	)

	sendTo := sendCmd.String(
		"to",
		"",
		"destination address",
	)

	sendAmount := sendCmd.Int64(
		"amount",
		0,
		"transfer amount",
	)

	sendMiner := sendCmd.String(
		"miner",
		"",
		"miner address",
	)

	sendData := sendCmd.String(
		"data",
		"",
		"coinbase data",
	)

	switch os.Args[1] {

	case "addBlock":
		_ = addBlockCmd.Parse(os.Args[2:])

	case "printChain":
		_ = printChainCmd.Parse(os.Args[2:])

	case "getBalance":
		_ = getBalanceCmd.Parse(os.Args[2:])

	case "send":
		_ = sendCmd.Parse(os.Args[2:])

	case "newWallet":
		_ = newWalletCmd.Parse(os.Args[2:])

	case "listAddresses":
		_ = listAddressesCmd.Parse(os.Args[2:])

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
			NewCoinbaseTX(
				"cli-user",
				*addBlockData,
			),
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

			fmt.Println(
				"error: please input address",
			)

			os.Exit(1)
		}

		cli.GetBalance(*getBalanceAddress)
	}

	// send
	if sendCmd.Parsed() {

		if *sendFrom == "" ||
			*sendTo == "" ||
			*sendMiner == "" ||
			*sendAmount <= 0 {

			fmt.Println(
				"error: invalid send arguments",
			)

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

	// newWallet
	if newWalletCmd.Parsed() {
		cli.NewWallet()
	}

	// listAddresses
	if listAddressesCmd.Parsed() {
		cli.ListAddresses()
	}
}

// 查询余额
func (cli *CLI) GetBalance(address string) {

	utxos := cli.bc.FindUTXO(address)

	var balance int64

	for _, out := range utxos {
		balance += out.Value
	}

	fmt.Printf(
		"Balance of %s: %d\n",
		address,
		balance,
	)
}

// 转账
func (cli *CLI) Send(
	from string,
	to string,
	amount int64,
	miner string,
	data string,
) {

	wallets := NewWallets()
	wallet := wallets.GetWallet(from)
	if wallet == nil {
		fmt.Println("transaction create failed: from address wallet not found")
		return
	}

	tx := NewUTXOTransaction(
		wallet,
		to,
		amount,
		cli.bc,
	)

	if tx == nil {
		fmt.Println("transaction create failed")
		return
	}

	coinbase := NewCoinbaseTX(
		miner,
		data,
	)

	cli.bc.AddBlock(
		[]*Transaction{
			coinbase,
			tx,
		},
	)

	fmt.Println("send success")
}

// 创建钱包
func (cli *CLI) NewWallet() {

	wallets := NewWallets()

	address := wallets.CreateWallet()

	fmt.Println("wallet created")
	fmt.Println("address:", address)
}

// 显示所有钱包地址
func (cli *CLI) ListAddresses() {

	wallets := NewWallets()

	addresses := wallets.GetAddresses()

	if len(addresses) == 0 {

		fmt.Println("no wallet")

		return
	}

	fmt.Println("wallet addresses:")

	for i, address := range addresses {

		fmt.Printf(
			"%d. %s\n",
			i+1,
			address,
		)
	}
}
