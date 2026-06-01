package controllers

import (
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/context"
)

func handleResponse(response *context.Response, code int, msg interface{}) {
	if code >= 400 {
		beego.Error(msg)
	} else {
		beego.Info(msg)
	}
	response.WriteHeader(code)
	if b, ok := msg.([]byte); ok {
		response.Write(b)
		return
	}
	response.Write([]byte(msg.(string)))
}
