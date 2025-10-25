# Vibe IDE — Remix. Manifest. Share. (v1.3.4)

Paste code. Hit **Push**. Manifest a live website instantly on IBM Cloud — zero configuration, zero cost.
This package deploys a full in-browser code editor with live preview, a public share link, and a tiny broker service
on IBM Code Engine that writes your HTML into IBM Cloud Object Storage.

## What you get
- ✨ Live-preview code editor — see changes as you type
- 🚀 Push to publish — updates your public `sample.html`
- 🔗 Share — one click copies your live link
- ♻️ Auto-refresh after publish (cache-busted)
- 🪄 Initial vibes manifested — sample included to remix
- 🔒 IDE is never overwritten — edits only update `sample.html`

## How it works
- **Object Storage (Lite)** hosts your static site (index & error both set to `index.html`)
- **Code Engine** exposes a `publish` endpoint to upload `sample.html` and `assets/env.js`
- The IDE always loads the current `sample.html`, so users can remix safely

## Zero input defaults
- Region: inherited from workspace (defaults safe for `us-south`)
- Public read: enabled for bucket policy (guardrails permitting)
- Scale: CE app min=0, max=1 (idle = $0)

## Primary Output
The IBM Cloud Projects UI opens your live site at:
**`primaryoutputlink` → COS website endpoint for `/sample.html`**

## One-minute test
1. Open the IDE (index.html)
2. Paste `<h1>It works!</h1>`
3. Click **Push 🚀**
4. Click **Live vibe** → Confirm your changes
5. Click **Share** → Link on clipboard

---

**Built for vibes.** Runs on IBM Cloud Object Storage + Code Engine.
