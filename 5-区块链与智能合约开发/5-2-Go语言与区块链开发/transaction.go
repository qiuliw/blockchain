package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/gob"
	"fmt"
)

const reward = 12

// Transaction 表示一笔交易
type Transaction struct {
	TXID      []byte
	TXInputs  []TXInput
	TXOutputs []TXOutput
}

// TXInput 表示交易输入
type TXInput struct {
	TXID      []byte // 引用的上一笔交易
	Index     int64  // 引用上一笔交易中的第几个 Output（输出）
	Signature string // 简化版解锁脚本
}

// TXOutput 表示交易输出
type TXOutput struct {
	Value      int64
	PubKeyHash string // 简化版锁定脚本
}

// Hash 计算交易 ID（txid）
func (tx *Transaction) Hash() []byte {
	var buffer bytes.Buffer

	// 交易ID不应包含自身字段，否则无法确定txid与tx内容之间的稳定关系
	tmpTx := *tx
	tmpTx.TXID = []byte{}

	encoder := gob.NewEncoder(&buffer)
	err := encoder.Encode(&tmpTx)
	if err != nil {
		panic(err)
	}

	hash := sha256.Sum256(buffer.Bytes())
	return hash[:]
}

// 判断是否为挖矿交易
func (tx *Transaction) IsCoinbase() bool {
	return len(tx.TXInputs) == 1 && len(tx.TXInputs[0].TXID) == 0 && tx.TXInputs[0].Index == -1
}

// Coinbase 挖矿交易
// NewCoinbaseTX 挖矿奖励交易(无输入，只输出)
// data 自由数据
//
//	    由于挖矿无需指定签名，所以允许矿工自由填写数据，一般填写矿池名字
//		写区块高度（BIP34之后强制）
//
// to 接收奖励者
func NewCoinbaseTX(to string, data string) *Transaction {
	// 挖矿交易的特点
	// 只有一个input
	// 无需引用交易id
	// 无需引用index

	if data == "" {
		data = "coinbase reward"
	}

	tx := &Transaction{
		TXInputs: []TXInput{
			{
				TXID:      []byte{},
				Index:     -1, // 无引用 -1
				Signature: data,
			},
		},
		TXOutputs: []TXOutput{
			{
				Value:      reward,
				PubKeyHash: to,
			},
		},
	}

	tx.TXID = tx.Hash()

	return tx
}

// 创建普通转账交易
func NewTransaction(
	from string,
	to string,
	amount int64,
	bc *BlockChain,
) *Transaction {

	// 查找需要的UTXO
	utxos, total := bc.FindNeedUTXOs(
		from,
		amount,
	)

	// 余额不足
	if total < amount {
		fmt.Printf(
			"余额不足, current=%d, need=%d\n",
			total,
			amount,
		)
		return nil
	}

	var inputs []TXInput
	var outputs []TXOutput

	// 构造 Inputs
	for _, utxo := range utxos {

		inputs = append(inputs, TXInput{
			TXID:      utxo.TXID,
			Index:     utxo.Index,
			Signature: from,
		})
	}

	// 收款输出
	outputs = append(outputs, TXOutput{
		Value:      amount,
		PubKeyHash: to,
	})

	// 找零输出
	if total > amount {

		outputs = append(outputs, TXOutput{
			Value:      total - amount,
			PubKeyHash: from,
		})
	}

	tx := &Transaction{
		TXInputs:  inputs,
		TXOutputs: outputs,
	}

	tx.TXID = tx.Hash()

	return tx
}
