# Vibe IDE — Cloud Manifest (IBM Cloud Functions + COS)

The minimal, reliable setup: a Node.js IBM Cloud Function that writes `index.html` into your COS bucket using automatic service bindings — no static keys in code.

## Deploy (concise)

```bash
# 0) Prereqs: ibmcloud CLI + plugins
ibmcloud version
ibmcloud plugin install cloud-functions -f
ibmcloud plugin install resource-group -f

# 1) Login + target
ibmcloud login -r us-south
ibmcloud target -g <YOUR_RESOURCE_GROUP>

# 2) Create COS + bucket (or reuse existing)
ibmcloud resource service-instance-create cos-vibe cloud-object-storage lite us-south
# Create a regional bucket in us-south (UI or CLI). Example bucket name:
export VIBE_BUCKET=<your-unique-bucket-name>

# 3) Namespace + Action
ibmcloud fn namespace create vibe-ns
ibmcloud fn property set --namespace vibe-ns

# 4) Create Action with Node.js 20 and include node_modules
cd functions
npm install
zip -r ../manifest_vibe_action.zip manifest_vibe.js node_modules package.json
cd ..
ibmcloud fn action create manifest_vibe --kind nodejs:20 manifest_vibe_action.zip

# 5) Bind COS to the action (injects __bx_creds automatically)
ibmcloud fn service bind cloud-object-storage cos-vibe manifest_vibe

# 6) Web-enable the action (public HTTPS endpoint)
ibmcloud fn action update manifest_vibe --web true

# 7) Call it once to write index.html
ibmcloud fn action invoke manifest_vibe -r -p bucket "$VIBE_BUCKET" -p key index.html -p html_input "<!doctype html><html><body><h1>Vibe!</h1></body></html>"
```

**Response** includes `object_url` you can open in a browser.

## Frontend test page
Open `web/index.html` and click “Manifest Vibe” — it will call your web action URL.

Edit `web/js/api.js` and set:
```js
const VIBE_ACTION_URL = "<your web action URL here>";
const VIBE_BUCKET = "<your bucket name>";
```

## Notes
- Uses `__bx_creds.cloud_object_storage` injected by the service binding; no secrets in code.
- CORS headers (`Access-Control-Allow-Origin: *`) are returned by the function.
- This avoids brittle Terraform provider surface while remaining infra-agnostic.
