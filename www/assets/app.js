(function () {
  const editor = document.getElementById('editor');
  const preview = document.getElementById('preview');
  const btnPreview = document.getElementById('btnPreview');
  const btnExport = document.getElementById('btnExport');
  const btnPush = document.getElementById('btnPush');

  const SAMPLE = `<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>My Vibe Page</title>
  <style>
    body { font-family: 'IBM Plex Sans', system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 40px; }
    .hero { padding: 56px; border-radius: 20px; background: linear-gradient(135deg, #0f1530, #111939); color:#e8edff; border:1px solid rgba(232,237,255,.15) }
    h1 { margin: 0 0 10px; font-size: 42px }
    p { color: #aab3d8; font-size: 18px }
    .tag { display:inline-block; padding:6px 10px; border-radius:999px; background:#0f1530; color:#e8edff; font-weight:600; font-size:12px }
  </style>
</head>
<body>
  <div class="hero">
    <div class="tag">Vibe</div>
    <h1 class="plex-serif" style="font-family:'IBM Plex Serif', Georgia, serif; font-weight:300">Hello, IBM Cloud 👋</h1>
    <p>You're editing this page inside the Vibe IDE. Click <b>Push to Cloud</b> to publish your changes.</p>
  </div>
</body>
</html>`;

  const saved = localStorage.getItem('vibe.page');
  editor.value = saved || SAMPLE;

  function render() {
    const doc = editor.value;
    const blob = new Blob([doc], { type: 'text/html' });
    const url = URL.createObjectURL(blob);
    preview.src = url;
    setTimeout(() => URL.revokeObjectURL(url), 2000);
    localStorage.setItem('vibe.page', editor.value);
  }

  btnPreview.addEventListener('click', render);
  render();

  btnExport.addEventListener('click', async () => {
    const zip = new JSZip();
    zip.file('index.html', editor.value);
    const envJs = 'window.__VIBE_ENV__=' + JSON.stringify(window.__VIBE_ENV__ || {});
    zip.folder('assets').file('env.js', envJs);
    const blob = await zip.generateAsync({ type: 'blob' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'vibe-site.zip';
    a.click();
    setTimeout(() => URL.revokeObjectURL(a.href), 2000);
  });

  // --- Auth & Push ---
  const appID = new AppID();
  let appidInit = false;

  async function initAuth() {
    const env = window.__VIBE_ENV__ || {};
    const { APPID_CLIENT_ID, APPID_TENANT_ID, APP_REGION } = env;
    if (!APPID_CLIENT_ID || !APPID_TENANT_ID || !APP_REGION) return;
    const discoveryEndpoint = `https://${APP_REGION}.appid.cloud.ibm.com/oauth/v4/${APPID_TENANT_ID}/.well-known/openid-configuration`;
    try {
      await appID.init({ clientId: APPID_CLIENT_ID, discoveryEndpoint });
      appidInit = true;
      console.log('App ID SDK initialized.');
    } catch (e) {
      console.error('App ID init error:', e);
    }
  }
  initAuth();

  btnPush.addEventListener('click', async () => {
    const env = window.__VIBE_ENV__ || {};
    const PUSH_API_URL = env.PUSH_API_URL;
    if (!PUSH_API_URL) { alert('Push API URL not configured.'); return; }

    if (!appidInit) {
      await initAuth();
      if (!appidInit) { alert('Authentication not configured.'); return; }
    }

    const original = btnPush.textContent;
    btnPush.textContent = 'Authenticating…'; btnPush.disabled = true;
    try {
      const tokens = await appID.signin();
      btnPush.textContent = 'Publishing…';
      const resp = await fetch(PUSH_API_URL, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${tokens.accessToken}`,
          'Content-Type': 'text/plain'
        },
        body: editor.value
      });
      if (!resp.ok) {
        const t = await resp.text();
        throw new Error(`${resp.status} ${t}`);
      }
      btnPush.textContent = 'Success!';
      setTimeout(() => { btnPush.textContent = original; btnPush.disabled = false; }, 1500);
    } catch (e) {
      console.error(e);
      alert('Push failed: ' + e.message);
      btnPush.textContent = original; btnPush.disabled = false;
    }
  });
})();