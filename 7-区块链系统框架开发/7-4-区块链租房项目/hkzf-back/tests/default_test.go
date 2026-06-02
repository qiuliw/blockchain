package test

import (
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"runtime"
	"testing"

	_ "hkzf/routers"

	"github.com/astaxie/beego"
	. "github.com/smartystreets/goconvey/convey"
)

func init() {
	_, file, _, _ := runtime.Caller(0)
	apppath, _ := filepath.Abs(filepath.Join(filepath.Dir(file), ".."))
	beego.TestBeegoInit(apppath)
}

func TestRoutesRegistered(t *testing.T) {
	r, _ := http.NewRequest(http.MethodGet, "/auth", nil)
	w := httptest.NewRecorder()
	beego.BeeApp.Handlers.ServeHTTP(w, r)

	Convey("GET /auth without params returns 400", t, func() {
		So(w.Code, ShouldEqual, 400)
	})
}
