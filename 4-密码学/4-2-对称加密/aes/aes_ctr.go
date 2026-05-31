package main

import (
	"crypto/aes"
	"crypto/cipher"
	"fmt"
)

func AesCtrEncrypt(plaintext, key, iv []byte) ([]byte, error) {
	// 创建 AES 加密器
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	if len(iv) != aes.BlockSize {
		return nil, fmt.Errorf("iv must be %d bytes", aes.BlockSize)
	}
	// 创建密文切片
	ciphertext := make([]byte, len(plaintext))
	// 创建 CTR 加密器
	stream := cipher.NewCTR(block, iv)
	// 加密
	stream.XORKeyStream(ciphertext, plaintext)

	return ciphertext, nil
}

func AesCtrDecrypt(ciphertext, key, iv []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	if len(iv) != aes.BlockSize {
		return nil, fmt.Errorf("iv must be %d bytes", aes.BlockSize)
	}

	plaintext := make([]byte, len(ciphertext))

	stream := cipher.NewCTR(block, iv)
	// CTR 模式加密和解密是一样的，XOR 回去
	stream.XORKeyStream(plaintext, ciphertext)

	return plaintext, nil
}

func main() {
	key := []byte("1234567890123456")

	// 外部传入 IV（必须 16 字节）
	iv := []byte("abcdefghijklmnop")

	plain := []byte("hello world AES CTR mode")

	fmt.Println("原文:", string(plain))

	enc, err := AesCtrEncrypt(plain, key, iv)
	if err != nil {
		panic(err)
	}

	fmt.Printf("密文(hex): %x\n", enc)

	dec, err := AesCtrDecrypt(enc, key, iv)
	if err != nil {
		panic(err)
	}

	fmt.Println("解密:", string(dec))
}
