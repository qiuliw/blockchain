package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/binary"
	"time"
)

// 0. 定义区块结构
type Block struct {
	// 版本号
	Version uint64

	// MerkleRoot(这是一个概念，暂时不实现)
	// 它是区块中所有交易的hash值的树形结构的根节点hash值
	MerkleRoot []byte

	// 时间戳
	Timestamp int64

	// 难度值
	Difficulty uint64

	// 随机数，也就是挖矿过程中不断变化的数值
	Nonce uint64

	// 前区块hash
	PrevHash []byte

	// 数据
	Data []byte

	// 当前区块hash
	// 正常比特币并不会存储这个字段
	// hash属于区块头计算结果
	// 这里为了教学方便不保存，动态计算
}

// 2. 创建区块
func NewBlock(data string, prevHash []byte) *Block {

	block := &Block{
		Version:    0,
		PrevHash:   prevHash,
		MerkleRoot: []byte{},
		Timestamp:  time.Now().Unix(),
		Difficulty: 16,
		Nonce:      0,
		Data:       []byte(data),
	}

	// 创建工作量证明对象
	pow := NewProofOfWork(block)

	// 开始挖矿
	nonce, _ := pow.Run()

	// 保存随机数
	block.Nonce = nonce

	return block
}

// 根据 nonce(未定状态) 生成快照
func (b *Block) PrepareData(nonce uint64) []byte {

	tmp := [][]byte{
		Uint64ToBytes(b.Version),
		b.MerkleRoot,
		Uint64ToBytes(uint64(b.Timestamp)),
		Uint64ToBytes(b.Difficulty),
		Uint64ToBytes(nonce),
		b.PrevHash,
		b.Data,
	}

	return bytes.Join(tmp, []byte{})
}

// 生成hash
func (b *Block) Hash() []byte {

	// 使用当前区块保存的 nonce
	blockInfo := b.PrepareData(b.Nonce)

	// 计算 SHA256
	hash := sha256.Sum256(blockInfo)

	return hash[:]
}

// 4. 引入区块链
type BlockChain struct {
	blocks []*Block // 区块数组
}

// 5. 创建一个区块链
func NewBlockChain() *BlockChain {

	// 创建区块链时，默认添加创世区块
	return &BlockChain{
		blocks: []*Block{
			GenesisBlock(),
		},
	}
}

// 6. 生成创世区块
func GenesisBlock() *Block {
	return NewBlock("Genesis Block", []byte{})
}

// 7. 添加区块
func (bc *BlockChain) AddBlock(data string) {

	// 获取最后一个区块
	lastBlock := bc.blocks[len(bc.blocks)-1]

	// 动态计算前一个区块的哈希
	prevHash := lastBlock.Hash()

	// 创建新区块
	newBlock := NewBlock(data, prevHash)

	// 添加到区块链
	bc.blocks = append(bc.blocks, newBlock)
}

// 辅助函数，将 uint64 转换为 []byte
func Uint64ToBytes(num uint64) []byte {

	buf := make([]byte, 8)

	binary.BigEndian.PutUint64(buf, num)

	return buf
}
