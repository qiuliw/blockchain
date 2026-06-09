package main

import (
	"bytes"
	"crypto/ecdh"
	"crypto/rand"
	"crypto/sha256"

	"github.com/btcsuite/btcutil/base58"
	"golang.org/x/crypto/ripemd160"
)

const (
	version        = byte(0x00)
	checksumLength = 4
)

// Wallet 钱包
type Wallet struct {
	PrivateKey []byte // PKCS8 / EC Private Key
	PublicKey  []byte // compressed/uncompressed pubkey
}

// 创建钱包
func NewWallet() (*Wallet, error) {

	curve := ecdh.P256()

	priv, err := curve.GenerateKey(rand.Reader)
	if err != nil {
		return nil, err
	}

	return &Wallet{
		PrivateKey: priv.Bytes(), // 标准字节
		PublicKey:  priv.PublicKey().Bytes(),
	}, nil
}

// 恢复私钥
func (w *Wallet) Private() (*ecdh.PrivateKey, error) {

	curve := ecdh.P256()

	return curve.NewPrivateKey(w.PrivateKey)
}

// HashPubKey
//
// HASH160(pubKey)
// = RIPEMD160(SHA256(pubKey)) 两次hash缩短长度，便于填写转账
func HashPubKey(pubKey []byte) []byte {

	shaHash := sha256.Sum256(pubKey)

	hasher := ripemd160.New()

	_, err := hasher.Write(shaHash[:])
	if err != nil {
		panic(err)
	}

	return hasher.Sum(nil)
}

// Checksum 防止用户输错地址，得hash和pubhash都错才可能。chechsum（pubKeyHash+version)
//
// checksum = SHA256(SHA256(payload))[:4]
func Checksum(payload []byte) []byte {

	first := sha256.Sum256(payload)
	second := sha256.Sum256(first[:])

	return second[:checksumLength]
}

// GetAddress 生成比特币风格地址
func (w *Wallet) GetAddress() string {

	// HASH160(PublicKey)
	pubKeyHash := HashPubKey(w.PublicKey)

	// Version + PubKeyHash
	versionedPayload := append(
		[]byte{version},
		pubKeyHash...,
	)

	// Checksum
	checksum := Checksum(versionedPayload)

	// 25字节数据:
	// 1字节Version
	// 20字节PubKeyHash
	// 4字节Checksum
	fullPayload := append(
		versionedPayload,
		checksum...,
	)

	// Base58编码
	return base58.Encode(fullPayload)
}

// ValidateAddress 验证地址是否合法
func ValidateAddress(address string) bool {

	decoded := base58.Decode(address)

	if len(decoded) < 25 {
		return false
	}

	actualChecksum :=
		decoded[len(decoded)-checksumLength:]

	version := decoded[0]

	pubKeyHash :=
		decoded[1 : len(decoded)-checksumLength]

	targetChecksum := Checksum(
		append([]byte{version}, pubKeyHash...),
	)

	return bytes.Equal(
		actualChecksum,
		targetChecksum,
	)
}
