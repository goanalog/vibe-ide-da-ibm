/**
 * Edit these two lines:
 */
const VIBE_ACTION_URL = "<SET_YOUR_WEB_ACTION_URL_HERE>"; // e.g., https://us-south.functions.appdomain.cloud/api/v1/web/.../manifest_vibe.json
const VIBE_BUCKET = "<SET_YOUR_BUCKET_NAME>";

async function manifest() {
  const key = document.getElementById('key').value || 'index.html';
  const bucket = document.getElementById('bucket').value || VIBE_BUCKET;
  const html = document.getElementById('html').value;
  const log = document.getElementById('log');
  log.textContent = "Calling function...";
  try {
    const resp = await fetch(`${VIBE_ACTION_URL}?bucket=${encodeURIComponent(bucket)}&key=${encodeURIComponent(key)}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ html_input: html })
    });
    const data = await resp.json();
    log.textContent = JSON.stringify(data, null, 2);
    if (data.body && data.body.object_url) {
      const a = document.createElement('a');
      a.href = data.body.object_url;
      a.textContent = "Open object URL";
      a.target = "_blank";
      log.appendChild(document.createElement('br'));
      log.appendChild(a);
    }
  } catch (e) {
    log.textContent = "Error: " + e.message;
  }
}

document.getElementById('go').addEventListener('click', manifest);
