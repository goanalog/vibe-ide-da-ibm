
# Vibe IDE — Live Static Site (IBM Cloud)

This Deployable Architecture provisions:
- **IBM Cloud Object Storage (Lite)** instance
- A **regional bucket** with **Static Website** hosting enabled
- Publishes `index.html` using either your **Catalog-form input** or the **bundled sample**

## How it works
1. Terraform creates a COS instance (plan: **lite**) and a regional bucket.
2. Website hosting is enabled with `index.html` as the index & error doc.
3. The initial page is uploaded via Terraform:
   - If you provided **Initial HTML** in the Customize step, it's published.
   - Otherwise, we publish the bundled sample in `./static-site/index.html`.

## Public access
IBM COS static websites require **public read** on the bucket.

This configuration automatically applies the required "Object Reader" policy to the "Public Access" IAM group to ensure the website is viewable immediately after deployment.

If your organization restricts applying policies to the "Public Access" group, this deployment may fail or require manual intervention.

## Outputs
- **primary_output** — the public website URL (use this to open the app)

## Inputs
- **cos_plan**: defaults to `lite` (per your 1A selection)
- **initial_html**: optional string; leave empty to use the bundled sample

## Notes
- This package is validated for Terraform 1.12 in IBM Cloud Projects/Catalog environments.
- Names are auto-suffixed for global uniqueness.

