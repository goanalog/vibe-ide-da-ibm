# Vibe IDE — Deployable Architecture

**What you get**
- `index.html` — the IDE (stays online)
- `sample.html` — the live page you overwrite on publish
- `assets/env.js` — environment passed to the IDE (Projects can rewrite this)
- Minimal `*.tf` — safe, resource-free outputs for Projects UI

**How it works**
- IDE loads `sample.html` by default.
- When you Push 🚀, only `sample.html` on your site is updated.
- The IDE remains available at its own URL.

**Wire a broker (optional)**
- Set Terraform var `push_api_url` to your Code Engine broker endpoint.
- The IDE will POST the HTML to that endpoint and auto-refresh the live site.
