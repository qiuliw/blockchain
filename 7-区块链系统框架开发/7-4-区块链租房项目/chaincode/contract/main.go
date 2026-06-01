package main

import (
	"fmt"
	"os"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-protos-go/peer"
)


type Contract struct {
}

func (this *Contract) Init(stub shim.ChaincodeStubInterface) peer.Response  {
	return shim.Success(nil)
}

func (this *Contract) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	function, parameters := stub.GetFunctionAndParameters()

	if function=="get"{
		return this.get(stub, parameters)

	}else if function== "set"{
		return this.set(stub,parameters)
	}
	return shim.Error("Invalid Smart Contract function name.")
}


func (this * Contract) get(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	key:=args[0]
	data, err := stub.GetState(key)
	if err != nil{
		return shim.Error(err.Error())
	}
	if data == nil{
		return shim.Error("Data not Available")
	}
	return shim.Success(data)
}

func (this *Contract) set(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments.Expecting 2")
	}

	key := args[0]
	value := args[1]
	err := stub.PutState(key, []byte(value))
	if err !=nil{
		return shim.Error(fmt.Sprintf("key:%s,value:%s,error:%s",key,value,err.Error()))
	}
	return shim.Success(nil)
}

func main() {
	cc := new(Contract)
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
