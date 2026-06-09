package main

import "go.etcd.io/bbolt"

// 定义迭代器
type BlockchainIterator struct {
	db          *bbolt.DB
	currentHash []byte
}

// 创建迭代器
func (bc *Blockchain) NewIterator() *BlockchainIterator {

	return &BlockchainIterator{
		db:          bc.db,
		currentHash: bc.tail,
	}
}

func (it *BlockchainIterator) Next() *Block {

	var block *Block

	err := it.db.View(func(tx *bbolt.Tx) error {

		bucket := tx.Bucket([]byte(blockBucket))

		blockBytes := bucket.Get(it.currentHash)

		block = Deserialize(blockBytes)

		return nil
	})

	if err != nil {
		panic(err)
	}

	// 指向前一个区块
	it.currentHash = block.PrevHash

	return block
}
