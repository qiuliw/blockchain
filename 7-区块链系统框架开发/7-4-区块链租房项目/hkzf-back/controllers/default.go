package controllers

import (
	"encoding/csv"
	"fmt"
	"hkzf/models"
	"io"
	"os"
	"path"
	"strconv"
	"strings"
	"time"

	"github.com/astaxie/beego"
	"github.com/astaxie/beego/toolbox"
)

type AuthController struct {
	beego.Controller
}

func (this *AuthController) Check() {
	name := this.GetString("name")
	id := this.GetString("id")
	if name == "" || id == "" {
		handleResponse(this.Ctx.ResponseWriter, 400, "Request parameter name(or id) can't be empty")
		return
	}

	response, err := models.Query(
		beego.AppConfig.String("chaincode_id_auth"),
		"check",
		[][]byte{[]byte(name), []byte(id)},
	)
	if err != nil {
		handleResponse(this.Ctx.ResponseWriter, 500, err.Error())
		return
	}
	handleResponse(this.Ctx.ResponseWriter, 200, response)
}

func (this *AuthController) RecordAuth() {
	_, header, err := this.GetFile("auth")
	if err != nil {
		handleResponse(this.Ctx.ResponseWriter, 400, err.Error())
		return
	}

	fileName := header.Filename
	if err = this.SaveToFile("auth", path.Join("static/upload", fileName)); err != nil {
		handleResponse(this.Ctx.ResponseWriter, 500, err.Error())
		return
	}

	t := time.Now().Add(5 * time.Second)
	spec := fmt.Sprintf("%d %d %d * * *", t.Second(), t.Minute(), t.Hour())
	task := toolbox.NewTask("auth-import", spec, func() error {
		defer toolbox.StopTask()
		return importAuthCSV(fileName)
	})
	toolbox.AddTask("auth-import", task)
	toolbox.StartTask()
	handleResponse(this.Ctx.ResponseWriter, 200, "ok")
}

func importAuthCSV(fileName string) error {
	chaincodeID := beego.AppConfig.String("chaincode_id_auth")
	file, err := os.Open(path.Join("static/upload", fileName))
	if err != nil {
		return err
	}
	defer file.Close()

	reader := csv.NewReader(file)
	var badLines []string
	line := 0
	for {
		line++
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil || len(record) != 3 {
			badLines = append(badLines, strconv.Itoa(line))
			continue
		}
		args := make([][]byte, len(record))
		for i, v := range record {
			args[i] = []byte(v)
		}
		if _, err = models.Invoke(chaincodeID, "add", args); err != nil {
			badLines = append(badLines, strconv.Itoa(line))
		}
	}
	if len(badLines) > 0 {
		beego.Error("auth import failed lines:", strings.Join(badLines, ","))
	}
	return nil
}
