# Vibe IDE — IBM Cloud Project Update Package

This package deploys a Cloud Object Storage bucket with a production-ready Vibe IDE static site.
It **does not** rely on deprecated services. Public read is expected to be enabled by the account owner for the bucket.

## Deploy
1. Import into IBM Cloud Project as a Deployable Architecture, or run via Schematics.
2. Apply with defaults (region `us-south`, resource group `Default`).
3. Outputs: `vibe_ide_url`, `public_base_url`, `bucket_name`.

## Enable Public Read (one-time per bucket)
In the COS bucket UI → *Public access* → enable **Public Access** with **Object Reader** role.

## Push Flow
- The IDE shows a **Push to Cloud** button which links to the Project URL you pass via `project_url` variable.
- After editing, click **Export ZIP** to download your current site bundle if you want to attach it in your Project repo/PR.