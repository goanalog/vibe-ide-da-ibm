# Vibe IDE — Deployable Architecture v1.3

**Zero inputs. Zero-cost. Serverless publishing on Code Engine (Node.js).**

- COS **Lite** static site with random bucket name
- Public-read policy + CORS enabled
- Code Engine **serverless HTTP broker** (scale-to-zero)
- `assets/env.js` **templated with live endpoint**
- **Initial publish** with readiness wait + retries
- **Primary output** = COS website endpoint

## Deploy
1) Upload ZIP to **Private Catalog**, add to **IBM Cloud Projects**.
2) Deploy runs automatically (no inputs).
3) Open **Primary Output** → your live site.
4) Edit in Vibe IDE → click **Push 🚀** → published.

## Notes
- Broker image defaults to a generic sample path (`var.ce_image`). Replace in Catalog defaults if your org requires a specific image.
- If your account blocks public-read, toggle `enable_public_read=false` and wire IAM/auth appropriately.
