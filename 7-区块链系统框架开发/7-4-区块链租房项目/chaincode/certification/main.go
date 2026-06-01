package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-protos-go/peer"
)

type House struct {
}

func (this *House) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

func (this *House) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	function, parameters := stub.GetFunctionAndParameters()

	if function == "check" {
		return this.check(stub, parameters)
	}else if function=="add"{
		return this.add(stub, parameters)
	}
	return shim.Error("Invalid Smart Contract function name")
}

func (this *House) check(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	// 房屋认证
	// 接收:房产证编号 身份证号
	// 回复:true:true 房产证与身份证的匹配结果:是否可以用于出租

	houseId := args[0]
	id := args[1]

	data, err := stub.GetState(houseId)
	if err != nil {
		return shim.Error(err.Error())
	}

	// data 数据结构:  身份证号:是否可以出租
	var result string

	if data != nil {
		var str string = string(data[:])
		split := strings.Split(str, ":")
		if split[0] == id {
			result = "true"
		} else {
			result = "false"
		}

		result = result + ":" + split[1]
		return shim.Success([]byte(result))
	}

	return shim.Success([]byte("false:false"))
}

func (this *House) add(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	// 接收数据: 房产证号(key)  身份证号 : 是否可以用于出租(value)

	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}

	houseId := args[0]
	id := args[1]
	record := args[2]

	err := stub.PutState(houseId, []byte(id+":"+record))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func main() {
	cc := new(House)
	ccid := os.Getenv("CHAINCODE_ID")
	addr := os.Getenv("CHAINCODE_SERVER_ADDRESS")
	if ccid != "" && addr != "" {
		server := &shim.ChaincodeServer{
			CCID:    ccid,
			Address: addr,
			CC:      cc,
			TLSProps: shim.TLSProperties{
				Disabled: os.Getenv("CHAINCODE_TLS_DISABLED") == "true",
			},
		}
		if err := server.Start(); err != nil {
			fmt.Fprintf(os.Stderr, "chaincode server failed: %v\n", err)
			os.Exit(1)
		}
		return
	}

	if err := shim.Start(cc); err != nil {
		fmt.Fprintf(os.Stderr, "chaincode failed: %v\n", err)
		os.Exit(1)
	}
}
