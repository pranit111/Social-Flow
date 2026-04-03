# Public API - Complete Guide to Creating Posts via API Key

## Authentication

All public API endpoints require an API key in the `Authorization` header:

```
Authorization: YOUR_API_KEY
```

**Base URL:** `/public/v1`

---

## Complete Workflow to Create a Post

### 1. Get Available Integrations

**Endpoint:** `GET /public/v1/integrations`

Lists all connected social media channels for your organization.

**Response:**
```json
[
  {
    "id": "integration-uuid",
    "name": "My Twitter Account",
    "identifier": "twitter",
    "picture": "https://...",
    "disabled": false,
    "profile": { ... },
    "customer": null
  }
]
```

### 2. Get Integration Settings (Optional)

**Endpoint:** `GET /public/v1/integration-settings/:id`

Get posting rules, character limits, and available tools for a specific integration.

**Response:**
```json
{
  "output": {
    "rules": "Twitter posting rules...",
    "maxLength": 280,
    "settings": { ... },
    "tools": []
  }
}
```

---

## Media Management

### 3a. Upload Media from File

**Endpoint:** `POST /public/v1/media/upload-simple`

Upload a file directly.

**Body (multipart/form-data):**
- `file`: File to upload
- `preventSave`: "true" or "false" (default: false)

**Response:**
```json
{
  "id": "media-uuid",
  "path": "https://cdn.example.com/file.jpg",
  "name": "file.jpg"
}
```

### 3b. Upload Media from URL

**Endpoint:** `POST /public/v1/upload-from-url`

Upload media from an external URL.

**Body:**
```json
{
  "url": "https://example.com/image.jpg"
}
```

**Response:**
```json
{
  "id": "media-uuid",
  "path": "https://cdn.example.com/image.jpg",
  "name": "image.jpg"
}
```

### 3c. Alternative Upload Methods

**Server Upload:** `POST /public/v1/media/upload-server`
- Full multipart upload with validation

**R2 Upload:** `POST /public/v1/media/:endpoint`
- For multipart uploads to Cloudflare R2

### 3d. Get Media Library

**Endpoint:** `GET /public/v1/media?page=0`

List all uploaded media with pagination. Returns 18 items per page.

**Query Parameters:**
- `page`: Page number (0-indexed, defaults to 0)

**Response:**
```json
{
  "pages": 5,
  "results": [
    {
      "id": "media-uuid",
      "path": "https://cdn.example.com/image.jpg",
      "name": "image.jpg",
      "originalName": "original-filename.jpg",
      "thumbnail": "https://cdn.example.com/thumbnail.jpg",
      "alt": "Alt text description",
      "thumbnailTimestamp": 5.2
    }
  ]
}
```

**Response Fields:**
- `pages`: Total number of pages available
- `results`: Array of media items (max 18 per page)
- `id`: Media UUID (use this when attaching to posts)
- `path`: Full URL to the media file
- `name`: Stored filename
- `originalName`: Original uploaded filename
- `thumbnail`: URL to thumbnail (for videos)
- `alt`: Alt text for accessibility
- `thumbnailTimestamp`: Timestamp for video thumbnail

### 3e. Delete Media

**Endpoint:** `DELETE /public/v1/media/:id`

Remove media from library.

### 3f. Save Media Information

**Endpoint:** `POST /public/v1/media/information`

Update media metadata like alt text, captions, etc.

**Body:**
```json
{
  "mediaId": "media-uuid",
  "alt": "Alt text",
  "caption": "Caption text"
}
```

---

## AI-Powered Media Generation

### 4a. Generate AI Image

**Endpoint:** `POST /public/v1/media/generate-image`

Generate an image from a text prompt.

**Body:**
```json
{
  "prompt": "A beautiful sunset over mountains",
  "isPicturePrompt": false
}
```

**Response:**
```json
{
  "output": "data:image/png;base64,iVBORw0KG..."
}
```

### 4b. Generate and Save AI Image

**Endpoint:** `POST /public/v1/media/generate-image-with-prompt`

Generate an image and automatically save it to media library.

**Body:**
```json
{
  "prompt": "A futuristic city skyline"
}
```

**Response:**
```json
{
  "id": "media-uuid",
  "path": "https://cdn.example.com/generated-image.jpg",
  "name": "generated-image.jpg"
}
```

### 4c. Generate AI Video

**Endpoint:** `POST /public/v1/media/generate-video`

Generate a video using AI.

**Body:**
```json
{
  "provider": "luma",
  "prompt": "A serene beach scene",
  "settings": { ... }
}
```

### 4d. Get Video Generation Options

**Endpoint:** `GET /public/v1/media/video-options`

List available video generation providers and their capabilities.

### 4e. Check Video Generation Availability

**Endpoint:** `GET /public/v1/media/generate-video/:type/allowed`

Check if a specific video generation type is allowed for your plan.

---

## Creating Posts

### 5. Create a Post

**Endpoint:** `POST /public/v1/posts`

**Body:**
```json
{
  "type": "schedule",
  "date": "2024-12-31T12:00:00Z",
  "shortLink": false,
  "tags": [
    {
      "value": "tag-uuid",
      "label": "Marketing"
    }
  ],
  "posts": [
    {
      "integration": {
        "id": "integration-uuid"
      },
      "value": [
        {
          "content": "Check out this amazing post! 🚀",
          "delay": 0,
          "image": [
            {
              "id": "media-uuid",
              "path": "https://cdn.example.com/image.jpg"
            }
          ]
        }
      ],
      "settings": {
        "__type": "TwitterSettingsDto"
      }
    }
  ]
}
```

**Post Types:**
- `draft` - Save as draft
- `schedule` - Schedule for specific date/time
- `now` - Post immediately
- `update` - Update existing post

**Response:**
```json
{
  "id": "post-uuid",
  "group": "group-uuid",
  "status": "scheduled",
  "date": "2024-12-31T12:00:00Z"
}
```

### 5a. Find Available Time Slot

**Endpoint:** `GET /public/v1/find-slot/:integrationId`

Find the next available posting slot for an integration.

**Response:**
```json
{
  "date": "2024-12-31T12:00:00Z"
}
```

---

## Managing Posts

### 6. Get Posts

**Endpoint:** `GET /public/v1/posts?page=0&status=scheduled`

List all posts with filtering options.

**Query Parameters:**
- `page`: Page number (default: 0)
- `status`: Filter by status (draft, scheduled, published, failed)
- `startDate`: Filter from date
- `endDate`: Filter to date

**Response:**
```json
{
  "posts": [
    {
      "id": "post-uuid",
      "group": "group-uuid",
      "status": "scheduled",
      "date": "2024-12-31T12:00:00Z",
      "posts": [ ... ]
    }
  ]
}
```

### 7. Delete Post by ID

**Endpoint:** `DELETE /public/v1/posts/:id`

Delete a single post. This deletes the entire post group.

### 8. Delete Post by Group

**Endpoint:** `DELETE /public/v1/posts/group/:groupId`

Delete all posts in a group (useful for multi-channel posts).

### 9. Get Missing Content

**Endpoint:** `GET /public/v1/posts/:id/missing`

Check if a post is missing required content for specific integrations.

**Response:**
```json
{
  "missing": [
    {
      "integrationId": "integration-uuid",
      "issues": ["Content exceeds max length", "Missing required image"]
    }
  ]
}
```

### 10. Update Release ID

**Endpoint:** `PUT /public/v1/posts/:id/release-id`

Update the release ID for a post (used for external tracking).

**Body:**
```json
{
  "releaseId": "external-release-123"
}
```

---

## Analytics

### 11. Get Post Analytics

**Endpoint:** `GET /public/v1/analytics/post/:postId?date=1704067200000`

Get analytics for a specific post.

**Response:**
```json
{
  "views": 1000,
  "likes": 50,
  "comments": 10,
  "shares": 5,
  "engagement": 6.5
}
```

### 12. Get Integration Analytics

**Endpoint:** `GET /public/v1/analytics/:integrationId?date=1704067200000`

Get overall analytics for an integration.

---

## Notifications

### 13. Get Notifications

**Endpoint:** `GET /public/v1/notifications?page=0`

Get system notifications about post status, errors, etc.

**Response:**
```json
{
  "notifications": [
    {
      "id": "notification-uuid",
      "type": "post_failed",
      "message": "Post failed to publish",
      "read": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

---

## Integration Tools

### 14. Trigger Integration Tool

**Endpoint:** `POST /public/v1/integration-trigger/:integrationId`

Execute integration-specific tools (e.g., fetch Twitter threads, get Instagram insights).

**Body:**
```json
{
  "methodName": "getInsights",
  "data": {
    "metric": "impressions",
    "period": "day"
  }
}
```

---

## Example: Complete Post Creation Workflow

```javascript
// 1. Get integrations
const integrations = await fetch('/public/v1/integrations', {
  headers: { 'Authorization': 'YOUR_API_KEY' }
}).then(r => r.json());

const twitterIntegration = integrations.find(i => i.identifier === 'twitter');

// 2. Upload media
const formData = new FormData();
formData.append('file', imageFile);

const media = await fetch('/public/v1/media/upload-simple', {
  method: 'POST',
  headers: { 'Authorization': 'YOUR_API_KEY' },
  body: formData
}).then(r => r.json());

// 3. Create scheduled post
const post = await fetch('/public/v1/posts', {
  method: 'POST',
  headers: {
    'Authorization': 'YOUR_API_KEY',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    type: 'schedule',
    date: '2024-12-31T12:00:00Z',
    shortLink: false,
    tags: [],
    posts: [{
      integration: { id: twitterIntegration.id },
      value: [{
        content: 'Happy New Year! 🎉',
        delay: 0,
        image: [{
          id: media.id,
          path: media.path
        }]
      }],
      settings: { __type: 'TwitterSettingsDto' }
    }]
  })
}).then(r => r.json());

console.log('Post created:', post);
```

---

## Error Handling

All endpoints return standard HTTP status codes:

- `200` - Success
- `400` - Bad request (validation error)
- `401` - Unauthorized (invalid or missing API key)
- `403` - Forbidden (insufficient permissions or credits)
- `404` - Not found
- `500` - Server error

Error response format:
```json
{
  "msg": "Error message description",
  "statusCode": 400
}
```

---

## Rate Limiting

API requests are tracked and may be rate-limited based on your subscription plan. The `Sentry.metrics.count('public_api-request', 1)` is logged for each request.

---

## Notes

- All dates must be in ISO 8601 format
- Media files are automatically stored in your organization's storage
- Posts can be scheduled up to 1 year in advance
- Multi-channel posts share the same `group` ID
- Each integration may have specific content requirements (check with `/integration-settings/:id`)
