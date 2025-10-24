/**
 * Runtime environment for Vibe IDE.
 * Configure FUNCTION_BASE_URL once your Code Engine Function (or App) is available.
 * Keep this file small and cacheable; you can update it in COS without redeploying Terraform.
 */
window.__VIBE_ENV__ = {
  NOTE: "Set FUNCTION_BASE_URL to your Code Engine function base when ready.",
  FUNCTION_BASE_URL: "", // e.g., "https://example.codeengine.appdomain.cloud"
};