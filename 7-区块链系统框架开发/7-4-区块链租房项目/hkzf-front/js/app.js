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

  currentPage: function () {
    var file = (location.pathname.split('/').pop() || 'index.html').split('?')[0];
    if (!file) file = 'index.html';
    return file.replace(/\.html$/, '');
  },

  mountNav: function (active) {
    var el = document.getElementById('site-nav');
    if (el) el.innerHTML = this.renderNav(active || this.currentPage());
  },

  renderNav: function (active) {
    var page = (active || '').replace(/\.html$/, '');
    var links = [
      { href: 'index.html', label: '首页' },
      { href: 'admin.html', label: '数据管理' },
      { href: 'about.html', label: '关于' }
    ];
    var html = '';
    for (var i = 0; i < links.length; i++) {
      var name = links[i].href.replace(/\.html$/, '');
      var cls = name === page ? ' class="active"' : '';
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
      var inner = '<div class="step-num">' + s.id + '</div><div class="step-label">' + s.label + '</div>';
      if (current !== s.id) {
        html += '<a class="' + cls + ' step-link" href="' + s.page + '">' + inner + '</a>';
      } else {
        html += '<div class="' + cls + '">' + inner + '</div>';
      }
    }
    html += '</div>';
    return html;
  },

  prevStep: function (current) {
    var map = { 1: 'index.html', 2: 'auth.html', 3: 'house.html' };
    return map[current] || 'index.html';
  },

  nextStep: function (current) {
    var map = { 1: 'house.html', 2: 'contract.html', 3: 'index.html' };
    return map[current] || 'index.html';
  }
};

(function () {
  function mount() {
    HKZF.mountNav();
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else {
    mount();
  }
})();
