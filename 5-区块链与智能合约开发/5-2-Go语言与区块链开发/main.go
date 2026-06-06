package main

import "fmt"

func main() {

	chain := NewBlockChain()

	defer chain.db.Close()

	chain.AddBlock("Hello Blockchain")
	chain.AddBlock("Hello Golang")
	chain.AddBlock("Hello BoltDB")

	it := chain.NewIterator()

	for {

		block := it.Next()

		fmt.Printf("Version: %d\n", block.Version)

		fmt.Printf("PrevHash: %x\n", block.PrevHash)

		fmt.Printf("Hash: %x\n", block.Hash())

		fmt.Printf("Nonce: %d\n", block.Nonce)

		fmt.Printf("Difficulty: %d\n", block.Difficulty)

		fmt.Printf("Data: %s\n", block.Data)

		pow := NewProofOfWork(block)

		fmt.Printf("Validate: %t\n", pow.Validate())

		fmt.Println()

		if len(block.PrevHash) == 0 {
			break
		}
	}
}
