// ============================================================
// auth.js — Shared authentication logic
// ============================================================

// ── Theme Manager ─────────────────────────────────────────
const Theme = {
  KEY: 'chat_theme',
  get() {
    return localStorage.getItem(this.KEY) || 'dark';
  },
  set(mode) {
    localStorage.setItem(this.KEY, mode);
    document.documentElement.setAttribute('data-theme', mode);
    this.syncStatusBar();
  },
  toggle() {
    this.set(this.get() === 'dark' ? 'light' : 'dark');
  },
  init() {
    // Apply saved theme immediately
    const saved = this.get();
    document.documentElement.setAttribute('data-theme', saved);
    this.syncStatusBar();
  },
  // Keep the OS status bar / window colour in sync with the theme
  syncStatusBar() {
    const meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute('content', this.get() === 'light' ? '#F5F3FF' : '#000000');
  }
};

// Auto-init theme on every page
Theme.init();

// ── App shell: register the service worker (installable / offline) ──
if ('serviceWorker' in navigator && (location.protocol === 'https:' || location.hostname === 'localhost' || location.hostname === '127.0.0.1')) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('sw.js').catch(() => {});
  });
}

// ── Country Data ──────────────────────────────────────────
const COUNTRIES = [
  { code: 'US', name: 'United States', dial: '+1' },
  { code: 'GB', name: 'United Kingdom', dial: '+44' },
  { code: 'NG', name: 'Nigeria', dial: '+234' },
  { code: 'CA', name: 'Canada', dial: '+1' },
  { code: 'AU', name: 'Australia', dial: '+61' },
  { code: 'IN', name: 'India', dial: '+91' },
  { code: 'DE', name: 'Germany', dial: '+49' },
  { code: 'FR', name: 'France', dial: '+33' },
  { code: 'BR', name: 'Brazil', dial: '+55' },
  { code: 'MX', name: 'Mexico', dial: '+52' },
  { code: 'JP', name: 'Japan', dial: '+81' },
  { code: 'CN', name: 'China', dial: '+86' },
  { code: 'ZA', name: 'South Africa', dial: '+27' },
  { code: 'KE', name: 'Kenya', dial: '+254' },
  { code: 'GH', name: 'Ghana', dial: '+233' },
  { code: 'SG', name: 'Singapore', dial: '+65' },
  { code: 'AE', name: 'UAE', dial: '+971' },
  { code: 'PK', name: 'Pakistan', dial: '+92' },
  { code: 'BD', name: 'Bangladesh', dial: '+880' },
  { code: 'PH', name: 'Philippines', dial: '+63' },
  { code: 'ID', name: 'Indonesia', dial: '+62' },
  { code: 'EG', name: 'Egypt', dial: '+20' },
  { code: 'IT', name: 'Italy', dial: '+39' },
  { code: 'ES', name: 'Spain', dial: '+34' },
  { code: 'NL', name: 'Netherlands', dial: '+31' },
  { code: 'SE', name: 'Sweden', dial: '+46' },
];

// ── Session Store ─────────────────────────────────────────
// sessionStorage = active session; localStorage = persisted
// (kept only when the user opts in via "Remember me")
const Session = {
  keyName(k)  { return 'chat_' + k; },
  permKey(k)  { return 'chat_persist_' + k; },
  set(key, val) {
    try { sessionStorage.setItem(this.keyName(key), JSON.stringify(val)); } catch(e) {}
  },
  get(key) {
    let raw = null;
    try { raw = sessionStorage.getItem(this.keyName(key)); } catch(e) {}
    if (raw === null) { try { raw = localStorage.getItem(this.permKey(key)); } catch(e) {} }
    if (raw === null) return null;
    try { return JSON.parse(raw); } catch(e) { return null; }
  },
  persist() {
    // Mirror the active session into long-term storage
    try {
      const tok = sessionStorage.getItem(this.keyName('access_token'));
      const user = sessionStorage.getItem(this.keyName('user'));
      if (tok) localStorage.setItem(this.permKey('access_token'), tok);
      if (user) localStorage.setItem(this.permKey('user'), user);
    } catch(e) {}
  },
  clear() {
    Object.keys(sessionStorage).filter(k => k.startsWith('chat_')).forEach(k => sessionStorage.removeItem(k));
    Object.keys(localStorage).filter(k => k.startsWith('chat_persist_')).forEach(k => localStorage.removeItem(k));
  },
  isLoggedIn() { return !!this.get('access_token'); }
};

// ── Toast ─────────────────────────────────────────────────
function showToast(msg, type = 'error', duration = 4000) {
  let container = document.querySelector('.toast-container');
  if (!container) {
    container = document.createElement('div');
    container.className = 'toast-container';
    document.body.appendChild(container);
  }
  const icons = {
    error: '<svg viewBox="0 0 20 20"><path d="M10 18a8 8 0 100-16 8 8 0 000 16zm0-9v4m0 2h.01" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/></svg>',
    success: '<svg viewBox="0 0 20 20"><path d="M10 18a8 8 0 100-16 8 8 0 000 16zm-1-5l-2-2 1.4-1.4L9 10.2l3.6-3.6L14 8l-5 5z" fill="currentColor"/></svg>',
    info: '<svg viewBox="0 0 20 20"><path d="M10 18a8 8 0 100-16 8 8 0 000 16zm0-11v2m0 4v2" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/></svg>',
  };
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `${icons[type] || icons.info}<span>${msg}</span>`;
  container.appendChild(toast);
  setTimeout(() => {
    toast.classList.add('removing');
    setTimeout(() => toast.remove(), 350);
  }, duration);
}

// ── Set Button Loading State ──────────────────────────────
function setLoading(btn, loading) {
  if (loading) {
    btn.classList.add('loading');
    btn.disabled = true;
  } else {
    btn.classList.remove('loading');
    btn.disabled = false;
  }
}

// ── Disable All Inputs ─────────────────────────────────────
function setFormDisabled(form, disabled) {
  if (!form) return;
  form.querySelectorAll('input, button, select').forEach(el => {
    if (el.classList.contains('btn-primary')) return; // btn handles itself
    el.disabled = disabled;
  });
}

// ── Validation Helpers ────────────────────────────────────
const Validate = {
  phone: (num) => /^\d{6,14}$/.test(num.replace(/\s/g, '')),
  email: (e) => /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(e),
  username: (u) => /^[a-zA-Z0-9_\.]{3,30}$/.test(u),
  identifier: (v) => Validate.email(v) || Validate.username(v),
  password: (p) => p.length >= 6,
};

function setFieldState(inputEl, msgEl, state, msg) {
  if (!inputEl) return;
  inputEl.classList.remove('error');
  if (msgEl) { msgEl.className = 'field-msg'; msgEl.textContent = msg || ''; }
  if (state === 'error') {
    inputEl.classList.add('error');
    if (msgEl) msgEl.classList.add('error');
  } else if (state === 'success') {
    if (msgEl) msgEl.classList.add('success');
  }
}

// ── Country Select Widget ─────────────────────────────────
function initCountrySelect(btnId, dropdownId, searchId, listId, selectedDialId) {
  const btn = document.getElementById(btnId);
  const dropdown = document.getElementById(dropdownId);
  const search = document.getElementById(searchId);
  const list = document.getElementById(listId);
  const dialDisplay = document.getElementById(selectedDialId);
  if (!btn || !dropdown) return;

  let selected = COUNTRIES[0];
  if (dialDisplay) dialDisplay.textContent = selected.dial;

  function renderList(filter = '') {
    const f = filter.toLowerCase();
    list.innerHTML = COUNTRIES.filter(c => c.name.toLowerCase().includes(f) || c.dial.includes(f) || c.code.toLowerCase().includes(f))
      .map(c => `<div class="country-item" data-code="${c.code}" data-dial="${c.dial}"><span>${c.name}</span><span class="dial">${c.dial}</span></div>`)
      .join('');
    list.querySelectorAll('.country-item').forEach(item => {
      item.addEventListener('click', () => {
        selected = COUNTRIES.find(c => c.code === item.dataset.code);
        if (dialDisplay) dialDisplay.textContent = selected.dial;
        if (search) search.value = '';
        renderList();
        closeDropdown();
        btn.dispatchEvent(new CustomEvent('countryChange', { detail: selected }));
      });
    });
  }

  function closeDropdown() {
    dropdown.classList.remove('open');
    btn.classList.remove('open');
  }

  btn.addEventListener('click', (e) => {
    e.stopPropagation();
    const isOpen = dropdown.classList.contains('open');
    dropdown.classList.toggle('open');
    btn.classList.toggle('open');
    if (!isOpen && search) setTimeout(() => search.focus(), 50);
  });

  if (search) search.addEventListener('input', () => renderList(search.value));
  document.addEventListener('click', closeDropdown);
  renderList();

  return { getSelected: () => selected };
}

// ── OTP Input Controller ──────────────────────────────────
function initOtpInputs(containerSelector) {
  const boxes = document.querySelectorAll(containerSelector + ' .otp-box');
  if (!boxes.length) return;

  boxes.forEach((box, i) => {
    box.addEventListener('input', (e) => {
      const val = e.target.value.replace(/\D/g, '');
      e.target.value = val ? val.slice(-1) : '';
      if (val && boxes[i + 1]) boxes[i + 1].focus();
      box.classList.toggle('filled', !!e.target.value);
    });

    box.addEventListener('keydown', (e) => {
      if (e.key === 'Backspace' && !box.value && boxes[i - 1]) {
        boxes[i - 1].focus();
        boxes[i - 1].value = '';
        boxes[i - 1].classList.remove('filled');
      }
      if (e.key === 'ArrowLeft' && boxes[i - 1]) boxes[i - 1].focus();
      if (e.key === 'ArrowRight' && boxes[i + 1]) boxes[i + 1].focus();
    });

    box.addEventListener('paste', (e) => {
      e.preventDefault();
      const paste = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '');
      [...paste.slice(0, 6)].forEach((ch, idx) => {
        if (boxes[idx]) { boxes[idx].value = ch; boxes[idx].classList.add('filled'); }
      });
      const next = boxes[Math.min(paste.length, boxes.length - 1)];
      if (next) next.focus();
    });
  });

  return {
    getValue: () => [...boxes].map(b => b.value).join(''),
    shake: () => boxes.forEach(b => { b.classList.remove('error'); void b.offsetWidth; b.classList.add('error'); }),
    clear: () => boxes.forEach(b => { b.value = ''; b.classList.remove('filled', 'error'); }),
    isComplete: () => [...boxes].every(b => b.value),
  };
}

// ── Mock API (simulate backend) ──────────────────────────
const API = {
  async requestOtp(phone, countryCode) {
    await delay(1200);
    if (phone === '0000000') throw new Error('Rate limit exceeded. Please try again later.');
    return { status: 'success', session_id: 'sess_' + Math.random().toString(36).slice(2) };
  },
  async verifyOtp(sessionId, otpCode) {
    await delay(1200);
    if (otpCode === '000000') throw new Error('Invalid verification code. Please try again.');
    return { access_token: 'jwt_mock_' + Date.now(), user: { id: '1', name: 'Demo User' } };
  },
  async login(identifier, password) {
    await delay(1200);
    if (password === 'wrong') throw new Error('Incorrect password. Please try again.');
    return { access_token: 'jwt_mock_' + Date.now(), user: { id: '1', name: 'Demo User' } };
  },
  async oauthLogin(provider) {
    await delay(800);
    return { access_token: 'jwt_mock_' + Date.now(), user: { id: '1', name: 'Demo User' } };
  }
};

function delay(ms) { return new Promise(r => setTimeout(r, ms)); }
