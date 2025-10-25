# Vibe IDE — Deployable Architecture v1.3.3

Zero inputs. Zero cost. Code Engine serverless publish to COS.

## What’s new in 1.3.3
- Share button (copies live link)
- Publish results log modal (non-blocking)
- IDE edits/publishes **sample.html** (IDE never overwritten)
- env.js includes `PRIMARY_OUTPUT` (COS website endpoint)

## Deploy
1. Import ZIP to Private Catalog → Add to IBM Cloud Projects
2. Auto-deploy runs; Primary Output opens `/sample.html`
3. Click **Remix your vibe in Vibe IDE** to open the editor
4. Edit → **Push 🚀** → site updates; preview refreshes automatically

## Files
- `index.html` → Vibe IDE (editor)
- `sample.html` → Public site
- `assets/env.js` → Generated at deploy with live endpoints
