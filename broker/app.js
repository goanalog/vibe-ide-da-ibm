// broker/app.js
const express = require('express');
const rateLimit = require('express-rate-limit');
const IBM = require('ibm-cos-sdk');
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const {
  COS_API_KEY, COS_ENDPOINT, COS_INSTANCE_CRN, BUCKET_NAME,
  APPID_TENANT_ID, APP_REGION
} = process.env;

if (!COS_API_KEY || !COS_ENDPOINT || !COS_INSTANCE_CRN || !BUCKET_NAME) {
  console.error('Missing COS configuration env vars.');
  process.exit(1);
}
if (!APPID_TENANT_ID || !APP_REGION) {
  console.error('Missing App ID env (APPID_TENANT_ID, APP_REGION).');
  process.exit(1);
}

const cos = new IBM.S3({
  endpoint: COS_ENDPOINT,
  apiKeyId: COS_API_KEY,
  serviceInstanceId: COS_INSTANCE_CRN
});

const publishLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many publish requests. Please try again after 15 minutes.',
  standardHeaders: true
});

const issuer = `https://${APP_REGION}.appid.cloud.ibm.com/oauth/v4/${APPID_TENANT_ID}`;
const client = jwksClient({
  jwksUri: `${issuer}/.well-known/jwks.json`,
  cache: true,
  cacheMaxEntries: 5,
  cacheMaxAge: 10 * 60 * 1000
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, function(err, key) {
    if (err) return callback(err);
    const signingKey = key.getPublicKey();
    callback(null, signingKey);
  });
}

function requireBearer(req, res, next) {
  const auth = req.headers['authorization'] || '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : null;
  if (!token) return res.status(401).send('Missing Bearer token');
  jwt.verify(token, getKey, { algorithms: ['RS256'], issuer }, (err, decoded) => {
    if (err) return res.status(401).send('Invalid token: ' + err.message);
    req.user = decoded;
    next();
  });
}

const app = express();
app.use(express.text({ type: '*/*', limit: '5mb' }));

app.get('/health', (req, res) => res.status(200).send('OK'));

app.post('/publish', requireBearer, publishLimiter, async (req, res) => {
  try {
    await cos.putObject({
      Bucket: BUCKET_NAME,
      Key: 'index.html',
      Body: req.body || '',
      ContentType: 'text/html'
    }).promise();
    res.status(200).send('Publish successful!');
  } catch (e) {
    console.error('COS putObject error:', e);
    res.status(500).send('Error publishing to COS');
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => console.log('Broker listening on', port));
