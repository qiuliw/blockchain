package main

import (
	"bytes"
	"crypto/ecdsa"
	"encoding/hex"
	"fmt"

	"go.etcd.io/bbolt"
)

// 引入区块链
type Blockchain struct {
	// blocks []*Block // 区块数组
	db   *bbolt.DB
	tail []byte // 存储最后一个区块的hash值
}

const blockChainDB = "blockchain.db"
const blockBucket = "blocks"
const lastHashKey = "LastHash"
const genesisInfo = "创世信息"

// 创建一个区块链
func NewBlockchain(to string) *Blockchain {

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
			genesisBlock := GenesisBlock(to)

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

	return &Blockchain{
		db:   db,
		tail: tail,
	}
}

// 生成创世区块
func GenesisBlock(to string) *Block {

	coinbase := NewCoinbaseTX(to, genesisInfo)
	return NewBlock([]*Transaction{coinbase}, []byte{})
}

// 查找指定交易
func (bc *Blockchain) FindTransaction(id []byte) (*Transaction, error) {
	it := bc.NewIterator()

	for {
		block := it.Next()
		for _, tx := range block.Transactions {
			if bytes.Equal(tx.ID, id) {
				return tx, nil
			}
		}

		if len(block.PrevHash) == 0 {
			break
		}
	}

	return nil, fmt.Errorf("transaction %x not found", id)
}

// 签名交易
func (bc *Blockchain) SignTransaction(tx *Transaction, privKey *ecdsa.PrivateKey) {
	prevTXs := make(map[string]Transaction)

	for _, vin := range tx.Vin {
		prevTx, err := bc.FindTransaction(vin.Txid)
		if err != nil {
			panic(err)
		}
		prevTXs[hex.EncodeToString(prevTx.ID)] = *prevTx
	}

	tx.Sign(*privKey, prevTXs)
}

// 验证交易合法性
func (bc *Blockchain) VerifyTransaction(tx *Transaction) bool {
	if tx.IsCoinbase() {
		return true
	}

	prevTXs := make(map[string]Transaction)

	for _, vin := range tx.Vin {
		prevTx, err := bc.FindTransaction(vin.Txid)
		if err != nil {
			panic(err)
		}
		prevTXs[hex.EncodeToString(prevTx.ID)] = *prevTx
	}

	return tx.Verify(prevTXs)
}

// 添加区块
func (bc *Blockchain) AddBlock(txs []*Transaction) {

	for _, tx := range txs {
		if len(tx.ID) == 0 {
			tx.ID = tx.Hash()
		}
		if bc.VerifyTransaction(tx) != true {
			panic("ERROR: Invalid transaction")
		}
	}

	// 动态计算前一个区块的哈希
	prevHash := bc.tail

	// 创建新区块
	newBlock := NewBlock(txs, prevHash)

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
func (bc *Blockchain) PrintChain() {

	it := bc.NewIterator()

	for {

		block := it.Next()

		fmt.Printf("Version: %d\n", block.Version)

		fmt.Printf("PrevHash: %x\n", block.PrevHash)

		fmt.Printf("Hash: %x\n", block.Hash())

		fmt.Printf("Timestamp: %d\n", block.Timestamp)

		fmt.Printf("Nonce: %d\n", block.Nonce)

		fmt.Printf("Difficulty: %d\n", block.Difficulty)

		if len(block.Transactions) > 0 && len(block.Transactions[0].Vin) > 0 {
			fmt.Printf("Data: %x\n", block.Transactions[0].Vin[0].PubKey)
		}

		// 工作量合法性验证
		pow := NewProofOfWork(block)
		fmt.Printf("Validate: %t\n", pow.Validate())

		fmt.Println()

		// 当前创世区块
		if len(block.PrevHash) == 0 {
			break
		}
	}
}

// 统计所关联的可用 UTXOs
// input 是output 配对的出口，且指向output
// 统计所关联的可用 UTXOs（只查余额，极简版）
// 正确版本：逆序区块 + 内部正序交易
// 先处理 Output → 后处理 Input
func (bc *Blockchain) FindUTXO(address string) []TXOutput {
	var utxos []TXOutput

	// 已花费的输出记录
	spentOutputs := make(map[string]map[int64]bool)

	it := bc.NewIterator()

	// 区块正序（output被缓冲，可能跨区未配对）output可能永不配对被缓冲
	// 交易正序 对input判断配对，对output判断无意义，因为之后才会出现。（output缓冲块间，可能之后被消费或余下，input一定被消耗光无缓冲）
	// 交易逆序 对output判断配对，对input判断无意义，因为之后才会出现。（input缓冲块内，之后匹配output，一定被消耗光） 对于 input，总存在output在前，区间结束，之前的output总被遍历完。

	// 区块逆序（input被缓冲，可能跨区未匹配）output可能永不配对被缓冲
	// 缓冲input，可能之后output，指向上一区块
	// 交易正序 对input判断配对，对output判断无意义，因为之后才会出现（output缓冲块间，之后input匹配，可能余下。input可能未匹配完）
	// 交易逆序 对output判断配对，对input判断无意义，因为之后才会出现（input缓冲块间，可能之后才匹配）

	// 缓冲先出现的一个，在另一个判断匹配。
	// output总被缓冲，因为可能用不被配对。

	// 总之，可以都缓冲
	for {
		// 区块 逆序
		block := it.Next()

		// 交易：正序遍历
		for _, tx := range block.Transactions {
			txID := string(tx.ID)
			pubKeyHash := GetPubKeyHashFromAddress(address)

			// 收集 output
			for idx, out := range tx.Vout {
				// 只看属于目标地址的
				if out.IsLockedWithKey(pubKeyHash) {
					// 判断是否已经被花掉
					spent := false
					if spentOutputs[txID] != nil {
						spent = spentOutputs[txID][int64(idx)]
					}
					// 未花费 → 加入余额
					if !spent {
						utxos = append(utxos, out)
					}
				}
			}

			if tx.IsCoinbase() {
				continue
			}

			// 处理 INPUT
			// 只有 input 指向 output。要遍历 input 判断是否指向 output
			for _, in := range tx.Vin {

				refTxID := string(in.Txid)
				index := in.Vout
				if spentOutputs[refTxID] == nil {
					spentOutputs[refTxID] = make(map[int64]bool)
				}
				// 标记：这个 Output 已经被花了
				spentOutputs[refTxID][int64(index)] = true
			}
		}

		// 创世块结束
		if len(block.PrevHash) == 0 {
			break
		}
	}

	return utxos
}
