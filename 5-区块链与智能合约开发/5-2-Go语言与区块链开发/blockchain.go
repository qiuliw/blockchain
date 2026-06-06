package main

import (
	"go.etcd.io/bbolt"
)

// 引入区块链
type BlockChain struct {
	// blocks []*Block // 区块数组
	db   *bbolt.DB
	tail []byte // 存储最后一个区块的hash值
}

const blockChainDB = "blockchain.db"
const blockBucket = "blocks"
const lastHashKey = "LastHash"

// 创建一个区块链
func NewBlockChain() *BlockChain {

	// 打开数据库
	db, err := bbolt.Open(blockChainDB, 0600, nil)

	if err != nil {
		panic(err)
	}

	var tail []byte

	err = db.Update(func(tx *bbolt.Tx) error {

		bucket := tx.Bucket([]byte(blockBucket))

		// bucket不存在
		if bucket == nil {

			var err error

			bucket, err = tx.CreateBucket([]byte(blockBucket))

			if err != nil {
				return err
			}

			// 创建区块链时，默认添加创世区块
			genesisBlock := GenesisBlock()

			// 保存创世区块
			err = bucket.Put(
				genesisBlock.Hash(),
				genesisBlock.Serialize(),
			)

			if err != nil {
				return err
			}

			// 保存最后区块hash
			err = bucket.Put(
				[]byte(lastHashKey),
				genesisBlock.Hash(),
			)

			if err != nil {
				return err
			}

			tail = genesisBlock.Hash()

		} else {

			tail = bucket.Get([]byte(lastHashKey))
		}

		return nil
	})

	if err != nil {
		panic(err)
	}

	return &BlockChain{
		db:   db,
		tail: tail,
	}
}

// 生成创世区块
func GenesisBlock() *Block {
	return NewBlock("Genesis Block", []byte{})
}

// 添加区块
func (bc *BlockChain) AddBlock(data string) {

	// 动态计算前一个区块的哈希
	prevHash := bc.tail

	// 创建新区块
	newBlock := NewBlock(data, prevHash)

	err := bc.db.Update(func(tx *bbolt.Tx) error {

		bucket := tx.Bucket([]byte(blockBucket))

		// 添加到区块链
		err := bucket.Put(
			newBlock.Hash(),
			newBlock.Serialize(),
		)

		if err != nil {
			return err
		}

		// 更新最后区块hash
		err = bucket.Put(
			[]byte(lastHashKey),
			newBlock.Hash(),
		)

		if err != nil {
			return err
		}

		bc.tail = newBlock.Hash()

		return nil
	})

	if err != nil {
		panic(err)
	}
}
