import { loadFromBucket, manifestHTML, pushToBucket, pushToProject, forkMyOwn } from "./api.js";
const editor = document.getElementById("vibe-editor");
const preview = document.getElementById("vibe-preview");
function toast(msg) { alert(msg); }
async function run(action) {
  try {
    if (action === "load") {
      const data = await loadFromBucket(); editor.value = data.html || "";
    } else if (action === "manifest") {
      const out = await manifestHTML(editor.value); preview.src = out.url;
    } else if (action === "push") {
      const out = await pushToBucket(editor.value); preview.src = out.url; toast(`✨ Your vibe is live at: ${out.url}`);
    } else if (action === "project") {
      const out = await pushToProject(editor.value); toast(out.status === "ok" ? "📡 Project update initiated." : (out.message || "Project update sent."));
    } else if (action === "fork") {
      const out = await forkMyOwn(); toast(out.html_url ? `🍴 Forked! ${out.html_url}` : (out.message || "Fork request sent."));
    }
  } catch (e) { console.error(e); toast(`Error: ${e.message}`); }
}
document.querySelectorAll("[data-action]").forEach(btn => btn.addEventListener("click", () => run(btn.dataset.action)));