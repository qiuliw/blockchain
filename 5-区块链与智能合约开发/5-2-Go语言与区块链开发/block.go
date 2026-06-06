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
	// MerkleRoot(这是一个概念，暂时不实现)，它是区块中所有交易的hash值的树形结构的根节点hash值
	MerkleRoot []byte
	// 时间戳
	Timestamp int64
	// 难度值
	Difficulty uint64
	// 随机数，也就是挖矿过程中不断变化的数值，直到满足挖矿条件为止
	Nonce uint64

	// 前区块hash
	PrevHash []byte
	// 数据
	Data []byte

	// 当前区块hash（PrevHash+Data）唯一性不只数据，还包含前区块hash。
	// 正常比特币是没有的，hash不是内部固有属性，而是外部计算的，这里为了简化，直接放在区块结构体中
	// Hash []byte
}

// 2. 创建区块
func NewBlock(data string, prevHash []byte) *Block {
	block := &Block{
		Version:    0,
		PrevHash:   prevHash,
		MerkleRoot: []byte{},
		Timestamp:  time.Now().Unix(),
		Difficulty: 0, // 难度值暂时不实现，默认为0
		Nonce:      0, // 默认为0，挖矿过程中不断变化
		Data:       []byte(data),
	}

	return block
}

// 3. 生成hash
// 3. 生成hash
func (b *Block) Hash() []byte {
	// 将所有字段转换为 [][]byte
	tmp := [][]byte{
		Uint64ToBytes(b.Version),
		b.MerkleRoot,
		Uint64ToBytes(uint64(b.Timestamp)),
		Uint64ToBytes(b.Difficulty),
		Uint64ToBytes(b.Nonce),
		b.PrevHash,
		b.Data,
	}

	// 拼接所有字节切片
	blockInfo := bytes.Join(tmp, []byte{})

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
	return &BlockChain{[]*Block{GenesisBlock()}} // 创建区块链时，默认添加创世区块
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
	newBlock := NewBlock(data, prevHash)
	bc.blocks = append(bc.blocks, newBlock)
}

// 辅助函数，将 unint64 转换为 []byte
func Uint64ToBytes(num uint64) []byte {
	buf := make([]byte, 8)
	binary.BigEndian.PutUint64(buf, num)
	return buf
}
