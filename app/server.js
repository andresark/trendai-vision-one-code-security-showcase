const express = require('express');
const app = express();

// ──────────────────────────────────────────────────────────────────────────
// WARNING: This application is INTENTIONALLY vulnerable.
// It exists solely to demonstrate Trend Vision One Artifact Scanner (TMAS)
// detection capabilities. Do NOT use any of this code in production.
// ──────────────────────────────────────────────────────────────────────────

// Hardcoded credentials (TMAS Secrets Scanner will flag these)
const DB_PASSWORD = "SuperSecret123!";
const API_TOKEN = "ghp_1234567890abcdefghijklmnopqrstuvwxyz";
const AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE";
const AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY";
const PRIVATE_KEY = `-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA0Z3VS5JJcds3xfn/ygWyF8PbnGy0AHB7MhgHcTz6sE2I2yPB
aFDrBz9vFqU4yBpV0gBXSMz1Ezc2DICRhHPIbZOlYMULcx0ky3HUDJnHJIQSr1G
wgs/kOkMpCMoQLGKM8ERYXQP8Y3RBpsXAHJPb+JwC5c0I8hVpDBdp0bfBLjGCw==
-----END RSA PRIVATE KEY-----`;

// Slack webhook (another common secret leak)
const SLACK_WEBHOOK = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX";

app.get('/', (req, res) => {
  res.json({
    status: 'running',
    message: 'Intentionally vulnerable demo app for TMAS scanning'
  });
});

app.listen(3000, () => {
  console.log('Demo app running on port 3000');
});
