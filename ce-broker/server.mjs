import express from 'express';
import multer from 'multer';
import AWS from 'aws-sdk';

const app = express();
const upload = multer();

function s3Client() {
  const endpoint = process.env.COS_ENDPOINT;
  const s3 = new AWS.S3({
    endpoint,
    s3ForcePathStyle: true,
    signatureVersion: 'v4',
    accessKeyId: process.env.COS_HMAC_ACCESS_KEY_ID || process.env.COS_API_KEY,
    secretAccessKey: process.env.COS_HMAC_SECRET_ACCESS_KEY || 'secret',
  });
  return s3;
}

app.get('/health', (_, res)=>res.json({ok:true}));

app.post('/publish', upload.single('file'), async (req,res)=>{
  try{
    const bucket = req.body.bucket || process.env.BUCKET_NAME;
    const region = req.body.region || process.env.REGION;
    const key = req.body.key || 'sample.html';
    const file = req.file;
    if (!bucket || !file) return res.status(400).json({error:'bucket and file required'});
    const s3 = s3Client();
    await s3.putObject({
      Bucket: bucket,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype || 'text/html',
      ACL: 'public-read'
    }).promise();
    const website = process.env.WEBSITE_ENDPOINT || `https://${bucket}.s3-web.${region}.cloud-object-storage.appdomain.cloud/${key}`;
    return res.json({ok:true, key, bucket, website});
  }catch(e){
    res.status(500).json({error:e.message});
  }
});

const port = process.env.PORT || 8080;
app.listen(port, ()=>console.log('broker on', port));