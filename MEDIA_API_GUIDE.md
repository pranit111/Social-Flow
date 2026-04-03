# Media Management API - Complete Guide

Complete documentation for managing media files using the Postiz Public API.

## Authentication

All endpoints require an API key in the `Authorization` header:

```
Authorization: YOUR_API_KEY
```

**Base URL:** `https://socialflow.confideleap.com/api/public/v1`

For local development: `http://localhost:4007/api/public/v1`

---

## Table of Contents

1. [Upload Media](#upload-media)
2. [Get Media Library](#get-media-library)
3. [Delete Media](#delete-media)
4. [Update Media Information](#update-media-information)
5. [AI Image Generation](#ai-image-generation)
6. [AI Video Generation](#ai-video-generation)

---

## Upload Media

### 1. Upload from File (Simple)

**Endpoint:** `POST /public/v1/media/upload-simple`

Upload a file directly from your device.

**Request Type:** `multipart/form-data`

**Body Parameters:**
- `file` (required): The file to upload
- `preventSave` (optional): `"true"` or `"false"` (default: `"false"`)

**Example (Postman):**
1. Select `POST` method
2. URL: `https://socialflow.confideleap.com/api/public/v1/media/upload-simple`
3. Headers:
   - `Authorization: YOUR_API_KEY`
4. Body → form-data:
   - Key: `file` (Type: File)
   - Value: Select your image file
   - Key: `preventSave` (Type: Text)
   - Value: `false`

**Example (cURL):**
```bash
curl -X POST https://socialflow.confideleap.com/api/public/v1/media/upload-simple \
  -H "Authorization: YOUR_API_KEY" \
  -F "file=@/path/to/image.jpg" \
  -F "preventSave=false"
```

**Example (JavaScript):**
```javascript
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('preventSave', 'false');

const response = await fetch('https://socialflow.confideleap.com/api/public/v1/media/upload-simple', {
  method: 'POST',
  headers: {
    'Authorization': 'YOUR_API_KEY'
  },
  body: formData
});

const media = await response.json();
console.log(media);
```

**Response (Success):**
```json
{
  "id": "cm9abc123def456",
  "path": "https://socialflow.confideleap.com/uploads/image-123456.jpg",
  "name": "image-123456.jpg",
  "createdAt": "2026-03-06T10:30:00.000Z",
  "organizationId": "org-uuid"
}
```

**Response with preventSave=true:**
```json
{
  "path": "https://socialflow.confideleap.com/uploads/image-123456.jpg"
}
```

---

### 2. Upload from URL

**Endpoint:** `POST /public/v1/upload-from-url`

Upload media from an external URL.

**Request Type:** `application/json`

**Body:**
```json
{
  "url": "https://example.com/image.jpg"
}
```

**Example (cURL):**
```bash
curl -X POST https://socialflow.confideleap.com/api/public/v1/upload-from-url \
  -H "Authorization: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/image.jpg"}'
```

**Response:**
```json
{
  "id": "cm9abc123def456",
  "path": "https://socialflow.confideleap.com/uploads/image.jpg",
  "name": "image.jpg"
}
```

---

### 3. Upload from Server

**Endpoint:** `POST /public/v1/media/upload-server`

Full multipart upload with validation.

**Request Type:** `multipart/form-data`

**Body:**
- `file` (required): File to upload

**Example:**
```bash
curl -X POST https://socialflow.confideleap.com/api/public/v1/media/upload-server \
  -H "Authorization: YOUR_API_KEY" \
  -F "file=@/path/to/video.mp4"
```

**Response:**
```json
{
  "id": "cm9xyz789ghi012",
  "path": "https://socialflow.confideleap.com/uploads/video-789012.mp4",
  "name": "video-789012.mp4",
  "originalName": "my-video.mp4"
}
```

---

## Get Media Library

### 4. List All Media

**Endpoint:** `GET /public/v1/media?page=0`

Retrieve all uploaded media with pagination. Returns 18 items per page.

**Query Parameters:**
- `page` (optional): Page number, 0-indexed (default: 0)

**Example (cURL):**
```bash
curl -X GET "https://socialflow.confideleap.com/api/public/v1/media?page=0" \
  -H "Authorization: YOUR_API_KEY"
```

**Example (JavaScript):**
```javascript
const response = await fetch('https://socialflow.confideleap.com/api/public/v1/media?page=0', {
  headers: {
    'Authorization': 'YOUR_API_KEY'
  }
});

const data = await response.json();
console.log(`Total pages: ${data.pages}`);
console.log(`Media items:`, data.results);
```

**Response:**
```json
{
  "pages": 3,
  "results": [
    {
      "id": "cm9abc123def456",
      "path": "https://socialflow.confideleap.com/uploads/image.jpg",
      "name": "image-123456.jpg",
      "originalName": "my-photo.jpg",
      "thumbnail": "https://socialflow.confideleap.com/uploads/thumb-image.jpg",
      "alt": "Beautiful sunset photo",
      "thumbnailTimestamp": 5.2,
      "createdAt": "2026-03-06T10:30:00.000Z"
    },
    {
      "id": "cm9xyz789ghi012",
      "path": "https://socialflow.confideleap.com/uploads/video.mp4",
      "name": "video-789012.mp4",
      "originalName": "vacation-video.mp4",
      "thumbnail": "https://socialflow.confideleap.com/uploads/thumb-video.jpg",
      "alt": null,
      "thumbnailTimestamp": 3.5,
      "createdAt": "2026-03-05T14:20:00.000Z"
    }
  ]
}
```

**Response Fields:**
- `pages`: Total number of pages available
- `results`: Array of media items (max 18 per page)
- `id`: Media UUID (use this when attaching to posts)
- `path`: Full URL to the media file
- `name`: System-generated filename
- `originalName`: Original uploaded filename
- `thumbnail`: Thumbnail URL (for videos)
- `alt`: Alt text for accessibility
- `thumbnailTimestamp`: Video thumbnail timestamp in seconds
- `createdAt`: Upload timestamp

**Pagination Example:**
```javascript
// Get all media across multiple pages
async function getAllMedia() {
  const allMedia = [];
  let page = 0;
  let totalPages = 1;

  while (page < totalPages) {
    const response = await fetch(
      `https://socialflow.confideleap.com/api/public/v1/media?page=${page}`,
      { headers: { 'Authorization': 'YOUR_API_KEY' } }
    );
    
    const data = await response.json();
    allMedia.push(...data.results);
    totalPages = data.pages;
    page++;
  }

  return allMedia;
}
```

---

## Delete Media

### 5. Delete Media by ID

**Endpoint:** `DELETE /public/v1/media/:id`

Remove a media file from your library.

**URL Parameters:**
- `id` (required): Media UUID

**Example (cURL):**
```bash
curl -X DELETE "https://socialflow.confideleap.com/api/public/v1/media/cm9abc123def456" \
  -H "Authorization: YOUR_API_KEY"
```

**Example (JavaScript):**
```javascript
const mediaId = 'cm9abc123def456';

const response = await fetch(
  `https://socialflow.confideleap.com/api/public/v1/media/${mediaId}`,
  {
    method: 'DELETE',
    headers: {
      'Authorization': 'YOUR_API_KEY'
    }
  }
);

if (response.ok) {
  console.log('Media deleted successfully');
}
```

**Response (Success):**
```json
{
  "success": true
}
```

---

## Update Media Information

### 6. Save Media Metadata

**Endpoint:** `POST /public/v1/media/information`

Update media metadata like alt text, captions, and other information.

**Request Type:** `application/json`

**Body:**
```json
{
  "mediaId": "cm9abc123def456",
  "alt": "A beautiful sunset over the mountains",
  "caption": "Taken at Mount Rainier National Park"
}
```

**Example (cURL):**
```bash
curl -X POST https://socialflow.confideleap.com/api/public/v1/media/information \
  -H "Authorization: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "mediaId": "cm9abc123def456",
    "alt": "Sunset over mountains",
    "caption": "Mount Rainier"
  }'
```

**Example (JavaScript):**
```javascript
const response = await fetch(
  'https://socialflow.confideleap.com/api/public/v1/media/information',
  {
    method: 'POST',
    headers: {
      'Authorization': 'YOUR_API_KEY',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      mediaId: 'cm9abc123def456',
      alt: 'Sunset over mountains',
      caption: 'Mount Rainier National Park'
    })
  }
);

const result = await response.json();
```

**Response:**
```json
{
  "id": "cm9abc123def456",
  "alt": "Sunset over mountains",
  "caption": "Mount Rainier National Park",
  "updatedAt": "2026-03-06T11:15:00.000Z"
}
```

---

## AI Image Generation

### 7. Generate AI Image

**Endpoint:** `POST /public/v1/media/generate-image`

Generate an image from a text prompt using AI.

**Request Type:** `application/json`

**Body:**
```json
{
  "prompt": "A beautiful sunset over mountains",
  "isPicturePrompt": false
}
```

**Parameters:**
- `prompt` (required): Text description of the image
- `isPicturePrompt` (optional): Boolean (default: false)

**Example (cURL):**
```bash
curl -X POST https://socialflow.confideleap.com/api/public/v1/media/generate-image \
  -H "Authorization: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "A futuristic city skyline at night",
    "isPicturePrompt": false
  }'
```

**Example (JavaScript):**
```javascript
const response = await fetch(
  'https://socialflow.confideleap.com/api/public/v1/media/generate-image',
  {
    method: 'POST',
    headers: {
      'Authorization': 'YOUR_API_KEY',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      prompt: 'A serene beach at sunset with palm trees',
      isPicturePrompt: false
    })
  }
);

const result = await response.json();
```

**Response:**
```json
{
  "output": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
}
```

---

### 8. Generate and Save AI Image

**Endpoint:** `POST /public/v1/media/generate-image-with-prompt`

Generate an image and automatically save it to your media library.

**Request Type:** `application/json`

**Body:**
```json
{
  "prompt": "A futuristic city skyline"
}
```

**Example (cURL):**
```bash
curl -X POST https://socialflow.confideleap.com/api/public/v1/media/generate-image-with-prompt \
  -H "Authorization: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "A cyberpunk cityscape at night"}'
```

**Example (JavaScript):**
```javascript
const response = await fetch(
  'https://socialflow.confideleap.com/api/public/v1/media/generate-image-with-prompt',
  {
    method: 'POST',
    headers: {
      'Authorization': 'YOUR_API_KEY',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      prompt: 'An astronaut riding a horse on Mars'
    })
  }
);

const media = await response.json();
console.log('Generated image saved:', media.path);
```

**Response:**
```json
{
  "id": "cm9gen456abc789",
  "path": "https://socialflow.confideleap.com/uploads/generated-image-456789.jpg",
  "name": "generated-image-456789.jpg",
  "createdAt": "2026-03-06T12:00:00.000Z"
}
```

---

## AI Video Generation

### 9. Generate AI Video

**Endpoint:** `POST /public/v1/media/generate-video`

Generate a video using AI providers.

**Request Type:** `application/json`

**Body:**
```json
{
  "provider": "luma",
  "prompt": "A serene beach scene with waves",
  "settings": {}
}
```

**Example (cURL):**
```bash
curl -X POST https://socialflow.confideleap.com/api/public/v1/media/generate-video \
  -H "Authorization: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "provider": "luma",
    "prompt": "Ocean waves crashing on a rocky shore",
    "settings": {}
  }'
```

**Response:**
```json
{
  "id": "cm9video789xyz",
  "status": "processing",
  "provider": "luma",
  "estimatedTime": 120
}
```

---

### 10. Get Video Generation Options

**Endpoint:** `GET /public/v1/media/video-options`

List available video generation providers and their capabilities.

**Example (cURL):**
```bash
curl -X GET https://socialflow.confideleap.com/api/public/v1/media/video-options \
  -H "Authorization: YOUR_API_KEY"
```

**Response:**
```json
{
  "providers": [
    {
      "name": "luma",
      "display": "Luma AI",
      "maxDuration": 5,
      "features": ["text-to-video", "image-to-video"]
    }
  ]
}
```

---

### 11. Check Video Generation Availability

**Endpoint:** `GET /public/v1/media/generate-video/:type/allowed`

Check if a specific video generation type is allowed for your plan.

**URL Parameters:**
- `type`: Provider name (e.g., "luma")

**Example (cURL):**
```bash
curl -X GET https://socialflow.confideleap.com/api/public/v1/media/generate-video/luma/allowed \
  -H "Authorization: YOUR_API_KEY"
```

**Response:**
```json
{
  "allowed": true,
  "remaining": 10,
  "limit": 20
}
```

---

## Error Handling

All endpoints return standard HTTP status codes:

**Success Codes:**
- `200` - Success
- `201` - Created

**Error Codes:**
- `400` - Bad request (validation error)
- `401` - Unauthorized (invalid or missing API key)
- `403` - Forbidden (insufficient permissions or credits)
- `404` - Not found
- `500` - Server error

**Error Response Format:**
```json
{
  "msg": "Error message description",
  "statusCode": 400
}
```

**Common Errors:**

```json
// Missing API Key
{
  "msg": "No API Key found",
  "statusCode": 401
}
```

```json
// Invalid API Key
{
  "msg": "Invalid API key",
  "statusCode": 401
}
```

```json
// No file provided
{
  "msg": "No file provided",
  "statusCode": 400
}
```

```json
// Insufficient credits
{
  "msg": "Insufficient credits",
  "statusCode": 403
}
```

---

## Complete Workflow Examples

### Upload and Use in Post

```javascript
// 1. Upload image
const formData = new FormData();
formData.append('file', imageFile);

const media = await fetch(
  'https://socialflow.confideleap.com/api/public/v1/media/upload-simple',
  {
    method: 'POST',
    headers: { 'Authorization': 'YOUR_API_KEY' },
    body: formData
  }
).then(r => r.json());

console.log('Uploaded:', media.id, media.path);

// 2. Add alt text
await fetch(
  'https://socialflow.confideleap.com/api/public/v1/media/information',
  {
    method: 'POST',
    headers: {
      'Authorization': 'YOUR_API_KEY',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      mediaId: media.id,
      alt: 'Product photo',
      caption: 'New release 2026'
    })
  }
);

// 3. Use in post (see POST API documentation)
// media.id and media.path can now be used in post creation
```

### Generate AI Image and Post

```javascript
// Generate and save AI image
const aiImage = await fetch(
  'https://socialflow.confideleap.com/api/public/v1/media/generate-image-with-prompt',
  {
    method: 'POST',
    headers: {
      'Authorization': 'YOUR_API_KEY',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      prompt: 'Modern minimalist office workspace'
    })
  }
).then(r => r.json());

console.log('AI Image generated:', aiImage.path);
// Now use aiImage.id in your post
```

### Batch Upload Multiple Files

```javascript
async function uploadMultipleFiles(files) {
  const uploadPromises = files.map(async (file) => {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await fetch(
      'https://socialflow.confideleap.com/api/public/v1/media/upload-simple',
      {
        method: 'POST',
        headers: { 'Authorization': 'YOUR_API_KEY' },
        body: formData
      }
    );
    
    return response.json();
  });
  
  const uploadedMedia = await Promise.all(uploadPromises);
  return uploadedMedia;
}

// Usage
const files = [file1, file2, file3];
const media = await uploadMultipleFiles(files);
console.log('Uploaded files:', media);
```

---

## Rate Limiting

- API requests are tracked per organization
- Default limit: 30 requests per hour (configurable)
- Rate limit headers are included in responses
- Exceeded limits return 429 status code

---

## Supported File Types

### Images
- JPEG (.jpg, .jpeg)
- PNG (.png)
- GIF (.gif)
- WebP (.webp)
- SVG (.svg)

### Videos
- MP4 (.mp4)
- MOV (.mov)
- AVI (.avi)
- WebM (.webm)

### File Size Limits
- Images: Up to 50MB
- Videos: Up to 500MB (varies by plan)

---

## Best Practices

1. **Always use preventSave=false** unless you only need temporary URLs
2. **Add alt text** to all images for accessibility
3. **Use pagination** when fetching media library
4. **Store media IDs** from upload responses for later use
5. **Handle errors gracefully** with proper error checking
6. **Implement retry logic** for network failures
7. **Compress large files** before uploading to save bandwidth

---

## Getting Your API Key

1. Login to your Postiz dashboard
2. Navigate to **Settings** → **API Keys**
3. Click **Generate New Key**
4. Copy and securely store your API key
5. Never share or commit your API key to version control

---

## Support

For issues or questions:
- Documentation: https://docs.postiz.com/
- GitHub Issues: https://github.com/gitroomhq/postiz-app
- Community: Join our Discord server

---

**Last Updated:** March 6, 2026
