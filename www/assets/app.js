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
    body { font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 32px; }
    .hero { padding: 48px; border-radius: 16px; background: linear-gradient(135deg,#eef3ff,#f7fbff); border: 1px solid #e6edff; }
    h1 { margin: 0 0 8px; }
    p { color: #4c5a88 }
    .tag { display:inline-block; padding:6px 10px; border-radius:999px; background:#0f1530; color:#e8edff; font-weight:600; font-size:12px }
  </style>
</head>
<body>
  <div class="hero">
    <div class="tag">Vibe</div>
    <h1>Hello, IBM Cloud 👋</h1>
    <p>You're editing this page inside the Vibe IDE. Click <b>Push to Cloud</b> to open your IBM Cloud Project and deploy your changes.</p>
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

  btnPush.addEventListener('click', () => {
    const url = (window.__VIBE_ENV__ && window.__VIBE_ENV__.projectUrl) || '';
    if (!url) {
      alert('Project URL not configured. Ask your admin to pass `project_url` at deploy time.');
      return;
    }
    window.open(url, '_blank');
  });
})();