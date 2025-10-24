
from ibm_boto3 import client
from ibm_botocore.client import Config

def main(args):
    cos = client(
        service_name='s3',
        ibm_api_key_id=args.get('__OW_IAM_NAMESPACE_API_KEY', ''),
        ibm_auth_endpoint='https://iam.cloud.ibm.com/identity/token',
        config=Config(signature_version='oauth'),
        endpoint_url=f"https://s3.{args.get('region','us-south')}.cloud-object-storage.appdomain.cloud"
    )
    bucket = args.get('bucket')
    html = args.get('html', '')
    env = args.get('env', '')
    try:
        cos.put_object(Bucket=bucket, Key='index.html', Body=html.encode('utf-8'), ContentType='text/html')
        if env:
            cos.put_object(Bucket=bucket, Key='js/env.js', Body=env.encode('utf-8'), ContentType='application/javascript')
        return {"status": "ok", "url": f"https://{bucket}.s3-website.{args.get('region','us-south')}.cloud-object-storage.appdomain.cloud"}
    except Exception as e:
        return {"error": str(e)}
