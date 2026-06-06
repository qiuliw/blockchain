package main

import "fmt"

func main() {
	chain := NewBlockChain()
	chain.AddBlock("Hello, Blockchain!")
	for i, block := range chain.blocks {
		fmt.Printf("Height: %d\n", i)
		fmt.Printf("PrevHash: %x\n", block.PrevHash)
		fmt.Printf("Data: %s\n", block.Data)
		fmt.Printf("Hash: %x\n", block.Hash())
		fmt.Println()
	}
}
