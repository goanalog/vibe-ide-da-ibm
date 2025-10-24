// assets/api.js
export async function fetchManifest(url) {
  const res = await fetch(url, { headers: { "accept": "application/json" }});
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}
