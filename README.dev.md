# developer guide — vibe ide deployable architecture

This directory defines a complete **IBM Cloud Deployable Architecture (DA)** designed for onboarding to **IBM Cloud Projects** and the **Private Catalog**. It provisions all resources automatically via Terraform.

---

## 📐 architecture overview

| Component | IBM Cloud Service | Purpose |
|------------|------------------|----------|
| `ibm_cos_bucket.vibe_bucket` | Cloud Object Storage (Lite) | Hosts static website and user content. |
| `ibm_resource_instance.cos_instance` | Resource Instance | Creates the COS Lite service binding. |
| `ibm_code_engine_project.vibe_ce_project` | Code Engine | Backend API runtime for dynamic extensions. |
| `null_resource.render_env` | Local Exec | Renders `env.js` with the backend URL at deploy time. |

---

## 🧰 files

| File | Purpose |
|------|----------|
| **main.tf** | Resources only — no providers or outputs. |
| **versions.tf** | Terraform configuration and provider versions. |
| **variables.tf** | Input variables (`region`, optional Slack). |
| **outputs.tf** | Exposed outputs for IBM Cloud Projects. |
| **manifest.yaml** | Metadata manifest for Catalog onboarding. |
| **catalog.json** | Simplified metadata for import UI. |
| **index.html** | The deployed web IDE. |
| **env.js** | Auto-injected Code Engine endpoint configuration. |
| **api.js / ui.js** | Front-end logic for manifesting and publishing. |

---

## 🧩 deployment flow

1. **Terraform Init/Apply**
   - Creates a COS Lite instance, bucket, and Code Engine project.
   - Injects the backend URL into `env.js`.

2. **Outputs**
   - `primaryoutputlink` → The public Vibe IDE web URL.
   - `code_engine_url` → Optional backend API.
   - Additional COS details for debugging.

3. **User Experience**
   - End user opens Vibe IDE in the browser.
   - Edits HTML/CSS/JS, hits *Manifest* to preview live.
   - Pushes updates to their COS bucket or IBM Cloud Project.

---

## 🧱 validation & compatibility

- **Provider versions**: `ibm >= 1.84.0`, `random >= 3.6.0`  
- **Terraform version**: `>= 1.3.0`  
- **Tested regions**: `us-south`, `eu-de`, `jp-tok`  
- **Catalog**: `manifest.yaml` uses `primary_output: primaryoutputlink`

---

## 🧭 support & contact

- Email: realbrendan@us.ibm.com  
- Support URL: https://www.ibm.com/cloud/support

---

## ⚡ license & attribution

Released for demonstration and educational use.  
Contains creative assets and descriptive text authored collaboratively with AI under the **Vibe Coding** project.
