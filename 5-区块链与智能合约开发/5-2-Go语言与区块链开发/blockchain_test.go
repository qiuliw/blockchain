package main

import (
	"testing"
)

func TestBlockChain(t *testing.T) {
	bc := NewBlockChain()

	defer bc.db.Close()

	bc.AddBlock("Hello Blockchain")
	bc.AddBlock("Hello Golang")
	bc.AddBlock("Hello BoltDB")

	bc.PrintChain()
}
