package main

import (
	"bytes"
	"crypto/cipher"
	"crypto/des"
	"fmt"
)

// des 的 CBC 加密
// 填充。如果最后一个分组字节数不够，填充
// 分组

// 填充函数，使用 PKCS#7 填充方式
func PKCS7Padding(data []byte, blockSize int) []byte {
	padding := blockSize - len(data)%blockSize

	padText := bytes.Repeat(
		[]byte{byte(padding)},
		padding,
	)

	return append(data, padText...)
}

// 删除填充函数，使用 PKCS#7 填充方式
func PKCS7UnPadding(data []byte) []byte {
	n := len(data)

	if n == 0 {
		return nil
	}

	padding := int(data[n-1])

	return data[:n-padding]
}

// DES-CBC 加密
func DesCbcEncrypt(data, key, iv []byte) ([]byte, error) {
	// 创建 DES 加密器
	block, err := des.NewCipher(key)
	if err != nil {
		return nil, err
	}

	// 填充数据
	data = PKCS7Padding(data, block.BlockSize())

	// CBC 分组加密
	ciphertext := make([]byte, len(data))     // 创建密文切片
	mode := cipher.NewCBCEncrypter(block, iv) // 创建 CBC 加密器
	mode.CryptBlocks(ciphertext, data)        // 返回密文

	return ciphertext, nil
}

// DES-CBC 解密
func DesCbcDecrypt(ciphertext, key, iv []byte) ([]byte, error) {
	// 创建 DES 加密器
	block, err := des.NewCipher(key)
	if err != nil {
		return nil, err
	}

	// CBC 分组解密
	plaintext := make([]byte, len(ciphertext)) // 创建明文切片
	mode := cipher.NewCBCDecrypter(block, iv)  // 创建 CBC 解密器
	mode.CryptBlocks(plaintext, ciphertext)    // 解密

	// 删除填充
	plaintext = PKCS7UnPadding(plaintext)

	return plaintext, nil
}

func main() {
	key := []byte("12345678") // DES key 必须 8 字节
	iv := []byte("abcdefgh")  // IV 也必须 8 字节

	plain := []byte("hello world")

	fmt.Println("原文:", string(plain))

	enc, err := DesCbcEncrypt(plain, key, iv)
	if err != nil {
		panic(err)
	}

	fmt.Printf("密文(hex): %x\n", enc)

	dec, err := DesCbcDecrypt(enc, key, iv)
	if err != nil {
		panic(err)
	}

	fmt.Println("解密:", string(dec))
}
