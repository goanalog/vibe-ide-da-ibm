# Vibe IDE — Code Engine (Static + Functions‑Ready)

This bundle deploys the Vibe IDE UI to IBM Cloud Object Storage (COS). Region and resource group are defaulted and hidden.

## What you get
- A COS bucket with public-read objects for:
  - `index.html` (the IDE shell)
  - `assets/env.js` (runtime config — change this any time without re-deploy)
  - `assets/api.js` and `assets/ui.js` (client logic + visuals)
- Outputs `vibe_ide_url` and `public_base_url` after `apply`

## Functions‑ready
When you stand up a Code Engine HTTP function/app, set its base URL in `assets/env.js` under `FUNCTION_BASE_URL`.
The IDE will call:
- `GET {base}/ping`
- `POST {base}/echo` (body: `{ "text": "..." }`)

Until then, the IDE uses local mocks so the UI is fully interactive.

## Terraform
```sh
terraform init
terraform apply -auto-approve
# check outputs: vibe_ide_url
```

## Notes
- Default region: `us-south`
- Default resource group: `Default`
- Buckets are created with a random suffix to avoid name collisions.