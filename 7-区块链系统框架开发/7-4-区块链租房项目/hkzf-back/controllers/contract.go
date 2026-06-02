package controllers

import (
	"crypto/sha256"
	"encoding/hex"
	"hkzf/models"
	"io"
	"strings"

	"github.com/astaxie/beego"
)

type ContractController struct {
	beego.Controller
}

func (this *ContractController) SetValue() {
	name := this.GetString("name")
	id := this.GetString("id")
	houseId := this.GetString("houseId")

	if ok, msg := verifyAuthOnChain(name, id); !ok {
		handleResponse(this.Ctx.ResponseWriter, 403, msg)
		return
	}
	if ok, msg := verifyHouseOnChain(houseId, id); !ok {
		handleResponse(this.Ctx.ResponseWriter, 403, msg)
		return
	}

	file, header, err := this.GetFile("contract")
	if err != nil {
		handleResponse(this.Ctx.ResponseWriter, 400, err.Error())
		return
	}
	defer file.Close()

	key := strings.Split(header.Filename, ".")[0]
	hash := sha256.New()
	if _, err = io.Copy(hash, file); err != nil {
		handleResponse(this.Ctx.ResponseWriter, 400, err.Error())
		return
	}

	hashHex := hex.EncodeToString(hash.Sum(nil))
	args := [][]byte{[]byte(key), []byte(hashHex)}
	_, err = models.Invoke(beego.AppConfig.String("chaincode_id_contract"), "set", args)
	if err != nil {
		handleResponse(this.Ctx.ResponseWriter, 500, err.Error())
		return
	}
	handleResponse(this.Ctx.ResponseWriter, 200, hashHex)
}

func (this *ContractController) GetValue() {
	key := this.GetString("contractId")
	if key == "" {
		handleResponse(this.Ctx.ResponseWriter, 400, "Request parameter contractId can't be empty")
		return
	}

	data, err := models.Query(beego.AppConfig.String("chaincode_id_contract"), "get", [][]byte{[]byte(key)})
	if err != nil {
		handleResponse(this.Ctx.ResponseWriter, 500, err.Error())
		return
	}
	handleResponse(this.Ctx.ResponseWriter, 200, data)
}
