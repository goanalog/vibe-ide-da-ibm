import express from 'express';
import multer from 'multer';
import AWS from 'aws-sdk';

const app = express();
const upload = multer();
const PORT = process.env.PORT || 8080;

app.get('/health', (req, res) => res.status(200).json({ ok: true }));

function makeS3(region, cosEndpoint) {
  const endpoint = new AWS.Endpoint(cosEndpoint || `s3.${region}.cloud-object-storage.appdomain.cloud`);
  const s3 = new AWS.S3({
    endpoint,
    s3ForcePathStyle: true,
    signatureVersion: 'v4'
  });
  return s3;
}

app.post('/publish', upload.single('file'), async (req, res) => {
  try {
    const { bucket, region, key } = req.body;
    if (!bucket || !region || !key || !req.file) {
      return res.status(400).json({ error: 'bucket, region, key, and file are required' });
    }
    const s3 = makeS3(region);
    await s3.putObject({
      Bucket: bucket,
      Key: key,
      Body: req.file.buffer,
      ContentType: req.file.mimetype || 'application/octet-stream',
      ACL: 'public-read'
    }).promise();
    return res.status(200).json({ ok: true, key });
  } catch (e) {
    console.error('Publish error:', e);
    return res.status(500).json({ error: e.message });
  }
});

app.listen(PORT, () => { console.log(`Vibe broker listening on ${PORT}`) });
