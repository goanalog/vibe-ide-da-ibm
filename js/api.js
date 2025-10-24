
export async function pushLive(html) {
  const url = window.VIBE_CONFIG?.FUNCTION_URL;
  if (!url) throw new Error("FUNCTION_URL missing in env.js");
  const payload = {
    html,
    bucket: window.VIBE_CONFIG.BUCKET,
    region: window.VIBE_CONFIG.REGION
  };
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });
  return await res.json();
}

export async function manifestHTML(html) {
  const blob = new Blob([html], { type: "text/html" });
  return { url: URL.createObjectURL(blob) };
}
