package main

import (
	"crypto/sha256"
	"math/big"
)

// 工作量证明
type ProofOfWork struct {
	Block  *Block
	Target *big.Int // 难度对应的目标值，挖矿成功的hash值必须小于这个目标值
}

// 创建工作量证明
func NewProofOfWork(block *Block) *ProofOfWork {

	// 1. 创建一个大整数，初始值为1
	target := big.NewInt(1)

	// 2.得到目标值（需要 hash 出来的值落于该值之下）
	// 难度值越大，越难。所允许区间越小，前面0就越多，挖矿就越难
	// 最高位1向右移动难度值位，得到目标值，用Lsh函数就是左移(256-难度值位)，得到目标值
	target.Lsh(target, uint(256-block.Difficulty))

	return &ProofOfWork{
		Block:  block,
		Target: target,
	}
}

// 提供一个挖矿函数
// 挖矿过程就是不断改变随机数
// 直到满足挖矿条件为止
// 函数式编程，返回挖矿结果，不改变区块数据
func (pow *ProofOfWork) Run() (uint64, []byte) {

	var nonce uint64

	var hash [32]byte

	hashInt := new(big.Int)

	for {

		// 使用当前nonce拼接区块数据
		data := pow.Block.PrepareData(nonce)

		// 计算hash
		hash = sha256.Sum256(data)

		// 转成大整数
		hashInt.SetBytes(hash[:])

		// hash < target
		if hashInt.Cmp(pow.Target) < 0 {
			break
		}

		// if nonce == ^uint64(0) {
		// 	return 0, nil // 搜索空间耗尽
		// }

		nonce++
	}

	return nonce, hash[:]
}

// 提供一个校验函数
func (pow *ProofOfWork) Validate() bool {

	hash := pow.Block.Hash()

	hashInt := new(big.Int)
	hashInt.SetBytes(hash[:])

	// hash < target
	return hashInt.Cmp(pow.Target) < 0
}
