package controllers

import (
	"hkzf/models"
	"strings"

	"github.com/astaxie/beego"
)

func parseBoolPair(raw string) (first, second bool) {
	parts := strings.Split(strings.TrimSpace(raw), ":")
	if len(parts) != 2 {
		return false, false
	}
	return parts[0] == "true", parts[1] == "true"
}

func verifyAuthOnChain(name, id string) (bool, string) {
	if name == "" || id == "" {
		return false, "姓名与身份证号不能为空"
	}

	data, err := models.Query(
		beego.AppConfig.String("chaincode_id_auth"),
		"check",
		[][]byte{[]byte(name), []byte(id)},
	)
	if err != nil {
		return false, err.Error()
	}

	first, second := parseBoolPair(string(data))
	if !first {
		return false, "身份未通过链上核验，请先完成个人认证"
	}
	if second {
		return false, "存在不良个人记录，无法继续租赁流程"
	}
	return true, ""
}

func verifyHouseOnChain(houseId, id string) (bool, string) {
	if houseId == "" || id == "" {
		return false, "房产证号与身份证号不能为空"
	}

	data, err := models.Query(
		beego.AppConfig.String("chaincode_id_house"),
		"check",
		[][]byte{[]byte(houseId), []byte(id)},
	)
	if err != nil {
		return false, err.Error()
	}

	first, second := parseBoolPair(string(data))
	if !first {
		return false, "产权人与身份证不匹配，或链上无该房产记录"
	}
	if !second {
		return false, "该房产不具备出租资格"
	}
	return true, ""
}
