package main

import (
	"crypto/sha256"
)

// 0. 定义区块结构
type Block struct {
	// 前区块hash
	PrevHash []byte
	// 数据
	Data []byte
	// 当前区块hash（PrevHash+Data）唯一性不只数据，还包含前区块hash
	Hash []byte
}

// 2. 创建区块
func NewBlock(data string, prevHash []byte) *Block {
	block := &Block{prevHash, []byte(data), []byte{}}
	block.SetHash() // 生成hash
	return block
}

// 3. 生成hash
func (block *Block) SetHash() {
	// 1. 将区块的属性拼接成一个字节数组
	blockInfo := append(block.PrevHash, block.Data...)
	// 2. 生成hash
	hash := sha256.Sum256(blockInfo)
	block.Hash = hash[:] // 数组转切片
}

// 4. 引入区块链
type BlockChain struct {
	blocks []*Block // 区块数组

}

// 5. 创建一个区块链
func NewBlockChain() *BlockChain {
	return &BlockChain{[]*Block{GenesisBlock()}} // 创建区块链时，默认添加创世区块
}

// 6. 生成创世区块
func GenesisBlock() *Block {
	return NewBlock("Genesis Block", []byte{})
}

// 7. 添加区块
func (bc *BlockChain) AddBlock(data string) {
	lastBlock := bc.blocks[len(bc.blocks)-1] // 获取最后一个区块
	newBlock := NewBlock(data, lastBlock.Hash)
	bc.blocks = append(bc.blocks, newBlock) // 将新块添加到区块链中
}
