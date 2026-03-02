/**
 * Script to generate OAuth authorization link for enterprise integrations
 * 
 * Usage:
 *   node generate-oauth-link.js <provider> <apiKey> [options]
 * 
 * Example:
 *   node generate-oauth-link.js instagram 6064530c18ad983394e80e98a7dae1683fc5f6b4332309b7345cfa8e3bb36bd6
 *   node generate-oauth-link.js facebook YOUR_API_KEY --onboarding
 *   node generate-oauth-link.js mastodon YOUR_API_KEY --external-url=https://mastodon.social
 */

const jwt = require('jsonwebtoken');
const https = require('https');
const http = require('http');
require('dotenv').config();

// Parse command line arguments
const args = process.argv.slice(2);

if (args.length < 2) {
  console.error('Usage: node generate-oauth-link.js <provider> <apiKey> [options]');
  console.error('\nExamples:');
  console.error('  node generate-oauth-link.js instagram YOUR_API_KEY');
  console.error('  node generate-oauth-link.js facebook YOUR_API_KEY --onboarding');
  console.error('  node generate-oauth-link.js mastodon YOUR_API_KEY --external-url=https://mastodon.social');
  console.error('\nOptions:');
  console.error('  --onboarding              Enable onboarding flow');
  console.error('  --refresh-id=<id>         Refresh token ID');
  console.error('  --external-url=<url>      External URL (for self-hosted like Mastodon)');
  console.error('  --webhook-url=<url>       Webhook URL for notifications');
  console.error('  --redirect-url=<url>      Custom redirect URL after OAuth');
  process.exit(1);
}

const provider = args[0];
const apiKey = args[1];

// Parse optional arguments
const options = {};
for (let i = 2; i < args.length; i++) {
  const arg = args[i];
  if (arg === '--onboarding') {
    options.onboarding = true;
  } else if (arg.startsWith('--refresh-id=')) {
    options.refreshId = arg.split('=')[1];
  } else if (arg.startsWith('--external-url=')) {
    options.externalUrl = arg.split('=')[1];
  } else if (arg.startsWith('--webhook-url=')) {
    options.webhookUrl = arg.split('=')[1];
  } else if (arg.startsWith('--redirect-url=')) {
    options.redirectUrl = arg.split('=')[1];
  }
}

// Configuration
const JWT_SECRET = process.env.JWT_SECRET || 'dev-jwt-secret-change-this-in-production-make-it-very-long-and-random';
const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000';

console.log('🔐 Generating OAuth link...\n');
console.log(`Provider: ${provider}`);
console.log(`API Key: ${apiKey}`);
console.log(`Options:`, options);
console.log('');

// Create JWT payload
const payload = {
  apiKey,
  ...options
};

// Generate JWT token
const token = jwt.sign(payload, JWT_SECRET);

console.log('📝 Generated JWT Token:');
console.log(token);
console.log('');

// Make API request
const url = new URL(`/enterprise/integrations/${provider}`, BACKEND_URL);
const requestData = JSON.stringify({ params: token });

const isHttps = url.protocol === 'https:';
const lib = isHttps ? https : http;

const requestOptions = {
  hostname: url.hostname,
  port: url.port || (isHttps ? 443 : 3000),
  path: url.pathname,
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(requestData)
  }
};

console.log(`🚀 Making request to: ${url.href}\n`);

const req = lib.request(requestOptions, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log(`Status Code: ${res.statusCode}\n`);
    
    try {
      const response = JSON.parse(data);
      
      if (res.statusCode === 200 || res.statusCode === 201) {
        console.log('✅ Success! OAuth URL generated:\n');
        console.log(response.url);
        console.log('\n📋 Copy this URL and open it in your browser to authorize the integration.');
      } else {
        console.error('❌ Error:', response.error || response.message || 'Unknown error');
        console.error('Full response:', JSON.stringify(response, null, 2));
      }
    } catch (e) {
      console.error('❌ Failed to parse response:', data);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Request failed:', error.message);
  console.error('\nMake sure your backend is running at:', BACKEND_URL);
});

req.write(requestData);
req.end();
