package routers

import (
	"hkzf/controllers"
	"github.com/astaxie/beego"
)

func init() {
    beego.Router("/auth", &controllers.AuthController{},"get:Check")
    beego.Router("/auth", &controllers.AuthController{},"post:RecordAuth")

	beego.Router("/house", &controllers.CertificationController{},"get:Check")
	beego.Router("/house", &controllers.CertificationController{},"post:RecordHouse")

	beego.Router("/contract", &controllers.ContractController{},"post:SetValue")
	beego.Router("/contract", &controllers.ContractController{},"get:GetValue")
}
