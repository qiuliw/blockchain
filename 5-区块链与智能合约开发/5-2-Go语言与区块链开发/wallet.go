package main

import (
	"bytes"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"math/big"

	"github.com/btcsuite/btcutil/base58"
	"golang.org/x/crypto/ripemd160"
)

const (
	version        = byte(0x00)
	checksumLength = 4
)

// Wallet 钱包
type Wallet struct {
	PrivateKey []byte // 私钥 D 值
	PublicKey  []byte // 公钥 X||Y 字节
}

// 创建钱包
func NewWallet() (*Wallet, error) {
	curve := elliptic.P256()

	priv, err := ecdsa.GenerateKey(curve, rand.Reader)
	if err != nil {
		return nil, err
	}

	pubKey := append(priv.PublicKey.X.Bytes(), priv.PublicKey.Y.Bytes()...)

	return &Wallet{
		PrivateKey: priv.D.Bytes(),
		PublicKey:  pubKey,
	}, nil
}

// Private 恢复 ECDSA 私钥
func (w *Wallet) Private() (*ecdsa.PrivateKey, error) {
	curve := elliptic.P256()
	d := new(big.Int).SetBytes(w.PrivateKey)
	x, y := curve.ScalarBaseMult(w.PrivateKey)

	return &ecdsa.PrivateKey{
		PublicKey: ecdsa.PublicKey{Curve: curve, X: x, Y: y},
		D:         d,
	}, nil
}

// HashPubKey
// HASH160(pubKey) = RIPEMD160(SHA256(pubKey))
func HashPubKey(pubKey []byte) []byte {
	shaHash := sha256.Sum256(pubKey)

	hasher := ripemd160.New()
	_, err := hasher.Write(shaHash[:])
	if err != nil {
		panic(err)
	}

	return hasher.Sum(nil)
}

// Checksum 计算地址校验值
func Checksum(payload []byte) []byte {
	first := sha256.Sum256(payload)
	second := sha256.Sum256(first[:])

	return second[:checksumLength]
}

// Base58Decode 解码地址
func Base58Decode(input string) []byte {
	return base58.Decode(input)
}

// GetAddress 生成比特币风格地址
func (w *Wallet) GetAddress() string {
	pubKeyHash := HashPubKey(w.PublicKey)
	versionedPayload := append([]byte{version}, pubKeyHash...)
	checksum := Checksum(versionedPayload)
	fullPayload := append(versionedPayload, checksum...)

	return base58.Encode(fullPayload)
}

// ValidateAddress 验证地址是否合法
func ValidateAddress(address string) bool {
	decoded := base58.Decode(address)
	if len(decoded) < 25 {
		return false
	}

	actualChecksum := decoded[len(decoded)-checksumLength:]
	version := decoded[0]
	pubKeyHash := decoded[1 : len(decoded)-checksumLength]
	targetChecksum := Checksum(append([]byte{version}, pubKeyHash...))

	return bytes.Equal(actualChecksum, targetChecksum)
}

// GetPubKeyHashFromAddress 解析地址得到公钥哈希
func GetPubKeyHashFromAddress(address string) []byte {
	decoded := Base58Decode(address)
	if len(decoded) < 25 {
		return nil
	}

	return decoded[1 : len(decoded)-checksumLength]
}
