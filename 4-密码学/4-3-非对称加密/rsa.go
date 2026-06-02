package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"os"
)

// 生成 RSA 密钥对
func GenerateRsaKey(bits int) (*rsa.PrivateKey, error) {
	return rsa.GenerateKey(rand.Reader, bits)
}

// 保存私钥
func SavePrivateKey(path string, key *rsa.PrivateKey) error {
	// 将私钥编码为 PKCS#1 DER 格式
	privDER := x509.MarshalPKCS1PrivateKey(key)
	// 组织一个 PEM 块
	block := &pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: privDER,
	}

	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()
	// 将 PEM 块写入文件（base64编码）
	return pem.Encode(file, block)
}

// 保存公钥
func SavePublicKey(path string, key *rsa.PublicKey) error {
	// 将公钥编码为 PKIX DER 格式
	pubDER, err := x509.MarshalPKIXPublicKey(key)
	if err != nil {
		return err
	}
	// PEM 块
	block := &pem.Block{
		Type:  "PUBLIC KEY",
		Bytes: pubDER,
	}

	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	// 将 PEM 块写入文件（base64编码）
	return pem.Encode(file, block)
}

func GenerateAndSaveRSAKeyPair(bits int, privPath, pubPath string) error {
	// 1. 生成密钥
	privateKey, err := GenerateRsaKey(bits)
	if err != nil {
		return err
	}

	// 2. 保存私钥
	if err := SavePrivateKey(privPath, privateKey); err != nil {
		return err
	}

	// 3. 保存公钥
	if err := SavePublicKey(pubPath, &privateKey.PublicKey); err != nil {
		return err
	}

	return nil
}

// 加载私钥
func LoadPrivateKey(path string) (*rsa.PrivateKey, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	block, _ := pem.Decode(data)
	if block == nil || block.Type != "RSA PRIVATE KEY" {
		return nil, errors.New("invalid private key PEM")
	}

	priv, err := x509.ParsePKCS1PrivateKey(block.Bytes)
	if err != nil {
		return nil, err
	}

	return priv, nil
}

// 加载公钥
func LoadPublicKey(path string) (*rsa.PublicKey, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	// PEM 解码
	block, _ := pem.Decode(data)
	if block == nil || block.Type != "PUBLIC KEY" {
		return nil, errors.New("invalid public key PEM")
	}
	// 解析公钥（返回 interface{}）
	pubInterface, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, err
	}
	// 断言为 *rsa.PublicKey
	pub, ok := pubInterface.(*rsa.PublicKey)
	if !ok {
		return nil, errors.New("not RSA public key")
	}

	return pub, nil
}

// 使用公钥加密数据
func EncryptWithPublicKey(msg []byte, pub *rsa.PublicKey) ([]byte, error) {
	label := []byte("")  // 可以为空
	hash := sha256.New() // OAEP 填充需要一个哈希函数，这里使用 SHA-256。其处理密文后也被加密纳入了加密结果的一部分，所以解密只需要匹配的私钥。
	ciphertext, err := rsa.EncryptOAEP(hash, rand.Reader, pub, msg, label)
	if err != nil {
		return nil, err
	}
	return ciphertext, nil
}

// 使用私钥解密数据
func DecryptWithPrivateKey(ciphertext []byte, priv *rsa.PrivateKey) ([]byte, error) {
	label := []byte("")
	hash := sha256.New()

	plaintext, err := rsa.DecryptOAEP(hash, rand.Reader, priv, ciphertext, label)
	if err != nil {
		return nil, err
	}
	return plaintext, nil
}

func main() {
	err := GenerateAndSaveRSAKeyPair(2048, "private.pem", "public.pem")
	if err != nil {
		panic(err)
	}

	fmt.Println("RSA 密钥对已生成")

	priv, err := LoadPrivateKey("private.pem")
	if err != nil {
		panic(err)
	}

	pub, err := LoadPublicKey("public.pem")
	if err != nil {
		panic(err)
	}

	msg := []byte("hello rsa file")

	cipher, err := EncryptWithPublicKey(msg, pub)
	if err != nil {
		panic(err)
	}

	plain, err := DecryptWithPrivateKey(cipher, priv)
	if err != nil {
		panic(err)
	}

	fmt.Println("解密结果:", string(plain))
}
