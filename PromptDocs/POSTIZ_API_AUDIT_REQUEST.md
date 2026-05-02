# Postiz API Audit Request

**Purpose:** Audit the Postiz codebase to identify all available API endpoints, features, and capabilities to avoid rebuilding existing functionality.

**Project Context:** We are integrating a self-hosted Postiz instance into our CRM system. We need to know exactly what Postiz already provides so we can leverage it instead of building custom solutions.

---

## 🎯 PRIMARY QUESTIONS TO ANSWER

### 1. What is the complete API endpoint structure?
### 2. What features does Postiz natively support?
### 3. What data formats/schemas are used?
### 4. What are the limitations and constraints?

---

## 📋 SPECIFIC ENDPOINTS TO CHECK

Please search the Postiz codebase for these endpoints and provide:
- ✅ Endpoint exists (provide exact path)
- 📝 Request body schema
- 📝 Response format
- ❌ Endpoint does not exist

---

## 1️⃣ **POST CREATION & MANAGEMENT**

### Check for these endpoints:

```
POST /posts
└─ Request body format?
└─ What fields are supported?
└─ Required vs optional fields?

GET /posts
└─ Query parameters available?
└─ Filtering options (status, date range, integration)?
└─ Pagination format?
└─ Response structure?

GET /posts/:id
└─ Response format?
└─ What data is included?

PUT /posts/:id
└─ What fields can be updated?
└─ Can you update after scheduling?

DELETE /posts/:id
└─ Soft delete or hard delete?
└─ What happens to scheduled posts?

PATCH /posts/:id
└─ Partial updates supported?
```

### Special Questions:
1. **Can you create a post with status "draft"?** Or is there a separate draft system?
2. **What post statuses exist?** (draft, scheduled, published, failed, etc.)
3. **Can you post immediately** (publishDate = now) or must posts be scheduled?

---

## 2️⃣ **DRAFT SYSTEM**

### Check if drafts are separate from posts:

```
POST /drafts
└─ Exists as separate endpoint?
└─ Or use POST /posts with status: "draft"?

GET /drafts
└─ List all drafts?
└─ Pagination?

GET /drafts/:id
└─ Get single draft?

PUT /drafts/:id
└─ Update draft?

DELETE /drafts/:id
└─ Delete draft?

POST /drafts/:id/publish
└─ Convert draft to scheduled/published post?
└─ Request body format?
```

### Questions:
1. Are drafts stored separately from scheduled posts?
2. Can drafts be converted to scheduled posts?
3. Can scheduled posts be converted back to drafts?

---

## 3️⃣ **THREAD/CAROUSEL SUPPORT**

### Check for multi-post/thread capabilities:

```
POST /posts/thread or POST /posts/bulk
└─ Can you create multiple posts at once?
└─ How to specify post order?
└─ Can you set delays between posts?

GET /posts/:id/thread
└─ Get all posts in a thread?

PUT /posts/thread/:id
└─ Update entire thread?

POST /posts (with thread support)
└─ Can single endpoint handle threads?
└─ What does the schema look like?
```

### Questions:
1. Does Postiz support threads/carousels?
2. How are posts linked together?
3. Can you set delays between thread posts?
4. What happens if one post in a thread fails?

---

## 4️⃣ **RECURRING/SCHEDULED POSTS**

### Check for recurring post functionality:

```
POST /recurring or POST /schedules/recurring
└─ Create recurring schedule?
└─ What recurrence patterns supported? (daily, weekly, monthly?)

GET /recurring
└─ List all recurring schedules?

GET /recurring/:id
└─ Get single recurring schedule?

PUT /recurring/:id
└─ Update recurring schedule?

DELETE /recurring/:id
└─ Stop/delete recurring schedule?

GET /recurring/:id/instances
└─ Get upcoming posts from recurrence?

PATCH /recurring/:id/pause
└─ Pause/resume recurring schedule?
```

### Questions:
1. Does Postiz handle recurring posts automatically?
2. What recurrence patterns are supported?
3. Can you set end dates or max post counts?
4. Are recurring posts created in advance or on-the-fly?

---

## 5️⃣ **MEDIA MANAGEMENT**

### We know these exist, but check for advanced features:

```
POST /media/upload ✅ (we know this exists)
└─ Max file size?
└─ Supported formats?
└─ Additional parameters?

GET /media ✅ (we know this exists)
└─ Pagination format?
└─ Default page size?

GET /media (with advanced search)
└─ ?search=query
└─ ?type=image|video|gif
└─ ?page=1&limit=50
└─ ?tags=tag1,tag2
└─ ?uploadedAfter=date
└─ ?uploadedBefore=date
└─ ?sortBy=date|size|name
└─ ?sortOrder=asc|desc

PUT /media/:id ✅ (we know this exists)
└─ What fields can be updated?
└─ Alt text support?
└─ Caption support?
└─ Tags support?

DELETE /media/:id ✅ (we know this exists)

POST /media/bulk-delete
└─ Delete multiple media at once?

GET /media/folders
└─ Folder/organization support?

POST /media/folders
└─ Create folders?

PUT /media/:id/move
└─ Move media to folders?

GET /media/stats or GET /media/usage
└─ Storage statistics?
└─ Total used space?
└─ File count by type?
```

### Questions:
1. What advanced media search/filter options exist?
2. Does Postiz support media folders/organization?
3. Is there storage quota tracking?
4. Can media have tags/categories?

---

## 6️⃣ **CALENDAR & VIEWS**

### Check for calendar-specific endpoints:

```
GET /posts?view=day&date=2026-03-11
└─ Posts grouped by hour?

GET /posts?view=week&from=...&to=...
└─ Week view support?

GET /posts?view=month&from=...&to=...
└─ Month view support?

GET /posts?view=list
└─ Simple list view?

GET /calendar or GET /posts/calendar
└─ Special calendar endpoint?

GET /posts/export
└─ ?format=ical
└─ ?format=csv
└─ ?format=json
└─ Export posts to calendar formats?

GET /posts/stats or GET /calendar/stats
└─ Calendar statistics?
└─ Posts per day/week/month?
└─ Busiest times?
```

### Questions:
1. Does Postiz provide calendar-specific views?
2. Can posts be exported to iCal/CSV?
3. Are there aggregation/statistics endpoints?

---

## 7️⃣ **INTEGRATIONS/CHANNELS**

### We know these exist, but check for additional features:

```
GET /integrations ✅ (we know this exists)
└─ What data is returned?
└─ Status information?

POST /integrations/:provider ✅ (we know this exists)
└─ OAuth flow details?

DELETE /integrations/:id ✅ (we know this exists)

GET /integrations/:id/capabilities or /integrations/:id/features
└─ Platform-specific features?
└─ Character limits?
└─ Media restrictions?
└─ Premium features detected?

GET /integrations/:id/settings
└─ Available settings per platform?
└─ Setting options/enums?

PATCH /integrations/:id/settings
└─ Update integration settings?
```

### Questions:
1. Can you query platform capabilities (char limits, media limits)?
2. Does Postiz detect premium accounts (e.g., Twitter Blue)?
3. What platform-specific settings are configurable?

---

## 8️⃣ **PLATFORM-SPECIFIC SETTINGS**

### Check what platform-specific options are supported in post creation:

When creating a post with **POST /posts**, can you include:

```javascript
{
  content: "...",
  date: "...",
  integrations: [...],
  media: [...],
  
  // SPECIAL FIELDS - DO THESE EXIST?
  firstComment: "...",           // Auto-comment after posting?
  
  settings: {                     // Post-level settings?
    enableLinkPreview: true,
    shortenUrls: true,
    customOgImage: "...",
  },
  
  // PLATFORM-SPECIFIC SETTINGS
  // Twitter/X
  twitter_settings: {
    who_can_reply: "everyone" | "following" | "mentioned" | "subscribers" | "verified",
    community_url: "...",
  },
  
  // LinkedIn
  linkedin_settings: {
    post_type: "post" | "article" | "poll",
    visibility: "public" | "connections",
    comments_enabled: boolean,
  },
  
  // Instagram
  instagram_settings: {
    collaborators: [...],
    location: { id: "...", name: "..." },
    first_comment: "...",
    aspect_ratio: "1:1" | "4:5" | "16:9",
    shopping_tags: [...],
  },
  
  // Facebook
  facebook_settings: {
    target_audience: {...},
    backdate: {...},
    location: {...},
  },
  
  // YouTube
  youtube_settings: {
    title: "...",
    description: "...",
    category: "...",
    visibility: "public" | "unlisted" | "private",
    age_restriction: boolean,
    thumbnail: "...",
    playlist: "...",
    tags: [...],
  },
}
```

### Questions:
1. What is the exact schema for platform-specific settings?
2. Which platforms support which settings?
3. Is there validation for platform-specific options?

---

## 9️⃣ **ERROR HANDLING & RETRY**

### Check for error management endpoints:

```
GET /posts/:id/errors or GET /posts/:id/status
└─ Get error details for failed posts?
└─ Error format?

POST /posts/:id/retry
└─ Retry failed posts?

GET /posts?status=failed
└─ Filter by failed status?

GET /logs or GET /activity
└─ API call logs?
└─ Error logs?

GET /errors or GET /posts/errors
└─ Global error list?
```

### Questions:
1. How does Postiz report posting failures?
2. Can you retry failed posts?
3. What error information is provided?
4. Are errors logged separately?

---

## 🔟 **ANALYTICS & INSIGHTS**

### Check for analytics endpoints:

```
GET /posts/:id/analytics
└─ Performance metrics for a post?
└─ Likes, comments, shares, reach?

GET /analytics
└─ Overall account analytics?

GET /analytics/:integrationId
└─ Per-platform analytics?

GET /posts/:id/engagement
└─ Engagement data?

GET /insights or GET /reports
└─ Reporting endpoints?
```

### Questions:
1. Does Postiz track post performance?
2. What metrics are available?
3. Is analytics real-time or delayed?
4. Can you get aggregated analytics?

---

## 1️⃣1️⃣ **BULK OPERATIONS**

### Check for bulk/batch endpoints:

```
POST /posts/bulk
└─ Create multiple posts at once?

PUT /posts/bulk
└─ Update multiple posts?

DELETE /posts/bulk
└─ Delete multiple posts?

POST /posts/bulk-schedule
└─ Schedule multiple posts intelligently?

POST /media/bulk-delete
└─ Delete multiple media files?

POST /posts/bulk-action
└─ Generic bulk action endpoint?
```

---

## 1️⃣2️⃣ **SEARCH & FILTERING**

### Check query parameter support on GET /posts:

```
GET /posts?status=scheduled
GET /posts?status=published
GET /posts?status=failed
GET /posts?status=draft

GET /posts?integrationId=...
GET /posts?platform=twitter

GET /posts?from=2026-03-01&to=2026-03-31
GET /posts?date=2026-03-11

GET /posts?search=keyword
GET /posts?content=keyword

GET /posts?page=1&limit=50
GET /posts?page=1&limit=100

GET /posts?sortBy=date
GET /posts?sortBy=platform
GET /posts?sortOrder=asc
GET /posts?sortOrder=desc
```

### Questions:
1. What filtering options are supported?
2. Is full-text search available?
3. What are pagination limits?

---

## 1️⃣3️⃣ **WEBHOOKS & CALLBACKS**

### Check for webhook/notification system:

```
POST /webhooks
└─ Register webhook URLs?

GET /webhooks
└─ List registered webhooks?

DELETE /webhooks/:id
└─ Remove webhooks?

GET /webhooks/events
└─ What events trigger webhooks?
```

### Questions:
1. What events can trigger webhooks?
2. What is the webhook payload format?
3. Are webhooks per-integration or global?

---

## 1️⃣4️⃣ **SPECIAL FEATURES**

### Check for additional features:

```
GET /posts/find-slot or GET /posts/suggest-time
└─ AI/algorithm to suggest best posting time?

GET /posts/:id/preview
└─ Generate platform-specific preview?

POST /posts/:id/duplicate
└─ Duplicate/clone a post?

POST /posts/:id/lock
└─ Lock post to prevent edits?

GET /posts/:id/history or GET /posts/:id/versions
└─ Version history tracking?

POST /posts/:id/revert
└─ Revert to previous version?
```

---

## 1️⃣5️⃣ **LIMITS & CONSTRAINTS**

### Please document:

1. **Rate Limits**
   - Requests per minute/hour?
   - Per-user or global?

2. **File Size Limits**
   - Maximum media file size?
   - Different per media type?

3. **Post Limits**
   - Max posts per day/month?
   - Max scheduled posts?

4. **Content Limits**
   - Max content length (varies by platform)?
   - Max media per post?

5. **Storage Limits**
   - Total media storage allowed?
   - Per-user quotas?

---

## 📤 OUTPUT FORMAT REQUESTED

For each endpoint you find, please provide:

```markdown
### Endpoint: POST /posts

**Status:** ✅ Exists | ❌ Not Found | ⚠️ Partially Implemented

**Request Schema:**
```typescript
{
  content: string;
  date: string; // ISO 8601
  integrations: string[];
  media?: Array<{ id: string; path: string }>;
  // ... other fields
}
```

**Response Format:**
```typescript
{
  id: string;
  status: string;
  // ... other fields
}
```

**Notes:**
- Any special behaviors
- Limitations discovered
- Related endpoints
```

---

## 🎯 SUMMARY CHECKLIST

After auditing, please provide a summary:

- [ ] Drafts supported as separate system? Or status-based?
- [ ] Threads/carousels supported?
- [ ] Recurring posts supported?
- [ ] Advanced media search/filtering?
- [ ] Media folders/organization?
- [ ] Calendar views (day/list/export)?
- [ ] Platform-specific settings supported?
- [ ] firstComment field works?
- [ ] Error handling/retry mechanism?
- [ ] Analytics endpoints available?
- [ ] Bulk operations supported?
- [ ] Webhook/event system?
- [ ] Auto-scheduling/slot-finding?
- [ ] Version history?

---

## 💡 ADDITIONAL CONTEXT TO LOOK FOR

1. **Model/Schema Files** - Look for TypeScript interfaces or database models
2. **Route Files** - Look for Express/FastAPI route definitions
3. **Controller Files** - Look for API handler implementations
4. **Documentation** - Any OpenAPI/Swagger specs or API docs
5. **Test Files** - API endpoint tests that show usage examples
6. **Frontend Code** - How the frontend calls these APIs (real examples)

---

## 🚀 GOAL

The goal is to create a complete map of Postiz's capabilities so we can:
1. **Leverage existing features** instead of rebuilding them
2. **Identify gaps** that need custom implementation
3. **Design proper integration** that uses Postiz optimally
4. **Avoid duplicate functionality** between our CRM and Postiz

Thank you for this audit! 🙏
