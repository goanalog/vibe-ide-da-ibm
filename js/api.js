
export async function pushLive(html) {
  const url = window.VIBE_CONFIG?.FUNCTION_URL;
  if (!url) throw new Error("FUNCTION_URL not set in js/env.js");
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ html })
  });
  return await res.json();
}

export async function manifestHTML(html) {
  const blob = new Blob([html], { type: "text/html" });
  return { url: URL.createObjectURL(blob) };
}
