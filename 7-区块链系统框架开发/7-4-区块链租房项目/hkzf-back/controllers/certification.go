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

type CertificationController struct {
	beego.Controller
}

func (this *CertificationController) Check() {
	houseId := this.GetString("houseId")
	id := this.GetString("id")
	if houseId == "" || id == "" {
		handleResponse(this.Ctx.ResponseWriter, 400, "Reqest parameter houseId(or id) can't be empty")
		return
	}

	response, err := models.Query(
		beego.AppConfig.String("chaincode_id_house"),
		"check",
		[][]byte{[]byte(houseId), []byte(id)},
	)
	if err != nil {
		handleResponse(this.Ctx.ResponseWriter, 500, err.Error())
		return
	}
	handleResponse(this.Ctx.ResponseWriter, 200, response)
}

func (this *CertificationController) RecordHouse() {
	_, header, err := this.GetFile("house")
	if err != nil {
		handleResponse(this.Ctx.ResponseWriter, 400, err.Error())
		return
	}

	fileName := header.Filename
	if err = this.SaveToFile("house", path.Join("static/upload", fileName)); err != nil {
		handleResponse(this.Ctx.ResponseWriter, 500, err.Error())
		return
	}

	t := time.Now().Add(5 * time.Second)
	spec := fmt.Sprintf("%d %d %d * * *", t.Second(), t.Minute(), t.Hour())
	tk := toolbox.NewTask("house-import", spec, func() error {
		defer toolbox.StopTask()
		return importHouseCSV(fileName)
	})
	toolbox.AddTask("house-import", tk)
	toolbox.StartTask()
	handleResponse(this.Ctx.ResponseWriter, 200, "ok")
}

func importHouseCSV(fileName string) error {
	chaincodeID := beego.AppConfig.String("chaincode_id_house")
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
		beego.Error("house import failed lines:", strings.Join(badLines, ","))
	}
	return nil
}
