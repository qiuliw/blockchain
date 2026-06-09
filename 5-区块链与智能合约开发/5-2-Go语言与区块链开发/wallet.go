package main

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
)

type Wallet struct {
	// 私钥
	PrivateKey *ecdsa.PrivateKey
	// 公钥，一般对外传输所以直接使用编码后的
	PublicKey []byte
}

func NewWallet() *Wallet {

	privateKey, err := ecdsa.GenerateKey(
		elliptic.P256(),
		rand.Reader,
	)
	if err != nil {
		return nil
	}

	pubBytes, err := privateKey.PublicKey.Bytes()
	if err != nil {
		return nil
	}

	return &Wallet{
		PrivateKey: privateKey,
		PublicKey:  pubBytes,
	}
}
