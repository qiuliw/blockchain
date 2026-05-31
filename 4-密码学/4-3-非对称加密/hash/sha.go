package main

import (
	"crypto/md5"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

func main() {
	data := "hello world"

	// sha256 直接计算
	hash := sha256.Sum256([]byte(data))

	fmt.Println("原始字节:", hash)
	fmt.Println("十六进制:", hex.EncodeToString(hash[:]))

	// md5 分批
	h := md5.New()

	h.Write([]byte("hello "))
	h.Write([]byte("world"))

	sum := h.Sum(nil)

	fmt.Printf("md5:%x\n", sum)
}
