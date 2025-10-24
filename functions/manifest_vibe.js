/**
 * manifest_vibe.js
 * IBM Cloud Function (Node.js 20)
 * Uses automatic service binding (__bx_creds) for COS.
 * Returns CORS-safe JSON with a direct object URL.
 */
const AWS = require('ibm-cos-sdk');

async function main(params) {
  try {
    const bx = params.__bx_creds && params.__bx_creds.cloud_object_storage;
    if (!bx) {
      return {
        statusCode: 500,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: { error: "__bx_creds.cloud_object_storage not found. Bind COS to this action." }
      };
    }

    const bucket = params.bucket || process.env.VIBE_BUCKET || "vibe-bucket";
    const key    = params.key    || "index.html";
    const html   = params.html_input || "<!doctype html><html><body><h1>Vibe!</h1></body></html>";

    const s3 = new AWS.S3({
      endpoint: bx.endpoints,
      apiKeyId: bx.apikey,
      serviceInstanceId: bx.resource_instance_id,
      ibmAuthEndpoint: "https://iam.cloud.ibm.com/identity/token",
      signatureVersion: 'iam'
    });

    await s3.putObject({
      Bucket: bucket,
      Key: key,
      Body: html,
      ContentType: "text/html"
    }).promise();

    const region = bx.region || "us-south";
    const object_url = `https://${bucket}.s3.${region}.cloud-object-storage.appdomain.cloud/${key}`;

    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: {
        status: "vibe manifested",
        object_url,
        saved_key: key,
        preview: html.slice(0, 160)
      }
    };
  } catch (e) {
    return {
      statusCode: 500,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: { error: e.message || String(e) }
    };
  }
}
exports.main = main;
