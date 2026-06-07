package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/binary"
	"encoding/gob"
	"time"
)

// 0. 定义区块结构
type Block struct {
	// 版本号
	Version uint64

	// MerkleRoot(这是一个概念，暂时不实现)
	// 它是区块中所有交易的hash值的树形结构的根节点hash值
	MerkelRoot []byte

	// 时间戳
	Timestamp int64

	// 难度值
	Difficulty uint64

	// 随机数，也就是挖矿过程中不断变化的数值
	Nonce uint64

	// 前区块hash
	PrevHash []byte

	// 数据
	// Data []byte
	Transactions []*Transaction // 真实的交易数组
}

// 2. 创建区块
func NewBlock(txs []*Transaction, prevHash []byte) *Block {

	block := &Block{
		Version:    0,
		PrevHash:   prevHash,
		MerkelRoot: []byte{},
		Timestamp:  time.Now().Unix(),
		Difficulty: 16,
		Nonce:      0,
		// Data:       []byte(data),
		Transactions: txs,
	}

	block.MerkelRoot = block.MakeMerkelRoot()

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
		b.MerkelRoot,
		Uint64ToBytes(uint64(b.Timestamp)),
		Uint64ToBytes(b.Difficulty),
		Uint64ToBytes(nonce),
		b.PrevHash,
		// 只对区块头做Hash，区块体通过MerkelRoot影响hash
		// b.Data,
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

// 区块序列化
func (b *Block) Serialize() []byte {

	var buffer bytes.Buffer

	encoder := gob.NewEncoder(&buffer)

	err := encoder.Encode(b)
	if err != nil {
		panic(err)
	}

	return buffer.Bytes()
}

// 区块反序列化
func Deserialize(data []byte) *Block {

	var block Block

	decoder := gob.NewDecoder(bytes.NewReader(data))

	err := decoder.Decode(&block)
	if err != nil {
		panic(err)
	}

	return &block
}

// 辅助函数，将 uint64 转换为 []byte
func Uint64ToBytes(num uint64) []byte {

	buf := make([]byte, 8)

	binary.BigEndian.PutUint64(buf, num)

	return buf
}

// 模拟 MerkelRoot，真实是对交易hash做二叉树
func (b *Block) MakeMerkelRoot() []byte {
	// TODO
	return []byte{}
}
