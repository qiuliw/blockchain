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
    return flow;
  },

  resetFlow: function () {
    sessionStorage.removeItem(this.STORAGE_KEY);
  },

  beginRental: function () {
    var flow = this.getFlow();
    if (flow.rentalId) return flow;
    var now = new Date();
    var pad = function (n) {
      return n < 10 ? '0' + n : '' + n;
    };
    var rentalId = 'RZ' + now.getFullYear() + pad(now.getMonth() + 1) + pad(now.getDate()) +
      pad(now.getHours()) + pad(now.getMinutes()) + pad(now.getSeconds());
    return this.saveFlow({ rentalId: rentalId, startedAt: now.toISOString() });
  },

  canAccessStep: function (stepId) {
    var flow = this.getFlow();
    if (stepId === 1) return true;
    if (stepId === 2) return !!flow.authDone;
    if (stepId === 3) return !!flow.authDone && !!flow.houseDone;
    return false;
  },

  guardStep: function (requiredStep) {
    var flow = this.getFlow();
    if (requiredStep >= 2 && !flow.authDone) {
      location.replace('auth.html');
      return false;
    }
    if (requiredStep >= 3 && !flow.houseDone) {
      location.replace('house.html');
      return false;
    }
    return true;
  },

  flowStatus: function (flow) {
    flow = flow || this.getFlow();
    if (flow.contractDone) {
      return { text: '租赁办理完成', cls: 'done', step: 4 };
    }
    if (flow.houseDone) {
      return { text: '待签约存证', cls: 'pending', step: 3 };
    }
    if (flow.authDone) {
      return { text: '待房产认证', cls: 'pending', step: 2 };
    }
    if (flow.rentalId) {
      return { text: '待身份认证', cls: 'pending', step: 1 };
    }
    return { text: '未开始', cls: 'idle', step: 0 };
  },

  nextStepUrl: function () {
    var flow = this.getFlow();
    if (!flow.rentalId) return 'auth.html';
    if (!flow.authDone) return 'auth.html';
    if (!flow.houseDone) return 'house.html';
    if (!flow.contractDone) return 'contract.html';
    return 'index.html';
  },

  nextStepLabel: function () {
    var flow = this.getFlow();
    if (!flow.rentalId || !flow.authDone) return '开始身份认证';
    if (!flow.houseDone) return '继续房产认证';
    if (!flow.contractDone) return '继续签约存证';
    return '查看办理结果';
  },

  maskId: function (id) {
    if (!id || id.length < 8) return id || '—';
    return id.slice(0, 4) + '**********' + id.slice(-4);
  },

  renderRentalPanel: function () {
    var flow = this.getFlow();
    if (!flow.rentalId) return '';

    var status = this.flowStatus(flow);
    var html = '<div class="rental-panel">';
    html += '<div class="rental-panel-head">';
    html += '<div><div class="rental-kicker">当前租赁申请</div>';
    html += '<div class="rental-id">' + flow.rentalId + '</div></div>';
    html += '<span class="status-badge status-' + status.cls + '">' + status.text + '</span>';
    html += '</div>';
    html += '<div class="rental-grid">';
    html += '<div class="rental-field"><span>租客</span><strong>' + (flow.name || '—') + '</strong></div>';
    html += '<div class="rental-field"><span>身份证</span><strong>' + this.maskId(flow.id) + '</strong></div>';
    html += '<div class="rental-field"><span>房源</span><strong>' + (flow.houseId || '—') + '</strong></div>';
    html += '<div class="rental-field"><span>合同编号</span><strong>' + (flow.contractId || '—') + '</strong></div>';
    html += '</div>';
    html += '<p class="rental-note">办理信息已与本次租赁申请关联，合同文件以链上哈希形式存证。</p>';
    html += '</div>';
    return html;
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
      { href: 'about.html', label: '关于' },
      { href: 'present.html', label: '答辩' }
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
      { id: 1, label: '身份核验', page: 'auth.html', key: 'authDone' },
      { id: 2, label: '房源认证', page: 'house.html', key: 'houseDone' },
      { id: 3, label: '合同存证', page: 'contract.html', key: 'contractDone' }
    ];
    var html = '<div class="steps">';
    for (var i = 0; i < steps.length; i++) {
      var s = steps[i];
      var cls = 'step';
      if (flow[s.key]) cls += ' done';
      if (current === s.id) cls += ' active';
      if (!this.canAccessStep(s.id)) cls += ' locked';
      var inner = '<div class="step-num">' + s.id + '</div><div class="step-label">' + s.label + '</div>';
      if (current !== s.id && this.canAccessStep(s.id)) {
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
