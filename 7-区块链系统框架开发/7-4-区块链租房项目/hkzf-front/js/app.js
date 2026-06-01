var HKZF = {
  STORAGE_KEY: 'hkzf_flow',

  getFlow: function () {
    try {
      return JSON.parse(sessionStorage.getItem(this.STORAGE_KEY) || '{}');
    } catch (e) {
      return {};
    }
  },

  saveFlow: function (data) {
    var flow = this.getFlow();
    for (var k in data) {
      if (data.hasOwnProperty(k)) flow[k] = data[k];
    }
    sessionStorage.setItem(this.STORAGE_KEY, JSON.stringify(flow));
  },

  resetFlow: function () {
    sessionStorage.removeItem(this.STORAGE_KEY);
  },

  parsePair: function (body) {
    var text = (body || '').toString().trim();
    var parts = text.split(':');
    return { first: parts[0] === 'true', second: parts[1] === 'true', raw: text };
  },

  boolLabel: function (v, ok, no) {
    return v ? (ok || '通过') : (no || '未通过');
  },

  apiGet: function (vm, url, params) {
    return vm.$http.get(url, { params: params || {} });
  },

  apiPostForm: function (vm, url, formData, headers) {
    return vm.$http.post(url, formData, { headers: headers || {} });
  },

  handleError: function (vm, err) {
    var msg = '请求失败，请稍后重试';
    if (err && err.body) msg = err.body.toString();
    else if (err && err.statusText) msg = err.statusText;
    vm.message = msg;
    vm.messageType = 'error';
  },

  renderNav: function (active) {
    var links = [
      { href: 'index.html', label: '首页' },
      { href: 'auth.html', label: '1. 身份认证' },
      { href: 'house.html', label: '2. 房产认证' },
      { href: 'contract.html', label: '3. 签约存证' },
      { href: 'admin.html', label: '数据管理' }
    ];
    var html = '';
    for (var i = 0; i < links.length; i++) {
      var cls = links[i].href.indexOf(active) >= 0 ? ' class="active"' : '';
      html += '<a href="' + links[i].href + '"' + cls + '>' + links[i].label + '</a>';
    }
    return html;
  },

  renderSteps: function (current) {
    var flow = this.getFlow();
    var steps = [
      { id: 1, label: '身份认证', page: 'auth.html', key: 'authDone' },
      { id: 2, label: '房产认证', page: 'house.html', key: 'houseDone' },
      { id: 3, label: '签约存证', page: 'contract.html', key: 'contractDone' }
    ];
    var html = '<div class="steps">';
    for (var i = 0; i < steps.length; i++) {
      var s = steps[i];
      var cls = 'step';
      if (flow[s.key]) cls += ' done';
      if (current === s.id) cls += ' active';
      html += '<div class="' + cls + '"><div class="step-num">' + s.id + '</div><div class="step-label">' + s.label + '</div></div>';
    }
    html += '</div>';
    return html;
  }
};
