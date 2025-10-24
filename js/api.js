
export async function pushLive(html) {
  const url = window.VIBE_CONFIG?.FUNCTION_URL;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ html })
  });
  return await res.json();
}
