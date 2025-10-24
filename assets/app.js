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
    body { font-family: 'IBM Plex Sans', system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 40px; color:#0b0f1a; }
    .hero { padding: 56px; border-radius: 18px; background: linear-gradient(135deg,#eef3ff,#f7fbff); border: 1px solid #e6edff; box-shadow: 0 20px 60px rgba(34,59,170,0.08) }
    h1 { margin: 0 0 10px; letter-spacing: 0.2px; }
    p { color: #3c4a78; margin: 0; }
    .tag { display:inline-block; padding:8px 12px; border-radius:999px; background:#0f1530; color:#e8edff; font-weight:600; font-size:12px; letter-spacing:0.25px }
    .sub { font-family: 'IBM Plex Serif', Georgia, serif; font-weight:300; font-size: 18px; color:#2b335b; margin-top: 8px; }
  </style>
</head>
<body>
  <div class="hero">
    <div class="tag">Vibe</div>
    <h1>Hello, IBM Cloud 👋</h1>
    <p class="sub">You're editing this page inside the Vibe IDE. Click <b>Push to Cloud</b> to publish your changes.</p>
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

  // Optional Push (frontend-only; backend must be configured separately)
  btnPush.addEventListener('click', async () => {
    const env = window.__VIBE_ENV__ || {};
    const url = env.PUSH_API_URL;
    if (!url) {
      alert('Push API URL is not configured. Ask your admin to enable Code Engine broker.');
      return;
    }
    if (!confirm('Publish your current HTML to the configured bucket?')) return;

    const originalText = btnPush.textContent;
    btnPush.textContent = 'Publishing...';
    btnPush.disabled = true;

    try {
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'text/plain' },
        body: editor.value
      });
      if (!res.ok) throw new Error('HTTP ' + res.status + ' — ' + (await res.text()));
      btnPush.textContent = 'Success!';
    } catch (e) {
      alert('Push failed: ' + e.message);
      btnPush.textContent = originalText;
      btnPush.disabled = false;
      return;
    }

    setTimeout(() => {
      btnPush.textContent = originalText;
      btnPush.disabled = false;
    }, 1500);
  });
})();