package main

import (
	"bytes"
	"encoding/gob"
	"fmt"
	"os"
)

// 钱包数据持久化保存的文件名
const walletFile = "wallet.dat"

// Wallets 钱包管理器
// 管理多个钱包，用地址作为 key 存储所有钱包
type Wallets struct {
	Wallets map[string]*Wallet // key：钱包地址，value：钱包对象
}

// NewWallets 创建钱包集合
// 作用：初始化钱包管理器，并从本地文件加载已保存的钱包
func NewWallets() *Wallets {

	// 初始化 Wallets 结构体，创建空的钱包 map
	ws := &Wallets{
		Wallets: make(map[string]*Wallet),
	}

	// 尝试从本地文件加载钱包（如果文件不存在则忽略）
	_ = ws.LoadFromFile()

	return ws
}

// CreateWallet 创建钱包
// 作用：生成一个新钱包，保存到钱包管理器中，并返回钱包地址
func (ws *Wallets) CreateWallet() string {

	// 创建一个新钱包（内部会生成公私钥对）
	wallet, err := NewWallet()
	if err != nil {
		fmt.Printf("Error creating wallet: %v\n", err)
		return ""
	}

	// 从钱包中获取地址
	address := wallet.GetAddress()

	// 将新钱包存入 map，地址作为 key
	ws.Wallets[address] = wallet

	// 更新持久化
	err = ws.SaveToFile()
	if err != nil {
		fmt.Printf("Error saving wallet: %v\n", err)
	}

	// 返回新生成的钱包地址
	return address
}

// GetWallet 根据地址获取钱包
// 作用：通过钱包地址查找对应的钱包对象
func (ws *Wallets) GetWallet(address string) *Wallet {

	// 从 map 中查找
	wallet, ok := ws.Wallets[address]
	if !ok {
		return nil // 没找到返回 nil
	}

	return wallet // 找到返回钱包
}

// GetAddresses 获取所有地址
// 作用：返回当前钱包管理器中所有钱包的地址列表
func (ws *Wallets) GetAddresses() []string {

	var addresses []string

	// 遍历钱包 map，把所有地址收集起来
	for address := range ws.Wallets {
		addresses = append(addresses, address)
	}

	return addresses
}

// SaveToFile 保存钱包文件
// 作用：将内存中的所有钱包序列化，保存到本地 wallet.dat 文件
func (ws *Wallets) SaveToFile() error {

	var buf bytes.Buffer
	enc := gob.NewEncoder(&buf)

	if err := enc.Encode(ws); err != nil {
		return err
	}

	return os.WriteFile(walletFile, buf.Bytes(), 0644)
}

// LoadFromFile 从文件加载钱包
// 作用：读取本地 wallet.dat 文件，反序列化为内存中的钱包对象
// func (ws *Wallets) LoadFromFile() error {

// 	// 如果文件不存在，直接返回，不报错（第一次运行时文件还没创建）
// 	if _, err := os.Stat(walletFile); os.IsNotExist(err) {
// 		return nil
// 	}

// 	// 读取文件所有字节
// 	fileContent, err := os.ReadFile(walletFile)
// 	if err != nil {
// 		return err
// 	}

// 	// 声明用于接收反序列化结果的对象
// 	var wallets Wallets

// 	// 要先 Register 注册 interface类型,让 gob 反射获取类型信息，知晓如何反序列化
// 	// 2018/10/18 17:20:40 gob: type not registered for interface: elliptic.p256Curve
// 	// panic: gob: type not registered for interface: elliptic.p256Curve
// 	gob.Register(elliptic.P256())

// 	// gob: type elliptic.nistCurve[*crypto/internal/fips140/nistec.P256Point] has no exported fields
// 	// Go 新版把内部椭圆曲线结构体改成了非导出字段，gob 无法直接序列化。

// 	// 创建解码器，读取文件字节流
// 	decoder := gob.NewDecoder(
// 		bytes.NewReader(fileContent),
// 	)

// 	// 反序列化到 wallets 对象
// 	err = decoder.Decode(&wallets)
// 	if err != nil {
// 		return err
// 	}

// 	// 将加载出来的钱包覆盖到当前钱包管理器
// 	ws.Wallets = wallets.Wallets

// 	return nil
// }

// 从文件加载钱包
func (ws *Wallets) LoadFromFile() error {

	if _, err := os.Stat(walletFile); os.IsNotExist(err) {
		return nil
	}

	data, err := os.ReadFile(walletFile)
	if err != nil {
		return err
	}

	var wallets Wallets

	dec := gob.NewDecoder(bytes.NewReader(data))

	if err := dec.Decode(&wallets); err != nil {
		return err
	}

	ws.Wallets = wallets.Wallets
	return nil
}
