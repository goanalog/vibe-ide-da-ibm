# Vibe IDE — Live Static Site (IBM Cloud)

This Deployable Architecture provisions a dynamic static website on IBM Cloud Object Storage.

It deploys:
* **IBM Cloud Object Storage (COS) Instance**: A new `lite` plan instance is created, or you can provide an existing instance.
* **A COS Bucket**: A regional bucket is created with **Static Website** hosting enabled.
* **Automated Public Access**: The required "Object Reader" IAM policy is automatically applied to the "Public Access" group.
* **A Dynamic `index.html`**: A sample "Vibe IDE" webpage is published. This page reads data from your deployment (like the bucket name) and displays it dynamically.

---

## How it works

1.  **COS Instance**: The automation first checks if you provided an `existing_cos_instance_id`.
    * If **yes**, it uses that existing instance.
    * If **no**, it creates a new `lite` plan COS instance. This prevents failures if you already have a `lite` instance in your account.
2.  **Bucket & Website**: It creates a regional bucket and enables static website hosting.
3.  **Public Access**: It automatically finds the "Public Access" group in your account and grants it the `Object Reader` role for the new bucket. This makes the website immediately viewable.
4.  **Dynamic HTML**:
    * If you provide custom HTML in the `initial_html` input, it publishes that.
    * If you leave `initial_html` blank, it uses `templatefile()` to inject deployment details (like your new bucket's name and region) into the `static-site/index.html.tftpl` sample file.
    * The final, rendered HTML is uploaded to your bucket.

---

## Required IAM Permissions

To run this deployment, the user or API key must have the following minimum permissions:

* **Service: Cloud Object Storage**
    * Roles: `Editor` (to create/use instances and create buckets)
* **Service: IAM Identity Service**
    * Roles: `Viewer` (to look up the "Public Access" group)
* **Service: IAM Access Management**
    * Roles: `Administrator` or `Editor` (to assign the policy to the access group)

---

## Inputs

| Name | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| `region` | IBM provider region for ancillary services. | `string` | `"us-south"` |
| `existing_cos_instance_id` | Optional: ID of an existing COS instance. If empty, a new `lite` instance is created. | `string` | `""` |
| `cos_plan` | COS plan to use if creating a new instance. | `string` | `"lite"` |
| `bucket_region` | Region for the new COS bucket. | `string` | `"us-south"` |
| `bucket_storage_class` | Storage class for the new bucket. | `string` | `"smart"` |
| `initial_html` | Optional: Custom HTML to publish as `index.html`. Leave blank to use the dynamic sample. | `string` | `""` |

## Outputs

| Name | Description |
| :--- | :--- |
| `primary_output` | The public, viewable URL for your new static website. |
| `bucket_name` | The name of the deployed COS bucket. |
| `cos_instance_name` | The name of the COS instance used. |