# Enterprise Account OAuth Mapping

## Overview

This document describes the enterprise endpoint for generating OAuth URLs to connect social media channels using the Postiz API key.

## Endpoint

**URL:** `POST /enterprise/integrations/:provider`

**Description:** Generates OAuth authorization URLs for connecting social media channels to an enterprise account authenticated via API key.

## Parameters

### Path Parameters
- `provider` (string, required) - The social media provider identifier (e.g., `instagram`, `facebook`, `linkedin`, `twitter`, etc.)

### Body Parameters
- `params` (string, required) - JWT-encoded payload containing authentication and configuration data

## JWT Payload Structure

The `params` field must be a JWT token containing the following properties:

```typescript
{
  apiKey: string;        // Required: Postiz API key
  refreshId?: string;    // Optional: ID for refresh token
  externalUrl?: string;  // Optional: For self-hosted platforms (e.g., Mastodon)
  webhookUrl?: string;   // Optional: Webhook URL for notifications
  redirectUrl?: string;  // Optional: Custom redirect after OAuth
  onboarding?: boolean;  // Optional: Onboarding flow flag
}
```

## Response

### Success Response
```json
{
  "url": "https://oauth-provider.com/authorize?client_id=...&state=...&redirect_uri=..."
}
```

### Error Responses

**Invalid Parameters:**
```json
{
  "error": "Invalid parameters"
}
```

**Organization Not Found:**
```json
{
  "error": "Organization not found"
}
```

**Integration Not Allowed:**
```json
{
  "error": "Integration not allowed"
}
```

**Missing External URL (for self-hosted platforms):**
```json
{
  "error": "Missing external url"
}
```

**OAuth Generation Failed:**
```json
{
  "error": "Failed to generate authorization URL"
}
```

**Invalid JWT:**
```json
{
  "error": "Invalid JWT token"
}
```

## Postman Request Example

### Basic Instagram Connection

**Endpoint:**
```
POST http://localhost:3000/enterprise/integrations/instagram
```

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "params": "YOUR_ENCODED_JWT_TOKEN"
}
```

### Generating the JWT Token

#### Using Node.js

```javascript
const jwt = require('jsonwebtoken');

const token = jwt.sign(
  {
    apiKey: "6064530c18ad983394e80e98a7dae1683fc5f6b4332309b7345cfa8e3bb36bd6",
    onboarding: true
  },
  process.env.JWT_SECRET  // Your JWT secret from .env
);

console.log(token);
```

#### Using an Online JWT Tool

1. Go to https://jwt.io
2. Set algorithm to `HS256`
3. In the payload section, add:
```json
{
  "apiKey": "6064530c18ad983394e80e98a7dae1683fc5f6b4332309b7345cfa8e3bb36bd6",
  "onboarding": true
}
```
4. In the signature section, add your `JWT_SECRET`
5. Copy the encoded token from the left panel

### Complete Postman Example with All Options

```json
{
  "params": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlLZXkiOiI2MDY0NTMwYzE4YWQ5ODMzOTRlODBlOThhN2RhZTE2ODNmYzVmNmI0MzMyMzA5YjczNDVjZmE4ZTNiYjM2YmQ2IiwicmVmcmVzaElkIjoicmVmcmVzaF8xMjMiLCJ3ZWJob29rVXJsIjoiaHR0cHM6Ly95b3VyLWFwcC5jb20vd2ViaG9vayIsInJlZGlyZWN0VXJsIjoiaHR0cHM6Ly95b3VyLWFwcC5jb20vY2FsbGJhY2siLCJvbmJvYXJkaW5nIjp0cnVlfQ.SIGNATURE"
}
```

**Payload (before encoding):**
```json
{
  "apiKey": "6064530c18ad983394e80e98a7dae1683fc5f6b4332309b7345cfa8e3bb36bd6",
  "refreshId": "refresh_123",
  "webhookUrl": "https://your-app.com/webhook",
  "redirectUrl": "https://your-app.com/callback",
  "onboarding": true
}
```

## Supported Providers

The endpoint supports all providers returned by `_integrationManager.getAllowedSocialsIntegrations()`, including:

- `instagram`
- `facebook`
- `linkedin`
- `twitter`
- `youtube`
- `tiktok`
- `pinterest`
- `reddit`
- `telegram`
- `discord`
- `slack`
- `mastodon` (requires `externalUrl`)
- And more...

## Example Workflow

1. **Generate JWT Token** with your API key
2. **Make POST Request** to `/enterprise/integrations/:provider` with the JWT token
3. **Receive OAuth URL** in the response
4. **Redirect User** to the OAuth URL to authorize the connection
5. **Handle OAuth Callback** - User will be redirected back after authorization
6. **Channel Connected** - The integration will be saved to the organization

## Redis State Storage

The endpoint stores temporary OAuth state in Redis with 1-hour expiration:

- `refresh:${state}` - Refresh token ID (if provided)
- `onboarding:${state}` - Onboarding flag
- `webhookUrl:${state}` - Webhook URL (if provided)
- `redirectUrl:${state}` - Custom redirect URL (if provided)
- `organization:${state}` - Organization ID
- `login:${state}` - OAuth code verifier (PKCE)
- `external:${state}` - External URL data (for self-hosted platforms)

## Security Notes

- The API key must be valid and associated with an existing organization
- JWT tokens must be signed with the correct secret
- OAuth state parameters expire after 1 hour
- All Redis keys are automatically cleaned up after expiration

## Comparison with Regular Integration Endpoint

| Feature | Regular Endpoint | Enterprise Endpoint |
|---------|-----------------|---------------------|
| Authentication | Session-based (@GetOrgFromRequest) | API Key (JWT) |
| Endpoint | `GET /integrations/social/:integration` | `POST /enterprise/integrations/:provider` |
| Parameters | Query params | JWT-encoded body |
| Authorization | @CheckPolicies decorator | API key validation |
| Webhook Support | No | Yes |
| Custom Redirect | No | Yes |

## Testing

To test the endpoint:

1. Ensure your backend is running
2. Get your organization's API key from the database or admin panel
3. Generate a JWT token with the API key
4. Send a POST request using Postman or cURL
5. Follow the returned OAuth URL to complete the integration

### cURL Example

```bash
curl -X POST http://localhost:3000/enterprise/integrations/instagram \
  -H "Content-Type: application/json" \
  -d '{
    "params": "YOUR_JWT_TOKEN_HERE"
  }'
```

## Error Handling

The endpoint returns error objects instead of throwing exceptions, making it suitable for API integrations that need consistent error responses.
