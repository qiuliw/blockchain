package main

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"math/big"
)

// ECDSA 签名
func SignatureEcdsa(plainText []byte, priv *ecdsa.PrivateKey) ([]byte, error) {
	// 1. 算哈希（和 RSA 完全一样）
	hash := sha256.Sum256(plainText)

	// 2. 私钥签名（只换了函数，逻辑不变）
	r, s, err := ecdsa.Sign(rand.Reader, priv, hash[:])
	if err != nil {
		return nil, err
	}

	// 3. 把 r + s 拼接成签名字节（ECDSA 固定格式）
	signature := append(r.Bytes(), s.Bytes()...)
	return signature, nil
}

// ECDSA 验签
func VerifySignatureEcdsa(plainText, signature []byte, pub *ecdsa.PublicKey) bool {
	// 1. 算哈希（一样）
	hash := sha256.Sum256(plainText)

	// 2. 拆分签名为 r 和 s(r 和 s 的长度由公钥 / 私钥的曲线参数提前约定好的，接口可以直接获取)
	keySize := pub.Params().BitSize / 8
	r := big.NewInt(0).SetBytes(signature[:keySize])
	s := big.NewInt(0).SetBytes(signature[keySize:])

	// 3. 公钥验签（返回 true/false）
	return ecdsa.Verify(pub, hash[:], r, s)
}

// 生成 ECDSA 密钥对（secp256r1）
func GenerateEcdsaKey() (*ecdsa.PrivateKey, *ecdsa.PublicKey, error) {
	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return nil, nil, err
	}
	return priv, &priv.PublicKey, nil
}

func TestEcdsaSign() {
	priv, pub, err := GenerateEcdsaKey()
	if err != nil {
		panic(err)
	}

	msg := []byte("hello ecdsa")

	signature, err := SignatureEcdsa(msg, priv)
	if err != nil {
		panic(err)
	}

	valid := VerifySignatureEcdsa(msg, signature, pub)
	if valid {
		println("验证成功")
	} else {
		println("验证失败")
	}
}
