
from ibm_boto3 import client
from ibm_botocore.client import Config

def main(args):
    # Expect these keys to be passed by the web action environment:
    #   bucket: COS bucket name
    #   region: IBM Cloud region (e.g., us-south)
    #   html:   HTML string for index.html
    #   env:    (optional) JS string for js/env.js
    region = args.get('region', 'us-south')
    bucket = args.get('bucket')
    html   = args.get('html', '')
    env_js = args.get('env', '')

    if not bucket:
        return { "error": "Missing 'bucket' in request." }
    if html is None:
        html = ''

    try:
        cos = client(
            service_name='s3',
            ibm_api_key_id=args.get('__OW_IAM_NAMESPACE_API_KEY', ''),
            ibm_auth_endpoint='https://iam.cloud.ibm.com/identity/token',
            config=Config(signature_version='oauth'),
            endpoint_url=f"https://s3.{region}.cloud-object-storage.appdomain.cloud"
        )

        # Write index.html
        cos.put_object(
            Bucket=bucket,
            Key='index.html',
            Body=html.encode('utf-8'),
            ContentType='text/html'
        )
        # Optional: write js/env.js if provided
        if env_js:
            cos.put_object(
                Bucket=bucket,
                Key='js/env.js',
                Body=env_js.encode('utf-8'),
                ContentType='application/javascript'
            )

        return {
            "status": "ok",
            "url": f"https://{bucket}.s3-website.{region}.cloud-object-storage.appdomain.cloud"
        }
    except Exception as e:
        return { "error": str(e) }
