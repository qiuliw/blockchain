package main

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type Test struct {
	// 测试区块蓝数据的读和写
}

func (this *Test) Init(stub shim.ChaincodeStubInterface) peer.Response  {
	// 仅执行一次,初始化工作
	return shim.Success(nil)
}

func (this *Test) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	// 入口,更新 添加 查询都可以走这个方法
	// 依据传递的数据区分调用的方法
	// 传递:调用方法的名称(get  set)
	// 传递:依据不同的方法传递参数( get key)(set key value)
	// 使用ChaincodeStubInterface的GetFunctionAndParameters
	// 约定:Parameters,如果是get方法index为0中存储key,如果是set方法index为0中存储key,1中存储value

	function, parameters := stub.GetFunctionAndParameters()

	if function=="get"{
		return this.get(stub,parameters[0])

	}else if function== "set"{
		return this.set(stub,parameters[0],[]byte(parameters[1]))
	}

	// 方法参数传递错误
	return shim.Error("Invalid Smart Contract function name.")
}

/*
	读取数据:
	读取是一条依据key获取到的内容
 */
func (this * Test) get(stub shim.ChaincodeStubInterface,key string) peer.Response {

	// 读数据
	// 读数据的结果处理:error  nil
	// 返回读取数据

	data, err := stub.GetState(key)

	// 处理异常
	if err != nil{
		return shim.Error(err.Error())
	}

	// 处理nil的data
	if data == nil{
		// 数据在ledger中不存在
		return shim.Error("Data not Available")
	}


	return shim.Success(data)
}

/*
	写数据方法
 */
func (this *Test) set(stub shim.ChaincodeStubInterface,key string,value []byte) peer.Response {

	err := stub.PutState(key, value)

	if err !=nil{
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func main() {
	shim.Start(new(Test))
}
