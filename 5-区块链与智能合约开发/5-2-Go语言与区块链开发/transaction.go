package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/gob"
)

const reward = 12

// Transaction 表示一笔交易
type Transaction struct {
	TXInputs  []TXInput
	TXOutputs []TXOutput
}

// TXInput 表示交易输入
type TXInput struct {
	TXID      []byte // 引用的上一笔交易
	Vout      int    // 输出索引
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

	encoder := gob.NewEncoder(&buffer)
	err := encoder.Encode(tx)
	if err != nil {
		panic(err)
	}

	hash := sha256.Sum256(buffer.Bytes())
	return hash[:]
}

// Coinbase 挖矿交易
// NewCoinbaseTX 挖矿奖励交易(无输入，只输出)
//
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
				Vout:      -1, // 无引用 -1
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

	return tx
}

// NewUTXOTransaction 普通转账
func NewUTXOTransaction(from, to string, amount int64) *Transaction {

	inputs := []TXInput{
		{
			TXID:      []byte("fake-txid"),
			Vout:      0,
			Signature: from,
		},
	}

	outputs := []TXOutput{
		{
			Value:      amount,
			PubKeyHash: to,
		},
		{
			Value:      100 - amount,
			PubKeyHash: from,
		},
	}

	tx := &Transaction{
		TXInputs:  inputs,
		TXOutputs: outputs,
	}

	return tx
}
