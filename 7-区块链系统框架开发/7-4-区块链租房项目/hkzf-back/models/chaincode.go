package models

import (
	"github.com/hyperledger/fabric-sdk-go/api/apitxn"
	"github.com/hyperledger/fabric-sdk-go/def/fabapi"
	"github.com/astaxie/beego"
)

type ChainCodeSpec struct {
	client apitxn.ChannelClient
	chaincodeID string
}

func Initialize(channelId,chainCodeId,userId,conf string)(*ChainCodeSpec,error){
	config := beego.AppConfig.String(conf)
	sdk, err := getSDK(config)
	if err !=nil{
		return nil,err
	}

	client, err := sdk.NewChannelClient(channelId, userId)
	if err !=nil{
		return nil,err
	}

	return &ChainCodeSpec{client,chainCodeId},nil

}

func (this *ChainCodeSpec) ChainCodeQuery(function string,args [][]byte) (response []byte,err error)  {
	request := apitxn.QueryRequest{this.chaincodeID, function, args}
	return this.client.Query(request)
}

func (this *ChainCodeSpec) ChainCodeUpdate(function string,args [][]byte) (response []byte,err error)  {
	request := apitxn.ExecuteTxRequest{ChaincodeID: this.chaincodeID, Fcn: function, Args: args}
	id, err := this.client.ExecuteTx(request)
	return []byte(id.ID),err
}
func (this *ChainCodeSpec) Close() {
	this.client.Close()
}

func getSDK(config string) (*fabapi.FabricSDK,error)  {
	options := fabapi.Options{ConfigFile: config}
	sdk, err := fabapi.NewSDK(options)
	if err !=nil{
		beego.Error(err.Error())
		return nil,err
	}
	return sdk ,nil
}

