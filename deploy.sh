#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-us-south}"
RG="${RG:-default}"
COS_INSTANCE="${COS_INSTANCE:-cos-vibe}"
NAMESPACE="${NAMESPACE:-vibe-ns}"
ACTION="${ACTION:-manifest_vibe}"
BUCKET="${BUCKET:-}"

echo "Login/target..."
ibmcloud login -r "$REGION"
ibmcloud target -g "$RG"

echo "Plugins..."
ibmcloud plugin install cloud-functions -f || true
ibmcloud plugin install resource-group -f || true

echo "Create COS instance (if missing)..."
ibmcloud resource service-instance-create "$COS_INSTANCE" cloud-object-storage lite "$REGION" || true

echo "Namespace..."
ibmcloud fn namespace create "$NAMESPACE" || true
ibmcloud fn property set --namespace "$NAMESPACE"

echo "Package action bundle..."
pushd functions >/dev/null
npm install
zip -r ../manifest_vibe_action.zip manifest_vibe.js node_modules package.json
popd >/dev/null

echo "Create/Update action..."
ibmcloud fn action update "$ACTION" --kind nodejs:20 manifest_vibe_action.zip || ibmcloud fn action create "$ACTION" --kind nodejs:20 manifest_vibe_action.zip

echo "Bind COS to action..."
ibmcloud fn service bind cloud-object-storage "$COS_INSTANCE" "$ACTION" || true

echo "Web-enable..."
ibmcloud fn action update "$ACTION" --web true

if [[ -n "${BUCKET}" ]]; then
  echo "Invoke once to write index.html..."
  ibmcloud fn action invoke "$ACTION" -r -p bucket "$BUCKET" -p key index.html -p html_input "<!doctype html><html><body><h1>Vibe!</h1></body></html>"
else
  echo "Set BUCKET env var and re-run to auto-create index.html"
fi

echo "Done."
