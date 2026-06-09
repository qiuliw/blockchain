package main

import (
	"bytes"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"encoding/gob"
	"encoding/hex"
	"fmt"
	"log"
	"math/big"
)

const reward = 12

// Transaction 表示一笔交易
type Transaction struct {
	ID   []byte
	Vin  []TXInput
	Vout []TXOutput
}

// TXInput 表示交易输入
type TXInput struct {
	Txid      []byte
	Vout      int    // 引用的output的索引
	Signature []byte // 签名，确认其为公钥持有者
	PubKey    []byte // 公钥
}

// TXOutput 表示交易输出
type TXOutput struct {
	Value      int64
	PubKeyHash []byte
}

// Serialize 序列化交易
func (tx *Transaction) Serialize() []byte {
	var buffer bytes.Buffer

	encoder := gob.NewEncoder(&buffer)
	err := encoder.Encode(tx)
	if err != nil {
		log.Panic(err)
	}

	return buffer.Bytes()
}

// Hash 计算交易 ID（txid）
func (tx *Transaction) Hash() []byte {
	var buffer bytes.Buffer

	tmpTx := *tx
	tmpTx.ID = []byte{}

	encoder := gob.NewEncoder(&buffer)
	err := encoder.Encode(tmpTx)
	if err != nil {
		panic(err)
	}

	hash := sha256.Sum256(buffer.Bytes())
	return hash[:]
}

// 判断是否为挖矿交易
func (tx *Transaction) IsCoinbase() bool {
	return len(tx.Vin) == 1 && len(tx.Vin[0].Txid) == 0 && tx.Vin[0].Vout == -1
}

// TrimmedCopy 创建一个用于签名的精简交易副本，避免无关属性影响交易签名与自引用
func (tx *Transaction) TrimmedCopy() Transaction {
	var inputs []TXInput
	var outputs []TXOutput

	for _, vin := range tx.Vin {
		inputs = append(inputs, TXInput{Txid: vin.Txid, Vout: vin.Vout, Signature: nil, PubKey: nil})
	}

	for _, vout := range tx.Vout {
		outputs = append(outputs, TXOutput{Value: vout.Value, PubKeyHash: vout.PubKeyHash})
	}

	txCopy := Transaction{ID: tx.ID, Vin: inputs, Vout: outputs}

	return txCopy
}

// Sign 对交易输入进行签名
func (tx *Transaction) Sign(privKey ecdsa.PrivateKey, prevTXs map[string]Transaction) {
	if tx.IsCoinbase() {
		return
	}

	for _, vin := range tx.Vin {
		if prevTXs[hex.EncodeToString(vin.Txid)].ID == nil {
			log.Panic("ERROR: Previous transaction is not correct")
		}
	}

	txCopy := tx.TrimmedCopy() // 创建一个精简交易副本

	for inID, vin := range txCopy.Vin {
		prevTx := prevTXs[hex.EncodeToString(vin.Txid)] // 获取上一笔交易
		txCopy.Vin[inID].Signature = nil                // 将签名置空
		// 签名时，input 的 PubKey = output 的 PubKeyHash，表明授权这个锁定的解锁
		txCopy.Vin[inID].PubKey = prevTx.Vout[vin.Vout].PubKeyHash

		dataToSign := fmt.Sprintf("%x\n", txCopy)

		r, s, err := ecdsa.Sign(rand.Reader, &privKey, []byte(dataToSign))
		if err != nil {
			log.Panic(err)
		}

		signature := append(r.Bytes(), s.Bytes()...)

		tx.Vin[inID].Signature = signature
	}
}

// Verify 验证交易输入签名（需提供当前交易所引用的所有上一笔交易（UTXO来源）的集合）
func (tx *Transaction) Verify(prevTXs map[string]Transaction) bool {
	if tx.IsCoinbase() {
		return true
	}

	for _, vin := range tx.Vin {
		if prevTXs[hex.EncodeToString(vin.Txid)].ID == nil {
			log.Panic("ERROR: Previous transaction is not correct")
		}
	}

	txCopy := tx.TrimmedCopy()
	curve := elliptic.P256()

	for inID, vin := range tx.Vin {
		prevTx := prevTXs[hex.EncodeToString(vin.Txid)]
		txCopy.Vin[inID].Signature = nil
		txCopy.Vin[inID].PubKey = prevTx.Vout[vin.Vout].PubKeyHash

		r := big.Int{}
		s := big.Int{}
		sigLen := len(vin.Signature)
		r.SetBytes(vin.Signature[:(sigLen / 2)])
		s.SetBytes(vin.Signature[(sigLen / 2):])

		x := big.Int{}
		y := big.Int{}
		keyLen := len(vin.PubKey)
		x.SetBytes(vin.PubKey[:(keyLen / 2)])
		y.SetBytes(vin.PubKey[(keyLen / 2):])

		dataToVerify := fmt.Sprintf("%x\n", txCopy)

		rawPubKey := ecdsa.PublicKey{Curve: curve, X: &x, Y: &y}
		if ecdsa.Verify(&rawPubKey, []byte(dataToVerify), &r, &s) == false {
			return false
		}

		txCopy.Vin[inID].PubKey = nil
	}

	return true
}

// NewCoinbaseTX 挖矿奖励交易(无输入，只输出)
func NewCoinbaseTX(to string, data string) *Transaction {
	if data == "" {
		data = "coinbase reward"
	}

	tx := &Transaction{
		Vin: []TXInput{
			{
				Txid:      []byte{},
				Vout:      -1,
				Signature: nil,
				PubKey:    []byte(data), // 矿工可自定义
			},
		},
		Vout: []TXOutput{
			*NewTXOutput(reward, to),
		},
	}

	tx.ID = tx.Hash()

	return tx
}

// NewUTXOTransaction 创建普通转账交易
func NewUTXOTransaction(wallet *Wallet, to string, amount int64, bc *Blockchain) *Transaction {
	from := wallet.GetAddress()
	utxos, total := bc.FindSpendableOutputs(from, amount)

	if total < amount {
		fmt.Printf("余额不足, current=%d, need=%d\n", total, amount)
		return nil
	}

	var inputs []TXInput
	var outputs []TXOutput

	for _, utxo := range utxos {
		inputs = append(inputs, TXInput{
			Txid:      utxo.ID,
			Vout:      utxo.Index,
			Signature: nil,
			PubKey:    wallet.PublicKey,
		})
	}

	outputs = append(outputs, *NewTXOutput(amount, to))

	if total > amount {
		outputs = append(outputs, *NewTXOutput(total-amount, from))
	}

	tx := &Transaction{
		Vin:  inputs,
		Vout: outputs,
	}

	tx.ID = tx.Hash()
	privKey, err := wallet.Private()
	if err != nil {
		panic(err)
	}
	bc.SignTransaction(tx, privKey)

	return tx
}

// 锁定输出
func (out *TXOutput) Lock(address string) {
	pubKeyHash := Base58Decode(address)
	pubKeyHash = pubKeyHash[1 : len(pubKeyHash)-checksumLength]
	out.PubKeyHash = pubKeyHash
}

// 判断输出是否被指定的公钥哈希所锁定
func (out *TXOutput) IsLockedWithKey(pubKeyHash []byte) bool {
	return bytes.Compare(out.PubKeyHash, pubKeyHash) == 0
}

func NewTXOutput(value int64, address string) *TXOutput {
	txo := &TXOutput{Value: value}
	txo.Lock(address)
	return txo
}
