package main

import "fmt"

func main() {

	chain := NewBlockChain()

	chain.AddBlock("Hello, Blockchain!")

	for i, block := range chain.blocks {

		fmt.Printf("Height: %d\n", i)

		fmt.Printf("Version: %d\n", block.Version)

		fmt.Printf("PrevHash: %x\n", block.PrevHash)

		fmt.Printf("Hash: %x\n", block.Hash())

		fmt.Printf("Nonce: %d\n", block.Nonce)

		fmt.Printf("Difficulty: %d\n", block.Difficulty)

		fmt.Printf("Data: %s\n", block.Data)

		pow := NewProofOfWork(block)

		fmt.Printf("Validate: %t\n", pow.Validate())

		fmt.Println()
	}
}
