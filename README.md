# Vibe IDE • IBM Cloud — Terraform Bundle

This package deploys a **minimal, robust** stack using **IBM Cloud Object Storage** and **IBM Cloud Functions** with the most provider-compatible attributes.

## What gets created
- **COS instance (Lite)** and a bucket (auto-generated name unless you set `bucket_name`)
- Three starter objects in the bucket: `index.html`, `assets/env.js`, `assets/api.js`
- **Cloud Functions namespace** and a **Node.js 20 action** `manifest_vibe.js`

> We intentionally **avoid parameters/annotations blocks** that have varied across provider versions. This keeps `terraform plan/apply` reliable in Schematics and Projects.

## Quickstart

```bash
# Authenticate
ibmcloud login -r us-south
ibmcloud target -g Default

# From this folder:
terraform init
terraform apply -auto-approve
```

## Outputs

- `bucket_name` — your bucket for static assets
- `function_action_path` — namespace/action identifier
- `function_cli_invoke` — copy/paste CLI to invoke the action and print JSON
- `web_enable_hint` — one-liner to enable a public "web action" endpoint

### Enable a public web URL (optional)

```bash
# After apply:
ibmcloud fn action update manifest-vibe --web true --namespace vibe-ns

# Web URL (json):
https://us-south.functions.appdomain.cloud/api/v1/web/vibe-ns/default/manifest-vibe.json
```

## Notes

- The COS website hosting block is omitted for now to avoid brittle args across provider versions. You can still host static files by using object URLs or add website config later.
- The function does not require secrets; it echoes a stable JSON manifest. You may pass `?name=...` to customize the title.
