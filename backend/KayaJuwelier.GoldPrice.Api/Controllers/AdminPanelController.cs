using Microsoft.AspNetCore.Mvc;

namespace KayaJuwelier.GoldPrice.Api.Controllers;

[ApiController]
public class AdminPanelController : ControllerBase
{
    [HttpGet("/adminpage")]
    public IActionResult AdminPage()
        => Content(AdminPageHtml, "text/html; charset=utf-8");

    // ── Embedded admin panel HTML ─────────────────────────────────────────────
    private const string AdminPageHtml = """
<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Kaya Juwelier – Admin Panel</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:#111122;color:#e0e0e0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;min-height:100vh}
.topbar{background:#1a1a2e;border-bottom:1px solid #2a2a4a;padding:0 24px;height:56px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:100}
.topbar-title{color:#d4af37;font-size:16px;font-weight:700;letter-spacing:.5px}
.topbar-right{display:flex;align-items:center;gap:12px}
#user-badge{font-size:12px;color:#888;display:none}
#logout-btn{padding:6px 14px;background:transparent;border:1px solid #444;border-radius:8px;color:#aaa;font-size:13px;cursor:pointer;display:none}
#logout-btn:hover{border-color:#e53935;color:#e53935}
.content{max-width:760px;margin:0 auto;padding:28px 16px 60px}

/* Login */
#login-section{display:flex;justify-content:center;padding-top:80px}
.login-card{background:#1a1a2e;border:1px solid #2a2a4a;border-radius:16px;padding:32px 28px;width:100%;max-width:400px}
.login-card h2{color:#d4af37;font-size:18px;margin-bottom:6px}
.login-card p{color:#888;font-size:13px;margin-bottom:24px}
.field{margin-bottom:16px}
.field label{display:block;font-size:12px;color:#aaa;margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px}
.field input{width:100%;padding:11px 14px;background:#111122;border:1px solid #333355;border-radius:9px;color:#fff;font-size:14px;outline:none;transition:border .2s}
.field input:focus{border-color:#d4af37}
#login-err{color:#e53935;font-size:13px;margin-bottom:12px;display:none}
.btn-gold{width:100%;padding:12px;background:#d4af37;border:none;border-radius:9px;color:#111;font-size:15px;font-weight:700;cursor:pointer;transition:opacity .2s}
.btn-gold:hover{opacity:.88}
.btn-gold:disabled{opacity:.5;cursor:default}

/* Main panel */
#main-section{display:none}
.section-header{display:flex;align-items:center;gap:8px;margin-bottom:14px}
.section-bar{width:4px;height:18px;background:#d4af37;border-radius:2px;flex-shrink:0}
.section-icon{font-size:15px}
.section-title{font-size:11px;font-weight:700;color:#aaa;text-transform:uppercase;letter-spacing:1.2px}
.card{background:#1a1a2e;border:1px solid #2a2a4a;border-radius:14px;padding:20px;margin-bottom:24px}

/* Commission rows */
.comm-row{display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid #1e1e36}
.comm-row:last-child{border-bottom:none}
.comm-info{flex:1;min-width:0}
.comm-name{font-size:14px;color:#e0e0e0;font-weight:600}
.comm-key{font-size:11px;color:#555;margin-top:1px}
.comm-right{display:flex;align-items:center;gap:8px;flex-shrink:0}
.comm-input{width:68px;padding:7px 8px;background:#111122;border:1px solid #333355;border-radius:8px;color:#d4af37;font-size:14px;font-weight:800;text-align:center;outline:none;transition:border .2s}
.comm-input:focus{border-color:#d4af37}
.comm-pct{font-size:12px;color:#666}
input[type=range]{-webkit-appearance:none;appearance:none;width:100%;height:4px;background:#1e1e36;border-radius:2px;outline:none;margin:6px 0 0}
input[type=range]::-webkit-slider-thumb{-webkit-appearance:none;width:16px;height:16px;background:#d4af37;border-radius:50%;cursor:pointer}
input[type=range]::-moz-range-thumb{width:16px;height:16px;background:#d4af37;border:none;border-radius:50%;cursor:pointer}

/* Save bar */
.save-bar{position:fixed;bottom:0;left:0;right:0;background:#1a1a2e;border-top:1px solid #2a2a4a;padding:14px 24px;display:flex;align-items:center;justify-content:space-between;gap:12px}
.save-status{font-size:13px;color:#888;flex:1}
.save-status.ok{color:#4caf50}
.save-status.err{color:#e53935}
#save-btn{padding:11px 28px;background:#d4af37;border:none;border-radius:9px;color:#111;font-size:14px;font-weight:700;cursor:pointer;transition:opacity .2s;flex-shrink:0}
#save-btn:hover{opacity:.88}
#save-btn:disabled{opacity:.5;cursor:default}

/* Change password */
.pw-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}
@media(max-width:500px){.pw-grid{grid-template-columns:1fr}}
#pw-err{color:#e53935;font-size:13px;margin-bottom:10px;display:none}
#pw-ok{color:#4caf50;font-size:13px;margin-bottom:10px;display:none}
.btn-outline{padding:11px 20px;background:transparent;border:1px solid #d4af37;border-radius:9px;color:#d4af37;font-size:14px;font-weight:600;cursor:pointer;width:100%;transition:background .2s}
.btn-outline:hover{background:rgba(212,175,55,.1)}
.btn-outline:disabled{opacity:.5;cursor:default}
</style>
</head>
<body>

<!-- Top bar -->
<div class="topbar">
  <div class="topbar-title">⚙ KAYA JUWELİER ADMIN</div>
  <div class="topbar-right">
    <span id="user-badge"></span>
    <button id="logout-btn" onclick="logout()">Çıkış Yap</button>
  </div>
</div>

<!-- Login section -->
<div id="login-section">
  <div class="login-card">
    <h2>Giriş Yap</h2>
    <p>Admin paneline erişmek için giriş yapın.</p>
    <div class="field">
      <label>Kullanıcı Adı</label>
      <input type="text" id="username" placeholder="admin" autocomplete="username">
    </div>
    <div class="field">
      <label>Şifre</label>
      <input type="password" id="password" placeholder="••••••••" autocomplete="current-password"
             onkeydown="if(event.key==='Enter')doLogin()">
    </div>
    <div id="login-err"></div>
    <button class="btn-gold" id="login-btn" onclick="doLogin()">Giriş Yap</button>
  </div>
</div>

<!-- Main panel -->
<div id="main-section">
  <div class="content">

    <!-- Commission section -->
    <div class="card">
      <div class="section-header">
        <div class="section-bar"></div>
        <span class="section-icon">📊</span>
        <span class="section-title">Gram Altın Komisyonları</span>
      </div>
      <div id="rows-gram"></div>
    </div>

    <div class="card">
      <div class="section-header">
        <div class="section-bar"></div>
        <span class="section-icon">🪙</span>
        <span class="section-title">Altın Para Komisyonları</span>
      </div>
      <div id="rows-altin"></div>
    </div>

    <div class="card">
      <div class="section-header">
        <div class="section-bar"></div>
        <span class="section-icon">🏅</span>
        <span class="section-title">Reşat Para Komisyonları</span>
      </div>
      <div id="rows-resat"></div>
    </div>

    <div class="card">
      <div class="section-header">
        <div class="section-bar"></div>
        <span class="section-icon">💍</span>
        <span class="section-title">Takı Komisyonları</span>
      </div>
      <div id="rows-taki"></div>
    </div>

    <!-- Change password -->
    <div class="card">
      <div class="section-header">
        <div class="section-bar"></div>
        <span class="section-icon">🔒</span>
        <span class="section-title">Şifre Değiştir</span>
      </div>
      <div id="pw-err"></div>
      <div id="pw-ok"></div>
      <div class="pw-grid">
        <div class="field"><label>Mevcut Şifre</label>
          <input type="password" id="pw-old" placeholder="••••••••"></div>
        <div class="field"><label>Yeni Şifre</label>
          <input type="password" id="pw-new" placeholder="••••••••"></div>
      </div>
      <button class="btn-outline" id="pw-btn" onclick="changePassword()">Şifreyi Güncelle</button>
    </div>

  </div><!-- /content -->

  <!-- Fixed save bar -->
  <div class="save-bar">
    <span class="save-status" id="save-status"></span>
    <button id="save-btn" onclick="saveAll()">💾 Tümünü Kaydet</button>
  </div>
</div>

<script>
const API = '';
const HDR = {'Content-Type':'application/json','ngrok-skip-browser-warning':'true'};
const GROUPS = {
  gram:  [{key:'24K',label:'24 Ayar Altın'},{key:'22K',label:'22 Ayar Altın'},
          {key:'21K',label:'21 Ayar Altın'},{key:'18K',label:'18 Ayar Altın'},
          {key:'troy',label:'Troy Ons'}],
  altin: [{key:'ceyrek_altin',label:'Çeyrek Altın'},{key:'yarim_altin',label:'Yarım Altın'},
          {key:'tam_altin',label:'Tam Altın'},{key:'gremse_altin',label:'Gremse Altın'},
          {key:'besli_altin',label:'Beşli Altın'}],
  resat: [{key:'ceyrek_resat',label:'Çeyrek Reşat'},{key:'yarim_resat',label:'Yarım Reşat'},
          {key:'tam_resat',label:'Tam Reşat'},{key:'iki5_resat',label:'2.5 Reşat'},
          {key:'besli_resat',label:'Beşli Reşat'}],
  taki:  [{key:'burma',label:'Burma Bilezik'},{key:'ajda',label:'Ajda / Kibrit'}]
};

let token = localStorage.getItem('kj_admin_token') || '';
let values = {}; // key → current value

// ── Boot ─────────────────────────────────────────────────────────────────────
window.onload = () => {
  if (token) tryAutoLogin();
};

async function tryAutoLogin() {
  // Validate token by fetching commissions
  try {
    const r = await fetch(API + '/api/commissions', {headers: {
      ...HDR, 'Authorization': 'Bearer ' + token
    }});
    if (r.ok) {
      const data = await r.json();
      showPanel(data);
      return;
    }
  } catch(_) {}
  token = '';
  localStorage.removeItem('kj_admin_token');
}

// ── Login ────────────────────────────────────────────────────────────────────
async function doLogin() {
  const u = document.getElementById('username').value.trim();
  const p = document.getElementById('password').value;
  const errEl = document.getElementById('login-err');
  const btn   = document.getElementById('login-btn');
  if (!u || !p) { showErr(errEl, 'Kullanıcı adı ve şifre gerekli.'); return; }

  btn.disabled = true;
  btn.textContent = 'Giriş yapılıyor...';
  errEl.style.display = 'none';

  try {
    const r = await fetch(API + '/api/auth/login', {
      method: 'POST',
      headers: HDR,
      body: JSON.stringify({username: u, password: p})
    });
    if (r.ok) {
      const data = await r.json();
      token = data.token;
      localStorage.setItem('kj_admin_token', token);
      // Load commissions
      const cr = await fetch(API + '/api/commissions', {headers: HDR});
      const comms = await cr.json();
      showPanel(comms, data.username || u);
    } else {
      const err = await r.json().catch(() => ({}));
      showErr(errEl, err.message || 'Giriş başarısız.');
    }
  } catch(_) {
    showErr(errEl, 'Sunucuya bağlanılamadı.');
  }
  btn.disabled = false;
  btn.textContent = 'Giriş Yap';
}

function showErr(el, msg) {
  el.textContent = msg;
  el.style.display = 'block';
}

// ── Show main panel ───────────────────────────────────────────────────────────
function showPanel(commissions, username) {
  // Build values map
  commissions.forEach(c => { values[c.assetKey] = c.commissionPercent; });

  // Render rows for each group
  Object.entries(GROUPS).forEach(([grp, items]) => {
    const container = document.getElementById('rows-' + grp);
    container.innerHTML = '';
    items.forEach(item => {
      const val = values[item.key] ?? 0;
      container.insertAdjacentHTML('beforeend', buildRow(item.key, item.label, val));
    });
  });

  // Show/hide sections
  document.getElementById('login-section').style.display = 'none';
  document.getElementById('main-section').style.display = 'block';

  // User badge
  if (username) {
    const badge = document.getElementById('user-badge');
    badge.textContent = '👤 ' + username;
    badge.style.display = 'block';
  }
  document.getElementById('logout-btn').style.display = 'block';
}

function buildRow(key, label, val) {
  const v = parseFloat(val).toFixed(2);
  return `
    <div class="comm-row">
      <div class="comm-info">
        <div class="comm-name">${label}</div>
        <div class="comm-key">${key}</div>
        <input type="range" min="0" max="20" step="0.01" value="${v}"
               oninput="syncFromSlider('${key}',this.value)"
               id="slider_${key}">
      </div>
      <div class="comm-right">
        <input class="comm-input" type="number" min="0" max="100" step="0.01" value="${v}"
               oninput="syncFromInput('${key}',this.value)"
               id="input_${key}">
        <span class="comm-pct">%</span>
      </div>
    </div>`;
}

function syncFromSlider(key, val) {
  const v = parseFloat(val).toFixed(2);
  values[key] = parseFloat(v);
  const inp = document.getElementById('input_' + key);
  if (inp) inp.value = v;
  clearStatus();
}

function syncFromInput(key, val) {
  const v = parseFloat(val);
  if (isNaN(v) || v < 0 || v > 100) return;
  values[key] = v;
  const slider = document.getElementById('slider_' + key);
  if (slider) slider.value = Math.min(v, 20);
  clearStatus();
}

function clearStatus() {
  const el = document.getElementById('save-status');
  el.textContent = '';
  el.className = 'save-status';
}

// ── Save all ─────────────────────────────────────────────────────────────────
async function saveAll() {
  const btn = document.getElementById('save-btn');
  const statusEl = document.getElementById('save-status');
  btn.disabled = true;
  btn.textContent = 'Kaydediliyor...';
  statusEl.textContent = '';
  statusEl.className = 'save-status';

  const payload = Object.entries(values).map(([k, v]) => ({
    assetKey: k, commissionPercent: v
  }));

  try {
    const r = await fetch(API + '/api/commissions/bulk', {
      method: 'PUT',
      headers: {...HDR, 'Authorization': 'Bearer ' + token},
      body: JSON.stringify(payload)
    });
    if (r.ok) {
      statusEl.textContent = '✓ Komisyonlar kaydedildi.';
      statusEl.className = 'save-status ok';
      setTimeout(() => { statusEl.textContent = ''; statusEl.className = 'save-status'; }, 3000);
    } else if (r.status === 401) {
      statusEl.textContent = 'Oturum süresi dolmuş. Lütfen tekrar giriş yapın.';
      statusEl.className = 'save-status err';
      setTimeout(logout, 2000);
    } else {
      statusEl.textContent = 'Kaydetme başarısız: ' + r.status;
      statusEl.className = 'save-status err';
    }
  } catch(_) {
    statusEl.textContent = 'Sunucuya bağlanılamadı.';
    statusEl.className = 'save-status err';
  }

  btn.disabled = false;
  btn.textContent = '💾 Tümünü Kaydet';
}

// ── Change password ───────────────────────────────────────────────────────────
async function changePassword() {
  const oldPw = document.getElementById('pw-old').value;
  const newPw = document.getElementById('pw-new').value;
  const errEl = document.getElementById('pw-err');
  const okEl  = document.getElementById('pw-ok');
  const btn   = document.getElementById('pw-btn');
  errEl.style.display = 'none';
  okEl.style.display  = 'none';

  if (!oldPw || !newPw) { showErr(errEl, 'Her iki alanı da doldurun.'); return; }
  if (newPw.length < 6)  { showErr(errEl, 'Yeni şifre en az 6 karakter olmalı.'); return; }

  btn.disabled = true;
  btn.textContent = 'Güncelleniyor...';

  try {
    const r = await fetch(API + '/api/auth/change-password', {
      method: 'POST',
      headers: {...HDR, 'Authorization': 'Bearer ' + token},
      body: JSON.stringify({oldPassword: oldPw, newPassword: newPw})
    });
    if (r.ok) {
      okEl.textContent = '✓ Şifre başarıyla güncellendi.';
      okEl.style.display = 'block';
      document.getElementById('pw-old').value = '';
      document.getElementById('pw-new').value = '';
    } else {
      const err = await r.json().catch(() => ({}));
      showErr(errEl, err.message || 'Güncelleme başarısız.');
    }
  } catch(_) {
    showErr(errEl, 'Sunucuya bağlanılamadı.');
  }

  btn.disabled = false;
  btn.textContent = 'Şifreyi Güncelle';
}

// ── Logout ───────────────────────────────────────────────────────────────────
function logout() {
  token = '';
  localStorage.removeItem('kj_admin_token');
  document.getElementById('main-section').style.display = 'none';
  document.getElementById('login-section').style.display = 'flex';
  document.getElementById('logout-btn').style.display = 'none';
  document.getElementById('user-badge').style.display = 'none';
  document.getElementById('password').value = '';
}
</script>
</body>
</html>
""";
}
