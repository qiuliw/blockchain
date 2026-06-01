package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

func GenerateHmac(plainText, key []byte) []byte {
	// 创建hash接口，指定需要使用的hash算法和密钥
	h := hmac.New(sha256.New, key)
	h.Write(plainText)
	return h.Sum(nil)
}

func VerifyHmac(plainText, key, hmacToCompare []byte) bool {
	expectedHmac := GenerateHmac(plainText, key)
	return hmac.Equal(expectedHmac, hmacToCompare)
}

func main() {

	msg := []byte("hello world")
	key := []byte("secret")

	hmac := GenerateHmac(msg, key)

	fmt.Printf("hmac hex: %s\n", hex.EncodeToString(hmac))
	// 消息认证中，发送者和接收者的密钥不能泄露，否则攻击者可以伪造消息，中间人攻击等。
	if VerifyHmac(msg, key, hmac) {
		fmt.Println("验证成功")
	} else {
		fmt.Println("验证失败")
	}
}
