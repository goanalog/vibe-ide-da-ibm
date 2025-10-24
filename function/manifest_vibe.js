// manifest_vibe.js
// Simple IBM Cloud Function that serves a minimal app manifest JSON.
// Designed to work without provider-specific parameters for reliability.

/**
 * Cloud Functions (OpenWhisk) action entry
 * @param {object} params - invocation params (query/body merged)
 * @returns {object} - object with body/status/headers for web action
 */
function main(params) {
  const name = (params && params.name) || "Vibe IDE • IBM Cloud";
  const now = new Date().toISOString();

  const response = {
    name,
    description: "Zero-config, reliable manifest endpoint (Terraform-deployed).",
    updated_at: now,
    links: {
      docs: "https://cloud.ibm.com/functions/",
      repo: "https://example.com/vibe/repo"
    },
    meta: {
      request_id: params.__ow_headers && params.__ow_headers["x-request-id"] || null,
      region: params.region || null,
      bucket: params.bucket || null
    }
  };

  // If this is running as a web action, we can return HTTP-style response
  if (params.__ow_method) {
    return {
      statusCode: 200,
      headers: { "content-type": "application/json; charset=utf-8" },
      body: response
    };
  }

  // classic action result
  return response;
}

exports.main = main;
