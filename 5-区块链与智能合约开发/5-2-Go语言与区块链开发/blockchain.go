package main

import (
	"fmt"

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

		if bucket == nil {
			return fmt.Errorf("Bucket %q not found! please check your database", blockBucket)
		}

		// 添加到区块链
		err := bucket.Put(
			newBlock.Hash(),
			newBlock.Serialize(),
		)

		if err != nil {
			return err
		}

		// 更新最后区块hash
		// 注意，先添加区块，再更新最后区块hash，否则中间如果发生错误，tail就会指向一个不存在的区块
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

// 打印区块链
func (bc *BlockChain) PrintChain() {

	it := bc.NewIterator()

	for {

		block := it.Next()

		fmt.Printf("Version: %d\n", block.Version)

		fmt.Printf("PrevHash: %x\n", block.PrevHash)

		fmt.Printf("Hash: %x\n", block.Hash())

		fmt.Printf("Timestamp: %d\n", block.Timestamp)

		fmt.Printf("Nonce: %d\n", block.Nonce)

		fmt.Printf("Difficulty: %d\n", block.Difficulty)

		fmt.Printf("Data: %s\n", block.Data)

		pow := NewProofOfWork(block)

		fmt.Printf("Validate: %t\n", pow.Validate())

		fmt.Println()

		// 创世区块
		if len(block.PrevHash) == 0 {
			break
		}
	}
}
