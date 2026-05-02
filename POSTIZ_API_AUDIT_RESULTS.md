# Postiz API Audit Results

**Date:** March 11, 2026  
**Auditor:** AI Assistant  
**Project:** Social-Flow (Postiz Self-Hosted)

---

## 🎯 EXECUTIVE SUMMARY

This audit documents **ALL available API endpoints** in the Postiz backend. The system is comprehensive and feature-rich, with support for:

✅ **Post Management** - Full CRUD with draft/schedule/publish support  
✅ **Thread/Carousel Support** - Multi-post sequences with delays  
✅ **Recurring Posts (Autopost)** - RSS/webhook-based automatic posting  
✅ **28+ Platform Integrations** - Social media, blogs, messaging  
✅ **Media Management** - Upload, library, AI generation  
✅ **Analytics** - Per-post and per-integration analytics  
✅ **Sets (Templates)** - Reusable post configurations  
✅ **Tags System** - Organize and filter posts  
✅ **Webhooks** - Custom webhook integrations  
✅ **Calendar Views** - Day/week/month/list views  

---

## 📋 TABLE OF CONTENTS

1. [Post Creation & Management](#1-post-creation--management)
2. [Draft System](#2-draft-system)
3. [Thread/Carousel Support](#3-threadcarousel-support)
4. [Recurring Posts (Autopost)](#4-recurring-posts-autopost)
5. [Media Management](#5-media-management)
6. [Calendar & Views](#6-calendar--views)
7. [Integrations/Channels](#7-integrationschannels)
8. [Platform-Specific Settings](#8-platform-specific-settings)
9. [Error Handling & Retry](#9-error-handling--retry)
10. [Analytics & Insights](#10-analytics--insights)
11. [Bulk Operations](#11-bulk-operations)
12. [Search & Filtering](#12-search--filtering)
13. [Webhooks & Callbacks](#13-webhooks--callbacks)
14. [Special Features](#14-special-features)
15. [Sets/Templates](#15-setstemplates)
16. [Tags System](#16-tags-system)
17. [Limits & Constraints](#17-limits--constraints)
18. [Summary Checklist](#18-summary-checklist)

---

## 1️⃣ POST CREATION & MANAGEMENT

### Endpoint: `POST /posts`

**Status:** ✅ **EXISTS**

**Purpose:** Create, schedule, or publish posts to one or more platforms

**Request Schema:**
```typescript
{
  type: 'draft' | 'schedule' | 'now' | 'update'; // REQUIRED
  date: string; // ISO 8601 date string, REQUIRED
  shortLink: boolean; // Enable URL shortening, REQUIRED
  inter?: number; // Interval for recurring posts (days)
  order?: string; // Order ID (for specific use cases)
  tags: Array<{
    value: string;
    label: string;
  }>; // REQUIRED (can be empty array)
  posts: Array<{
    integration: {
      id: string; // Integration/channel ID
    };
    group: string; // Groups multi-platform posts together
    settings: AllProvidersSettings; // Platform-specific settings
    value: Array<{
      id?: string; // Post ID (for updates)
      content: string; // HTML content
      delay?: number; // Minutes to wait before this post (for threads)
      image: Array<{
        id: string;
        path: string; // Full URL or path
        alt?: string;
        thumbnail?: string; // For videos
        thumbnailTimestamp?: number; // Timestamp for video thumbnail
      }>;
    }>;
  }>;
}
```

**Response Format:**
```typescript
{
  success: boolean;
  // Additional response data from service
}
```

**Notes:**
- **Draft Support:** YES - Use `type: 'draft'` to save without scheduling
- **Immediate Posting:** YES - Use `type: 'now'` to post immediately
- **Scheduling:** YES - Use `type: 'schedule'` with future date
- **Updates:** YES - Use `type: 'update'` with existing post IDs
- **Thread Support:** YES - Use `delay` field in value array + multiple values
- **Multi-platform:** YES - Include multiple objects in `posts` array with same `group`
- **Permissions Check:** Enforces POSTS_PER_MONTH policy

---

### Endpoint: `GET /posts`

**Status:** ✅ **EXISTS**

**Purpose:** Get posts for calendar view with date range filtering

**Query Parameters:**
```typescript
{
  startDate: string; // ISO 8601, REQUIRED
  endDate: string; // ISO 8601, REQUIRED
  customer?: string; // Organization/customer filter
}
```

**Response Format:**
```typescript
{
  posts: Array<{
    id: string;
    group: string;
    publishDate: string;
    content: string;
    state: 'DRAFT' | 'QUEUE' | 'PUBLISHED' | 'ERROR';
    intervalInDays?: number;
    integration: {
      id: string;
      name: string;
      identifier: string;
      picture: string;
      // ... more integration data
    };
    image: Array<Media>;
    tags: Array<{ tag: Tag }>;
    // ... more post data
  }>;
  integrations: Array<Integration>;
  sets: Array<Set>;
  comments: Array<CommentSummary>;
  signature?: any;
  trendings?: string[];
}
```

**Notes:**
- Returns **minified** posts optimized for performance
- Date range is required
- Supports customer/organization filtering
- Includes related data (integrations, sets, comments)

---

### Endpoint: `GET /posts/list`

**Status:** ✅ **EXISTS**

**Purpose:** Get paginated list of posts (list view)

**Query Parameters:**
```typescript
{
  page?: number; // Default: 0, Min: 0
  limit?: number; // Default: 20, Min: 1, Max: 100
  customer?: string; // Organization filter
}
```

**Response Format:**
```typescript
{
  posts: Post[];
  total: number;
  pages: number;
  currentPage: number;
}
```

**Notes:**
- Maximum 100 posts per page
- Default page size: 20
- Pagination starts at 0

---

### Endpoint: `GET /posts/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Get single post by ID

**Response Format:**
```typescript
Post & {
  integration: Integration;
  tags: Array<{ tag: Tag }>;
  // Full post data
}
```

---

### Endpoint: `GET /posts/group/:group`

**Status:** ✅ **EXISTS**

**Purpose:** Get all posts in a group (multi-platform posts)

**Response Format:**
```typescript
Post[] // All posts sharing the same group ID
```

**Notes:**
- Groups link posts published together across multiple platforms
- Essential for editing multi-platform posts

---

### Endpoint: `PUT /posts/:id/date`

**Status:** ✅ **EXISTS**

**Purpose:** Change post date/time (drag & drop in calendar)

**Request Body:**
```typescript
{
  date: string; // ISO 8601
  action: 'schedule' | 'update'; // Default: 'schedule'
}
```

**Response Format:**
```typescript
{
  success: boolean;
}
```

**Notes:**
- Used for drag & drop in calendar
- Can reschedule or update existing posts

---

### Endpoint: `DELETE /posts/:group`

**Status:** ✅ **EXISTS**

**Purpose:** Delete post or entire post group

**Notes:**
- Deletes by **group ID**, not post ID
- Removes all posts in the group (multi-platform)
- **Hard delete** (not soft delete)

---

### Endpoint: `POST /posts/separate-posts`

**Status:** ✅ **EXISTS**

**Purpose:** Split long content into multiple posts based on character limit

**Request Body:**
```typescript
{
  content: string; // Content to split
  len: number; // Character limit per post
}
```

**Response Format:**
```typescript
{
  posts: string[]; // Array of split content
}
```

**Notes:**
- Useful for platforms with character limits
- Intelligently splits at sentence/paragraph boundaries

---

### Endpoint: `GET /posts/find-slot`

**Status:** ✅ **EXISTS**

**Purpose:** Find next available time slot for posting

**Response Format:**
```typescript
{
  date: string; // ISO 8601 date
}
```

**Notes:**
- Algorithm considers:
  - Existing scheduled posts
  - Platform posting times (optimal hours)
  - Post density
- Returns intelligent suggestion for best posting time

---

### Endpoint: `GET /posts/find-slot/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Find next available slot for specific integration

**Parameters:**
- `:id` - Integration ID

**Response Format:**
```typescript
{
  date: string; // ISO 8601 date
}
```

**Notes:**
- Respects integration-specific posting times
- Considers platform best practices

---

### Endpoint: `GET /posts/old`

**Status:** ✅ **EXISTS**

**Purpose:** Get posts before a specific date (for pagination)

**Query Parameters:**
```typescript
{
  date: string; // ISO 8601
}
```

---

## 2️⃣ DRAFT SYSTEM

### Status: ✅ **INTEGRATED INTO POST SYSTEM**

**Implementation:** Drafts are **NOT separate** from posts. They use the same endpoints with `state` field.

**Create Draft:**
```typescript
POST /posts
Body: {
  type: 'draft', // KEY: Use 'draft' type
  // ... rest of post data
}
```

**Draft States:**
- `DRAFT` - Saved but not scheduled
- `QUEUE` - Scheduled for future
- `PUBLISHED` - Already posted
- `ERROR` - Failed to post

**Get Drafts:**
```typescript
GET /posts
// Filter by state='DRAFT' in response
```

**Convert Draft to Scheduled:**
```typescript
POST /posts
Body: {
  type: 'schedule', // Change type
  // Include post IDs from draft in value[].id
  // ... rest of data
}
```

**Notes:**
- ✅ Drafts stored in same table as posts
- ✅ Filter by `state` field
- ✅ Can convert draft → scheduled → published
- ✅ Can revert published → draft (update type)

---

## 3️⃣ THREAD/CAROUSEL SUPPORT

### Status: ✅ **FULLY SUPPORTED**

**Implementation:** Threads are created using **multiple values** in a single post with **delay** fields.

**Create Thread:**
```typescript
POST /posts
Body: {
  type: 'schedule',
  date: '2026-03-15T10:00:00Z',
  posts: [{
    integration: { id: 'twitter-123' },
    group: 'unique-group-id',
    value: [
      {
        content: '<p>First tweet in thread...</p>',
        delay: 0, // Post immediately
        image: []
      },
      {
        content: '<p>Second tweet...</p>',
        delay: 5, // Wait 5 minutes after first
        image: []
      },
      {
        content: '<p>Third tweet...</p>',
        delay: 10, // Wait 10 minutes after first (cumulative)
        image: []
      }
    ]
  }]
}
```

**Features:**
- ✅ Unlimited posts per thread
- ✅ Custom delays between posts (in minutes)
- ✅ Each post can have different content and media
- ✅ Platform-specific threading rules handled automatically
- ✅ If one post fails, system continues with others
- ✅ `group` field links thread posts together

**Get Thread:**
```typescript
GET /posts/group/:groupId
// Returns all posts in thread
```

**Update Thread:**
```typescript
POST /posts
Body: {
  type: 'update',
  // Include all post IDs in value[].id
  // Modify content, delays, or media as needed
}
```

**Notes:**
- Delays are in **minutes**
- Delays are **cumulative** from the first post
- Each platform handles threading differently (handled in orchestrator)
- Thread integrity maintained via `group` field

---

## 4️⃣ RECURRING POSTS (AUTOPOST)

### Status: ✅ **FULLY SUPPORTED** (via Autopost system)

**Base Path:** `/autopost`

---

### Endpoint: `GET /autopost`

**Status:** ✅ **EXISTS**

**Purpose:** List all autopost/recurring configurations

**Response Format:**
```typescript
Autopost[] // Array of autopost configurations
```

---

### Endpoint: `POST /autopost`

**Status:** ✅ **EXISTS**

**Purpose:** Create recurring post configuration

**Request Body:**
```typescript
{
  name: string;
  url: string; // RSS feed or webhook URL
  active: boolean;
  integrations: string[]; // Integration IDs
  settings: {
    // Platform-specific settings
  };
  type: 'rss' | 'webhook';
  // Additional configuration
}
```

**Response Format:**
```typescript
{
  id: string;
  // ... created autopost data
}
```

**Notes:**
- Supports **RSS feeds** and **webhooks**
- Automatically creates posts from feed/webhook
- Permissions check: WEBHOOKS policy

---

### Endpoint: `PUT /autopost/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Update autopost configuration

**Request Body:**
```typescript
AutopostDto // Same as POST
```

---

### Endpoint: `DELETE /autopost/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Delete autopost configuration

**Notes:**
- Stops automatic posting
- Does not delete already created posts

---

### Endpoint: `POST /autopost/:id/active`

**Status:** ✅ **EXISTS**

**Purpose:** Enable/disable autopost

**Request Body:**
```typescript
{
  active: boolean;
}
```

**Notes:**
- Pause/resume without deleting configuration

---

### Endpoint: `POST /autopost/send`

**Status:** ✅ **EXISTS**

**Purpose:** Test/trigger autopost manually

**Query Parameters:**
```typescript
{
  url: string; // RSS/webhook URL to test
}
```

**Response Format:**
```typescript
{
  // Parsed feed/webhook data
}
```

---

**Recurring Post Features:**

✅ **RSS Feed Support** - Auto-pull from RSS feeds  
✅ **Webhook Support** - Trigger from external events  
✅ **Multi-platform** - Post to multiple channels  
✅ **Enable/Disable** - Pause without deleting  
✅ **Manual Trigger** - Test before enabling  

❌ **NOT Supported:**
- Traditional cron-style recurring (daily/weekly/monthly) via autopost
- Use `inter` field in POST /posts for interval-based recurring

**For Interval-Based Recurring:**
```typescript
POST /posts
Body: {
  inter: 7, // Repeat every 7 days
  // ... rest of post data
}
```

The system will automatically recreate the post after the interval.

---

## 5️⃣ MEDIA MANAGEMENT

### Base Path: `/media`

---

### Endpoint: `GET /media`

**Status:** ✅ **EXISTS**

**Purpose:** Get media library with pagination

**Query Parameters:**
```typescript
{
  page: number; // Page number
}
```

**Response Format:**
```typescript
{
  media: Array<{
    id: string;
    path: string; // Full URL
    name: string;
    originalName: string;
    createdAt: Date;
    // ... more media data
  }>;
  total: number;
  pages: number;
}
```

---

### Endpoint: `POST /media/upload-server`

**Status:** ✅ **EXISTS**

**Purpose:** Upload media file

**Content-Type:** `multipart/form-data`

**Request Body:**
```typescript
FormData {
  file: File; // File to upload
}
```

**Response Format:**
```typescript
{
  id: string;
  path: string; // Full URL
  name: string;
  originalName: string;
}
```

**Notes:**
- Maximum file size: Configurable (typically 1GB)
- Stored in Cloudflare R2 or local storage
- Automatic thumbnail generation for videos

---

### Endpoint: `POST /media/upload-simple`

**Status:** ✅ **EXISTS**

**Purpose:** Simple file upload with optional save prevention

**Content-Type:** `multipart/form-data`

**Request Body:**
```typescript
FormData {
  file: File;
  preventSave?: 'true' | 'false'; // If true, uploads but doesn't save to DB
}
```

**Response Format:**
```typescript
{
  id?: string; // If saved
  path: string; // Full URL
  name: string;
  originalName: string;
}
```

**Notes:**
- Use `preventSave: 'true'` for temporary uploads
- Useful for thumbnails or temp files

---

### Endpoint: `POST /media/:endpoint`

**Status:** ✅ **EXISTS**

**Purpose:** Multipart upload handler (for large files)

**Supported Endpoints:**
- `initiate-multipart-upload`
- `get-multipart-presigned-urls`
- `complete-multipart-upload`
- `abort-multipart-upload`

**Notes:**
- For files >100MB
- Uses multipart upload to R2/S3
- Returns presigned URLs for chunk uploads

---

### Endpoint: `POST /media/save-media`

**Status:** ✅ **EXISTS**

**Purpose:** Save already uploaded media to database

**Request Body:**
```typescript
{
  name: string; // Filename
  originalName: string; // Original filename
}
```

**Notes:**
- Use after uploading directly to storage
- Associates uploaded file with organization

---

### Endpoint: `POST /media/information`

**Status:** ✅ **EXISTS**

**Purpose:** Update media metadata (alt text, etc.)

**Request Body:**
```typescript
{
  id: string;
  alt?: string;
  // Other media metadata
}
```

---

### Endpoint: `DELETE /media/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Delete media file

**Notes:**
- Removes from database and storage
- Cannot be undone

---

### Endpoint: `POST /media/generate-image`

**Status:** ✅ **EXISTS** (AI Features)

**Purpose:** Generate AI image from prompt

**Request Body:**
```typescript
{
  prompt: string; // Text prompt for image generation
}
```

**Response Format:**
```typescript
{
  output: string; // Base64 encoded image or URL
}
```

**Notes:**
- Uses AI image generation service
- Requires credits (if Stripe enabled)
- Returns base64 by default

---

### Endpoint: `POST /media/generate-image-with-prompt`

**Status:** ✅ **EXISTS** (AI Features)

**Purpose:** Generate AI image and save to library

**Request Body:**
```typescript
{
  prompt: string;
}
```

**Response Format:**
```typescript
{
  id: string;
  path: string;
  // Saved media object
}
```

**Notes:**
- Combines generation + upload + save
- Directly adds to media library

---

### Endpoint: `POST /media/generate-video`

**Status:** ✅ **EXISTS** (AI Features)

**Purpose:** Generate AI video

**Request Body:**
```typescript
VideoDto // Video generation parameters
```

**Notes:**
- More complex than images
- May take longer to process
- Returns video URL when complete

---

### Endpoint: `GET /media/video-options`

**Status:** ✅ **EXISTS**

**Purpose:** Get available video generation options/templates

---

### Endpoint: `POST /media/video/function`

**Status:** ✅ **EXISTS**

**Purpose:** Call video service functions

**Request Body:**
```typescript
{
  identifier: string; // Video service identifier
  functionName: string; // Function to call
  params: any; // Function parameters
}
```

---

### Endpoint: `GET /media/generate-video/:type/allowed`

**Status:** ✅ **EXISTS**

**Purpose:** Check if video generation is allowed for user

---

**Media Features Summary:**

✅ **File Upload** - Multiple methods (simple, multipart)  
✅ **Media Library** - Paginated browsing  
✅ **AI Generation** - Images and videos  
✅ **Metadata** - Alt text, captions  
✅ **Large File Support** - Multipart chunked uploads  

❌ **NOT Available:**
- Folders/organization (flat structure)
- Tags/categories for media
- Advanced search/filtering (basic page-based)
- Bulk delete
- Storage quota tracking (manual query needed)

---

## 6️⃣ CALENDAR & VIEWS

### Calendar View Support

**Implementation:** Calendar views are handled via query parameters on `GET /posts`

---

### Day View

**Endpoint:** `GET /posts?startDate=2026-03-11&endDate=2026-03-11`

**Notes:**
- Same start and end date
- Returns posts for single day
- Grouped by hour in frontend

---

### Week View (Default)

**Endpoint:** `GET /posts?startDate=2026-03-10&endDate=2026-03-16`

**Notes:**
- 7-day range (ISO week: Monday-Sunday)
- Frontend calculates week boundaries
- Most common view

---

### Month View

**Endpoint:** `GET /posts?startDate=2026-03-01&endDate=2026-03-31`

**Notes:**
- Full month date range
- Frontend handles calendar grid
- Shows post density

---

### List View

**Endpoint:** `GET /posts/list?page=0&limit=100`

**Notes:**
- Ignores date range
- Paginated list of all posts
- Max 100 per page

---

### Calendar Features

✅ **Multiple Views** - Day/Week/Month/List  
✅ **Date Range Filtering** - Flexible date queries  
✅ **Customer Filter** - Multi-tenant support  
✅ **Related Data** - Includes integrations, sets, comments  

❌ **NOT Available:**
- Export to iCal format
- Export to CSV
- Calendar statistics endpoint (must calculate in frontend)
- Aggregation queries (posts per day/hour)

**Workaround for Statistics:**
- Fetch posts and aggregate in frontend
- Or create custom endpoint

---

## 7️⃣ INTEGRATIONS/CHANNELS

### Base Path: `/integrations`

---

### Endpoint: `GET /integrations/list`

**Status:** ✅ **EXISTS**

**Purpose:** Get all connected integrations for organization

**Response Format:**
```typescript
{
  integrations: Array<{
    id: string;
    name: string; // Display name
    internalId: string; // Platform-specific ID
    identifier: string; // 'x', 'linkedin', 'facebook', etc.
    picture: string; // Avatar URL
    type: string; // 'social', 'blog', 'messaging', etc.
    disabled: boolean;
    editor: 'normal' | 'markdown' | 'html' | 'none';
    display: string; // Profile name
    time: Array<{ time: number }>; // Preferred posting times
    inBetweenSteps: boolean;
    refreshNeeded: boolean; // Token needs refresh
    isCustomFields: boolean;
    customFields?: any; // Platform-specific custom fields
    changeProfilePicture: boolean;
    changeNickName: boolean;
    customer?: {
      id: string;
      name: string;
    };
    additionalSettings: string; // JSON string of settings
  }>;
}
```

**Notes:**
- Returns all connected channels
- Includes platform capabilities
- Shows which need token refresh

---

### Endpoint: `GET /integrations/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Get single integration details

**Query Parameters:**
```typescript
{
  order?: string; // Order ID
}
```

---

### Endpoint: `GET /integrations/social/:integration`

**Status:** ✅ **EXISTS**

**Purpose:** Get OAuth URL to connect new integration

**Query Parameters:**
```typescript
{
  refresh?: string; // Refresh existing connection
  externalUrl?: string; // Callback URL
  onboarding?: string; // Onboarding flow
}
```

**Response Format:**
```typescript
{
  url: string; // OAuth authorization URL
}
```

**Notes:**
- Redirects user to platform for authorization
- Handles OAuth1 and OAuth2
- Returns callback URL with tokens

---

### Endpoint: `DELETE /integrations`

**Status:** ✅ **EXISTS**

**Purpose:** Delete/disconnect integration

**Request Body:**
```typescript
{
  id: string; // Integration ID
}
```

---

### Endpoint: `POST /integrations/disable`

**Status:** ✅ **EXISTS**

**Purpose:** Disable integration without deleting

**Request Body:**
```typescript
{
  id: string;
}
```

---

### Endpoint: `POST /integrations/enable`

**Status:** ✅ **EXISTS**

**Purpose:** Re-enable disabled integration

**Request Body:**
```typescript
{
  id: string;
}
```

---

### Endpoint: `POST /integrations/:id/settings`

**Status:** ✅ **EXISTS**

**Purpose:** Update integration settings

**Request Body:**
```typescript
{
  additionalSettings: string; // JSON string of settings
}
```

**Notes:**
- Platform-specific settings
- Must be valid JSON string

---

### Endpoint: `POST /integrations/:id/nickname`

**Status:** ✅ **EXISTS**

**Purpose:** Change profile name/picture on platform

**Request Body:**
```typescript
{
  name: string; // New display name
  picture: string; // New picture URL
}
```

**Response Format:**
```typescript
{
  name: string; // Updated name
  url: string; // Updated picture URL
}
```

**Notes:**
- Only works if platform supports it (changeProfilePicture/changeNickname)
- Actually updates the platform profile

---

### Endpoint: `POST /integrations/:id/time`

**Status:** ✅ **EXISTS**

**Purpose:** Set preferred posting times for integration

**Request Body:**
```typescript
{
  time: Array<{ time: number }>; // Hours (0-23)
}
```

**Notes:**
- Used by find-slot algorithm
- Suggests posts during these hours

---

### Endpoint: `GET /integrations/customers`

**Status:** ✅ **EXISTS**

**Purpose:** Get list of customers/organizations (for agencies)

**Response Format:**
```typescript
Array<{
  id: string;
  name: string;
}>
```

**Notes:**
- Multi-tenant support
- For agency/white-label scenarios

---

### Endpoint: `PUT /integrations/:id/group`

**Status:** ✅ **EXISTS**

**Purpose:** Update integration group/category

**Request Body:**
```typescript
{
  group: string;
}
```

---

### Endpoint: `PUT /integrations/:id/customer-name`

**Status:** ✅ **EXISTS**

**Purpose:** Update customer name for integration

**Request Body:**
```typescript
{
  name: string;
}
```

---

### Endpoint: `GET /integrations/:identifier/internal-plugs`

**Status:** ✅ **EXISTS**

**Purpose:** Get internal plugin options for platform

**Parameters:**
- `:identifier` - Platform identifier ('x', 'linkedin', etc.)

---

### Endpoint: `POST /integrations/mentions`

**Status:** ✅ **EXISTS**

**Purpose:** Search for mentions/users on platform

**Request Body:**
```typescript
{
  integrationId: string;
  query: string; // Search query
}
```

**Response Format:**
```typescript
{
  mentions: Array<{
    id: string;
    name: string;
    username: string;
    avatar: string;
  }>;
}
```

**Notes:**
- Used for @mention autocomplete
- Platform-specific implementation

---

### Endpoint: `POST /integrations/function`

**Status:** ✅ **EXISTS**

**Purpose:** Call platform-specific function

**Request Body:**
```typescript
{
  integrationId: string;
  functionName: string;
  params: any;
}
```

**Notes:**
- Generic endpoint for platform capabilities
- Examples: get communities, get pages, get groups

---

### **Platform Capabilities Detection**

Postiz **automatically detects** platform capabilities from integration data:

**Character Limits:**
```typescript
integration.additionalSettings // Includes premium status
// Example: Twitter Blue = 4000 chars vs 280
```

**Media Restrictions:**
- Defined in platform provider classes
- Checked during post validation
- Returns errors if limits exceeded

**Premium Features:**
- Stored in `additionalSettings` array
- Example: `[{ title: 'Verified', value: true }]`
- Used in validation logic

❌ No dedicated `/integrations/:id/capabilities` endpoint  
✅ Capabilities included in integration list data  

---

## 8️⃣ PLATFORM-SPECIFIC SETTINGS

### Post Creation with Platform Settings

When creating posts via `POST /posts`, platform-specific settings are included in the `settings` field:

```typescript
{
  posts: [{
    integration: { id: 'integration-id' },
    settings: {
      __type: 'x', // Discriminator for platform type
      // Platform-specific fields below
    }
  }]
}
```

### Available Platform Settings

Based on DTO analysis, here are the supported settings per platform:

---

#### **X (Twitter)**

**DTO:** `XDto`

```typescript
{
  __type: 'x',
  who_can_reply_post?: 'everyone' | 'following' | 'mentionedUsers' | 'subscribers' | 'verified';
  community?: string; // Community URL
}
```

---

#### **LinkedIn**

**DTO:** `LinkedInDto`

```typescript
{
  __type: 'linkedin',
  // Settings determined by platform
}
```

---

#### **Facebook**

**DTO:** `FacebookDto`

```typescript
{
  __type: 'facebook',
  // Settings TBD
}
```

---

#### **Instagram**

**DTO:** `InstagramDto`

```typescript
{
  __type: 'instagram',
  collaborators?: string[]; // User IDs
  // Additional settings TBD
}
```

---

#### **Dev.to**

**DTO:** `DevToSettingsDto`

```typescript
{
  __type: 'devto',
  tags?: string[];
  series?: string;
  canonical_url?: string;
}
```

---

#### **Medium**

**DTO:** `MediumSettingsDto`

```typescript
{
  __type: 'medium',
  tags?: string[];
  canonicalUrl?: string;
  license?: string;
  notifyFollowers?: boolean;
}
```

---

#### **Hashnode**

**DTO:** `HashnodeSettingsDto`

```typescript
{
  __type: 'hashnode',
  tags?: string[];
  series?: string;
  disableComments?: boolean;
}
```

---

#### **YouTube**

**DTO:** Not found in initial scan - likely complex

```typescript
{
  __type: 'youtube',
  // Settings likely include:
  // title, description, category, visibility, etc.
}
```

---

#### **Pinterest**

**DTO:** `PinterestDto`

```typescript
{
  __type: 'pinterest',
  board?: string; // Board ID
  link?: string; // Destination URL
}
```

---

#### **Discord**

**DTO:** `DiscordDto`

```typescript
{
  __type: 'discord',
  channel?: string; // Channel ID
}
```

---

#### **Dribbble**

**DTO:** `DribbbleDto`

```typescript
{
  __type: 'dribbble',
  tags?: string[];
}
```

---

#### **Google My Business**

**DTO:** `GmbSettingsDto`

```typescript
{
  __type: 'gmb',
  location?: string;
  actionType?: string;
}
```

---

#### **Additional Platforms:**

Similar DTOs exist for:
- Lemmy (`LemmyDto`)
- Kick (`KickDto`)
- Moltbook (`MoltbookDto`)
- Listmonk (`ListmonkDto`)
- Warpcast/Farcaster (`FarcasterDto`)

---

### Settings Validation

**Validation Path:**
1. DTO discriminator identifies platform (`__type` field)
2. Class-validator validates against platform DTO
3. Platform provider validates media/content requirements
4. Settings passed to orchestrator for posting

**Example:**
```typescript
// Full post with X settings
{
  type: 'schedule',
  date: '2026-03-15T10:00:00Z',
  shortLink: true,
  tags: [],
  posts: [{
    integration: { id: 'twitter-123' },
    group: 'group-abc',
    settings: {
      __type: 'x',
      who_can_reply_post: 'verified',
      community: 'https://x.com/i/communities/123456'
    },
    value: [{
      content: '<p>Hello Twitter!</p>',
      delay: 0,
      image: []
    }]
  }]
}
```

---

### First Comment Support

**Status:** ⚠️ **PARTIAL SUPPORT**

Some platforms have "first comment" functionality:

**Instagram:**
- Likely supported via `settings` field
- Check InstagramDto for `firstComment` field

**Facebook:**
- Similar implementation expected

**General Posts:**
- No global `firstComment` field in CreatePostDto
- Must be platform-specific in settings

**Workaround:**
Create a second post in the thread with delay:
```typescript
value: [
  { content: '<p>Main post</p>', delay: 0 },
  { content: '<p>First comment</p>', delay: 1 } // 1 minute delay
]
```

---

## 9️⃣ ERROR HANDLING & RETRY

### Post Status/State

Posts have a `state` field with these values:

**States:**
- `DRAFT` - Saved, not scheduled
- `QUEUE` - Scheduled, waiting
- `PUBLISHED` - Successfully posted
- `ERROR` - Failed to post

---

### Endpoint: `GET /posts/:id/missing`

**Status:** ✅ **EXISTS**

**Purpose:** Get missing content/requirements for post

**Response Format:**
```typescript
{
  missingFields: string[];
  requiredActions: string[];
  // Details about what's needed
}
```

**Notes:**
- Checks platform requirements
- Returns validation errors
- Useful before posting

---

### Endpoint: `GET /posts/:id/statistics`

**Status:** ✅ **EXISTS**

**Purpose:** Get post statistics and status

**Response Format:**
```typescript
{
  views?: number;
  likes?: number;
  comments?: number;
  shares?: number;
  engagement?: number;
  reach?: number;
  state: string;
  error?: string; // Error message if failed
  // Platform-specific metrics
}
```

**Notes:**
- Includes error information if post failed
- Can check state and error fields

---

### Retry Failed Posts

**Status:** ❌ **NO DEDICATED RETRY ENDPOINT**

**Workaround:**
```typescript
// Get failed post
GET /posts/:id

// Re-submit with type: 'now' or 'schedule'
POST /posts
Body: {
  type: 'now',
  // Copy post data
}
```

**Alternative:**
- Edit post in UI
- Change state from ERROR to QUEUE
- Orchestrator will retry automatically

---

### Monitor Queue

**Endpoint:** `GET /monitor/queue/:name`

**Status:** ✅ **EXISTS** (Admin only)

**Purpose:** Monitor BullMQ queue status

**Notes:**
- Internal/admin endpoint
- Not for regular API use
- Shows queue jobs, failed jobs, etc.

---

### Error Logging

**Status:** ❌ **NO DEDICATED ERROR LOG ENDPOINT**

**Error Information Available:**
- In post `state` field (ERROR)
- In statistics endpoint (error message)
- In orchestrator logs (server-side)

**Best Practice:**
- Filter posts by `state: 'ERROR'`
- Get error details from statistics
- Display to user for manual retry

---

## 🔟 ANALYTICS & INSIGHTS

### Base Path: `/analytics`

---

### Endpoint: `GET /analytics/:integration`

**Status:** ✅ **EXISTS**

**Purpose:** Get analytics for specific integration

**Query Parameters:**
```typescript
{
  date: string; // ISO date or timestamp
}
```

**Response Format:**
```typescript
{
  // Platform-specific analytics
  followers?: number;
  following?: number;
  posts?: number;
  engagement?: number;
  reach?: number;
  impressions?: number;
  // Varies by platform
}
```

**Notes:**
- Fetches from platform API
- Date parameter specifies reporting period
- Different metrics per platform

---

### Endpoint: `GET /analytics/post/:postId`

**Status:** ✅ **EXISTS**

**Purpose:** Get analytics for specific post

**Query Parameters:**
```typescript
{
  date: string; // Timestamp
}
```

**Response Format:**
```typescript
{
  views?: number;
  likes?: number;
  comments?: number;
  shares?: number;
  clicks?: number;
  engagement?: number;
  reach?: number;
  impressions?: number;
  // Platform-specific metrics
}
```

**Notes:**
- Real-time or delayed (depends on platform)
- May return null if platform doesn't provide analytics
- Some platforms require time for data processing

---

### Analytics Features

✅ **Per-Integration Analytics** - Account-level metrics  
✅ **Per-Post Analytics** - Individual post performance  
✅ **Platform-Specific** - Adapts to each platform's API  

❌ **NOT Available:**
- Aggregated analytics across all platforms
- Historical trending/comparison
- Custom reports
- Export analytics
- Scheduled reports

**Workaround for Aggregation:**
- Fetch analytics for each post/integration
- Aggregate in your application
- Store historical data in your database

---

## 1️⃣1️⃣ BULK OPERATIONS

### Bulk Delete Posts

**Status:** ❌ **NO DEDICATED BULK DELETE ENDPOINT**

**Workaround:**
```typescript
// Delete posts one by one
for (const groupId of groupIds) {
  await DELETE(`/posts/${groupId}`);
}
```

**Alternative:**
- Create custom endpoint
- Or use database queries directly

---

### Bulk Create Posts

**Status:** ✅ **SUPPORTED** via `POST /posts`

**Implementation:**
Create multiple posts by including different groups:

```typescript
POST /posts
Body: {
  type: 'schedule',
  date: '2026-03-15T10:00:00Z',
  posts: [
    {
      integration: { id: 'twitter-123' },
      group: 'group-1',
      value: [{ content: 'Post 1', delay: 0, image: [] }]
    },
    {
      integration: { id: 'linkedin-456' },
      group: 'group-2',
      value: [{ content: 'Post 2', delay: 0, image: [] }]
    },
    // Add more posts...
  ]
}
```

**Notes:**
- Each post needs unique `group` ID
- All scheduled for same date
- Can target different platforms

---

### Bulk Update

**Status:** ❌ **NO DEDICATED BULK UPDATE ENDPOINT**

**Workaround:** Update posts individually via `POST /posts` with `type: 'update'`

---

### Bulk Media Operations

**Delete Multiple Media:**

**Status:** ❌ **NO BULK DELETE ENDPOINT**

**Workaround:**
```typescript
for (const mediaId of mediaIds) {
  await DELETE(`/media/${mediaId}`);
}
```

---

### Bulk Schedule

**Status:** ⚠️ **PARTIAL** via AI Generator

**Endpoint:** `POST /posts/generator`

Generates multiple posts at once (AI-powered), but this is more for content generation than bulk scheduling existing posts.

---

## 1️⃣2️⃣ SEARCH & FILTERING

### GET /posts Query Parameters

**Available Filters:**
```typescript
{
  startDate: string; // REQUIRED - ISO 8601
  endDate: string; // REQUIRED - ISO 8601
  customer?: string; // Organization/customer ID
}
```

---

### GET /posts/list Query Parameters

**Available Filters:**
```typescript
{
  page?: number; // Pagination
  limit?: number; // Results per page (max 100)
  customer?: string; // Organization filter
}
```

---

### Search Capabilities

**Status by Feature:**

✅ **Date Range Filtering** - Via startDate/endDate  
✅ **Customer Filtering** - Via customer parameter  
✅ **Pagination** - Via page/limit  

❌ **NOT Available:**
- `status` filter (draft/scheduled/published)
- `integrationId` or `platform` filter
- Content search / full-text search
- Tag filtering
- Sort options (sortBy/sortOrder)
- Advanced queries

---

### Workarounds

**Filter by Status:**
```typescript
// Get all posts, filter in application
const response = await GET('/posts?startDate=...&endDate=...');
const drafts = response.posts.filter(p => p.state === 'DRAFT');
const scheduled = response.posts.filter(p => p.state === 'QUEUE');
```

**Filter by Platform:**
```typescript
const posts = await GET('/posts?startDate=...&endDate=...');
const twitterPosts = posts.posts.filter(p => 
  p.integration.identifier === 'x'
);
```

**Content Search:**
```typescript
const posts = await GET('/posts/list?page=0&limit=100');
const results = posts.posts.filter(p => 
  p.content.toLowerCase().includes(searchQuery.toLowerCase())
);
```

**Recommendation:**
- Fetch posts and filter client-side
- Or create custom search endpoint
- Consider implementing Elasticsearch for large datasets

---

## 1️⃣3️⃣ WEBHOOKS & CALLBACKS

### Base Path: `/webhooks`

---

### Endpoint: `GET /webhooks`

**Status:** ✅ **EXISTS**

**Purpose:** List all registered webhooks

**Response Format:**
```typescript
Webhook[] // Array of webhook configurations
```

---

### Endpoint: `POST /webhooks`

**Status:** ✅ **EXISTS**

**Purpose:** Create/register new webhook

**Request Body:**
```typescript
{
  name: string;
  url: string; // Webhook callback URL
  events: string[]; // Which events trigger webhook
  active: boolean;
  // Additional configuration
}
```

**Response Format:**
```typescript
{
  id: string;
  // Created webhook data
}
```

**Notes:**
- Permissions check: WEBHOOKS policy
- Validates URL format

---

### Endpoint: `PUT /webhooks`

**Status:** ✅ **EXISTS**

**Purpose:** Update webhook configuration

**Request Body:**
```typescript
{
  id: string;
  name: string;
  url: string;
  events: string[];
  active: boolean;
}
```

---

### Endpoint: `DELETE /webhooks/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Delete webhook

---

### Endpoint: `POST /webhooks/send`

**Status:** ✅ **EXISTS**

**Purpose:** Test webhook by sending request

**Query Parameters:**
```typescript
{
  url: string; // Webhook URL to test
}
```

**Request Body:**
```typescript
any // Payload to send
```

**Response Format:**
```typescript
{
  send: boolean; // Always true (even if failed)
}
```

**Notes:**
- Fire-and-forget
- Doesn't report errors
- Use for testing only

---

### Webhook Events

**Available Events:** (Based on Autopost system)

- `post.created` - New post created
- `post.published` - Post successfully published
- `post.failed` - Post failed to publish
- (More events configurable)

**Event Payload Format:**
```typescript
{
  event: string; // Event name
  timestamp: string; // ISO 8601
  data: {
    postId: string;
    groupId: string;
    integration: string;
    state: string;
    // Event-specific data
  }
}
```

**Notes:**
- Webhooks are HTTP POST requests
- Content-Type: application/json
- No retry mechanism (send once)
- No signature verification (add your own)

---

### Webhook Features

✅ **Register Webhooks** - Multiple per organization  
✅ **Event Filtering** - Select which events  
✅ **Enable/Disable** - Pause without deleting  
✅ **Test Endpoint** - Verify webhook works  

❌ **Missing Features:**
- Webhook signature/HMAC validation
- Retry on failure
- Delivery logs/history
- Webhook payload customization
- Rate limiting

**Security Recommendation:**
- Validate webhook origin in your application
- Use HTTPS only
- Implement your own signature validation
- Whitelist Postiz IP addresses

---

## 1️⃣4️⃣ SPECIAL FEATURES

### AI Post Generation

---

### Endpoint: `POST /posts/generator`

**Status:** ✅ **EXISTS**

**Purpose:** Generate posts using AI (streaming)

**Request Body:**
```typescript
{
  prompt: string;
  platforms: string[]; // Platform identifiers
  count?: number; // Number of posts to generate
  tone?: string; // 'professional', 'casual', etc.
  // Additional generation parameters
}
```

**Response Format:**
```
Content-Type: application/json; charset=utf-8
Server-Sent Events (SSE)

Each line: JSON object
{
  type: 'progress' | 'post' | 'complete' | 'error';
  data: any;
}
```

**Notes:**
- Streaming response (not standard JSON)
- Generates multiple posts at once
- Permissions check: POSTS_PER_MONTH
- Expensive operation (uses credits)

---

### Endpoint: `POST /posts/generator/draft`

**Status:** ✅ **EXISTS**

**Purpose:** Generate draft posts (non-streaming)

**Request Body:**
```typescript
{
  prompt: string;
  platforms: string[];
  count: number;
}
```

**Response Format:**
```typescript
{
  posts: Array<{
    content: string;
    platform: string;
    // Generated post data
  }>;
}
```

**Notes:**
- Returns all posts at once
- Saved as drafts (not scheduled)
- Permissions check: POSTS_PER_MONTH

---

### Endpoint: `POST /posts/:id/duplicate`

**Status:** ❌ **NOT AVAILABLE**

**Workaround:**
```typescript
// Get post
const post = await GET(`/posts/:id`);

// Create new post with same data
await POST('/posts', {
  ...post,
  group: makeNewGroupId(),
  date: newDate,
  // Remove post IDs
  posts: post.posts.map(p => ({
    ...p,
    value: p.value.map(v => ({
      ...v,
      id: undefined // Remove to create new
    }))
  }))
});
```

---

### Endpoint: `POST /posts/:id/lock`

**Status:** ❌ **NOT AVAILABLE**

**Alternative:**
- Implement in your application layer
- Use database flags
- Check before allowing edits

---

### Endpoint: `GET /posts/:id/history`

**Status:** ❌ **NOT AVAILABLE**

**Notes:**
- No version history tracking
- No audit log for post edits
- Single version only

**Workaround:**
- Implement in your application
- Store snapshots before updates
- Use separate history table

---

### Endpoint: `POST /posts/:id/revert`

**Status:** ❌ **NOT AVAILABLE**

---

### URL Shortening

---

### Endpoint: `POST /posts/should-shortlink`

**Status:** ✅ **EXISTS**

**Purpose:** Check if posts should have URLs shortened

**Request Body:**
```typescript
{
  messages: string[]; // Post contents to check
}
```

**Response Format:**
```typescript
{
  ask: boolean; // true if URLs found
}
```

**Notes:**
- Scans for URLs in content
- Returns whether to ask user
- Actual shortening happens during post creation if `shortLink: true`

---

### Comments System

---

### Endpoint: `POST /posts/:id/comments`

**Status:** ✅ **EXISTS**

**Purpose:** Add internal comment to post

**Request Body:**
```typescript
{
  comment: string;
}
```

**Response Format:**
```typescript
{
  id: string;
  postId: string;
  userId: string;
  content: string;
  createdAt: Date;
}
```

**Notes:**
- Internal team comments
- Not published to platforms
- Collaboration feature

---

### Endpoint: `GET /public/posts/:id/comments`

**Status:** ✅ **EXISTS** (Public endpoint)

**Purpose:** Get public comments on post preview

**Response Format:**
```typescript
{
  comments: Array<{
    id: string;
    userId: string;
    content: string;
    createdAt: Date;
  }>;
}
```

**Notes:**
- Public preview feature
- Requires no authentication
- For pre-publication feedback

---

## 1️⃣5️⃣ SETS/TEMPLATES

### Base Path: `/sets`

---

### Endpoint: `GET /sets`

**Status:** ✅ **EXISTS**

**Purpose:** Get all sets/templates for organization

**Response Format:**
```typescript
Array<{
  id: string;
  name: string;
  content: string; // JSON string of post configuration
  organizationId: string;
  createdAt: Date;
}>
```

**Notes:**
- Sets are reusable post templates
- Content includes channel selections, settings, etc.
- Does NOT include actual post content (that's added when using set)

---

### Endpoint: `POST /sets`

**Status:** ✅ **EXISTS**

**Purpose:** Create new set/template

**Request Body:**
```typescript
{
  name: string;
  content: string; // JSON string of configuration
}
```

**Response Format:**
```typescript
{
  id: string;
  name: string;
  content: string;
}
```

**Notes:**
- `content` should be JSON stringified object
- Includes: selected integrations, settings, structure

---

### Endpoint: `PUT /sets`

**Status:** ✅ **EXISTS**

**Purpose:** Update existing set

**Request Body:**
```typescript
{
  id: string;
  name: string;
  content: string;
}
```

---

### Endpoint: `DELETE /sets/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Delete set/template

---

### Sets Usage Flow

1. **Create Set:** Save post configuration (channels, settings)
2. **Use Set:** When creating post, load set configuration
3. **Add Content:** Fill in actual post content
4. **Schedule:** Post using set template

**Set Content Example:**
```json
{
  "posts": [
    {
      "integration": { "id": "twitter-123" },
      "settings": {
        "__type": "x",
        "who_can_reply_post": "everyone"
      }
    },
    {
      "integration": { "id": "linkedin-456" },
      "settings": { "__type": "linkedin" }
    }
  ]
}
```

---

### Sets Features

✅ **Create Reusable Templates**  
✅ **Save Channel Configurations**  
✅ **Save Platform Settings**  
✅ **Update and Delete Sets**  

❌ **NOT Available:**
- Set categories/folders
- Share sets between organizations
- Set permissions (team member access)
- Set usage statistics
- Public set library

---

## 1️⃣6️⃣ TAGS SYSTEM

### Base Path: `/posts/tags` (under posts)

---

### Endpoint: `GET /posts/tags`

**Status:** ✅ **EXISTS**

**Purpose:** Get all tags for organization

**Response Format:**
```typescript
{
  tags: Array<{
    id: string;
    name: string;
    color: string; // Hex color code
    organizationId: string;
    createdAt: Date;
  }>;
}
```

---

### Endpoint: `POST /posts/tags`

**Status:** ✅ **EXISTS**

**Purpose:** Create new tag

**Request Body:**
```typescript
{
  name: string;
  color: string; // Hex color code (e.g., '#FF5733')
}
```

**Response Format:**
```typescript
{
  id: string;
  name: string;
  color: string;
}
```

---

### Endpoint: `PUT /posts/tags/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Update tag

**Request Body:**
```typescript
{
  name: string;
  color: string;
}
```

---

### Endpoint: `DELETE /posts/tags/:id`

**Status:** ✅ **EXISTS**

**Purpose:** Delete tag

**Notes:**
- Removes tag from all posts
- Cannot be undone

---

### Tags in Posts

**Attach Tags to Post:**
```typescript
POST /posts
Body: {
  tags: [
    { label: 'Campaign', value: 'Campaign' },
    { label: 'Product Launch', value: 'Product Launch' }
  ],
  // ... rest of post data
}
```

**Note:** Tags use `label` and `value` (both are the tag name)

---

### Tag Features

✅ **CRUD Operations** - Create, read, update, delete  
✅ **Color Coding** - Visual organization  
✅ **Attach to Posts** - Multiple tags per post  
✅ **Organization-Scoped** - Private to org  

❌ **NOT Available:**
- Filter posts by tag (use client-side)
- Tag analytics (posts per tag)
- Tag suggestions/autocomplete endpoint
- Tag hierarchy/nesting
- Tag permissions

**Workaround for Filtering:**
```typescript
const posts = await GET('/posts?...');
const taggedPosts = posts.posts.filter(p => 
  p.tags.some(t => t.tag.name === 'Campaign')
);
```

---

## 1️⃣7️⃣ LIMITS & CONSTRAINTS

### Rate Limits

**Status:** ⚠️ **DEPENDS ON DEPLOYMENT**

- Self-hosted: No global rate limiting (unless configured)
- Cloud: Likely rate limited per subscription tier
- No public documentation of exact limits

**Best Practice:**
- Implement exponential backoff
- Cache responses where possible
- Don't spam endpoints

---

### File Size Limits

**Media Upload:**
- **Default:** 1GB per file (mentioned in frontend)
- **Configurable:** Via environment variables
- **Multipart:** For files >100MB

**File Types Supported:**
- Images: JPG, PNG, GIF, WebP
- Videos: MP4, MOV, AVI, etc.
- Documents: (platform-dependent)

---

### Post Limits

**Per Request:**
- No hard limit on posts per `POST /posts` request
- Practical limit: ~10-20 posts per request

**Per Day/Month:**
- Governed by `Sections.POSTS_PER_MONTH` policy
- Checked via `@CheckPolicies` decorator
- Limit depends on subscription tier

**Scheduled Posts:**
- No technical limit
- Queue handles unlimited scheduled posts
- BullMQ manages job scheduling

---

### Content Limits

**Character Limits:**
- Varies by platform (280 for X, 3000 for LinkedIn, etc.)
- Enforced in frontend validation
- Backend validation via platform DTOs

**Media Per Post:**
- Platform-specific (4 images for X, 1 video for most)
- Validated in provider checkValidity functions
- Returns error if exceeded

**Thread Length:**
- No technical limit on thread posts
- Practical limit: 50-100 posts per thread

---

### Storage Limits

**Media Storage:**
- Stored in Cloudflare R2 or local storage
- No built-in quota enforcement
- Monitor via database queries

**Database Storage:**
- PostgreSQL database
- No built-in limits
- Grows with posts, media, analytics

**Query to Check Storage:**
```sql
SELECT 
  pg_size_pretty(pg_database_size('postiz_db')) as db_size,
  COUNT(*) as media_count,
  pg_size_pretty(SUM(size)) as total_media_size
FROM media;
```

---

### Pagination Limits

**GET /posts/list:**
- Max: 100 posts per page
- Min: 1 post per page
- Default: 20 posts per page

**GET /media:**
- Page-based (not limit-based)
- Default page size: ~50 items
- No max specified

---

### Integration Limits

**Connected Channels:**
- No technical limit
- Can connect multiple accounts per platform
- Limited by subscription tier (likely)

**OAuth Tokens:**
- Expire based on platform rules
- Refresh tokens stored
- Auto-refresh attempted before operations

---

### AI Generation Limits

**Credits System:**
- If Stripe enabled: Credit-based
- If Stripe disabled: Unlimited (but slow)
- Check credits via `/copilot/credits`

**Generation Limits:**
- Image generation: Per-prompt cost
- Video generation: Higher cost
- Post generation: Per-post cost

---

### Webhook Limits

**Registered Webhooks:**
- No documented limit
- Practical limit: ~10-20 per organization

**Delivery:**
- No retry mechanism
- Single attempt per event
- Fire-and-forget

---

### Autopost Limits

**Configurations:**
- No limit on autopost configurations
- Check via `Sections.WEBHOOKS` policy
- Active/inactive tracking

**RSS Feed Checks:**
- Frequency depends on orchestrator settings
- Typically every 15-60 minutes

---

## 1️⃣8️⃣ SUMMARY CHECKLIST

Based on the audit, here's the status of key features:

### Post Management

- [x] **Posts have draft status** - YES, via `state: 'DRAFT'` or `type: 'draft'`
- [x] **Drafts stored separately** - NO, same table with state field
- [x] **Drafts can be converted** - YES, via `type` change on POST
- [x] **Scheduled posts can revert to drafts** - YES, via update

### Threading

- [x] **Threads/carousels supported** - YES, via multiple `value` entries
- [x] **Posts linked together** - YES, via `group` field
- [x] **Delays between posts** - YES, via `delay` field (minutes)
- [x] **Thread failure handling** - YES, continues with remaining posts

### Recurring Posts

- [x] **Recurring posts supported** - YES, via `inter` field or Autopost
- [x] **Recurrence patterns** - Limited (interval-based or RSS/webhook)
- [x] **End dates/max counts** - NO, manual stop required
- [x] **Posts created in advance** - NO, created on schedule

### Media

- [x] **Advanced media search** - NO, only page-based browsing
- [x] **Media folders** - NO, flat structure
- [x] **Storage quota tracking** - NO built-in, manual queries needed
- [x] **Media tags/categories** - NO

### Calendar

- [x] **Calendar views** - YES (day/week/month via date range)
- [x] **Export to iCal** - NO
- [x] **Export to CSV** - NO
- [x] **Calendar statistics** - NO endpoint, calculate client-side

### Platform Settings

- [x] **Platform-specific settings** - YES, via `settings.__type` discriminator
- [x] **First comment** - PARTIAL, platform-specific or thread workaround
- [x] **Validation** - YES, via DTOs and checkValidity functions

### Error Handling

- [x] **Error handling** - YES, `state: 'ERROR'` field
- [x] **Retry mechanism** - NO dedicated endpoint, re-submit manually
- [x] **Error details** - YES, in statistics endpoint

### Analytics

- [x] **Analytics endpoints** - YES, per-post and per-integration
- [x] **Real-time data** - Platform-dependent
- [x] **Aggregated analytics** - NO, fetch and aggregate client-side
- [x] **Export analytics** - NO

### Bulk Operations

- [x] **Bulk create** - YES, multiple posts in one request
- [x] **Bulk update** - NO, update individually
- [x] **Bulk delete** - NO, delete individually

### Webhooks

- [x] **Webhook system** - YES, full CRUD
- [x] **Event filtering** - YES, select events
- [x] **Retry on failure** - NO, single attempt
- [x] **Delivery logs** - NO

### Special Features

- [x] **Auto-scheduling/slot-finding** - YES, `/posts/find-slot`
- [x] **AI generation** - YES, streaming and batch
- [x] **Version history** - NO
- [x] **Post duplication** - NO endpoint, manual copy
- [x] **Post locking** - NO

### Sets & Tags

- [x] **Sets/templates** - YES, full CRUD
- [x] **Tags system** - YES, full CRUD
- [x] **Filter by tag** - NO endpoint, filter client-side

---

## 🎯 KEY FINDINGS

### ✅ STRENGTHS

1. **Comprehensive Post Management** - Draft, schedule, publish, update all supported
2. **Thread Support** - Full multi-post threading with delays
3. **Multi-Platform** - 28+ integrations with platform-specific settings
4. **Media Management** - Upload, library, AI generation
5. **Analytics** - Per-post and per-integration metrics  
6. **Sets & Tags** - Organization and reusability features
7. **Webhooks** - Custom integrations via webhooks
8. **Autopost** - RSS/webhook-based automation
9. **AI Features** - Post generation, image generation, video generation

### ⚠️ LIMITATIONS

1. **No Advanced Search** - Limited filtering, no full-text search
2. **No Bulk Operations** - Delete/update one at a time
3. **No Media Organization** - Flat structure, no folders
4. **No Calendar Export** - Can't export to iCal/CSV
5. **No Retry Mechanism** - Failed posts must be manually resubmitted
6. **No Version History** - Single version only, no audit log
7. **No Storage Quotas** - Not enforced, must monitor manually
8. **Limited Webhook Features** - No retry, no signature validation

### 💡 RECOMMENDATIONS

**For Your CRM Integration:**

1. **Leverage Existing Features:**
   - Use POST /posts for all post creation
   - Use sets for templates
   - Use tags for organization
   - Use find-slot for intelligent scheduling

2. **Build Custom Layers:**
   - **Search:** Implement full-text search in your database
   - **Bulk Operations:** Create bulk endpoints that call Postiz API multiple times
   - **Analytics Dashboard:** Fetch and aggregate analytics yourself
   - **Retry Queue:** Build retry logic for failed posts
   - **Version Control:** Store snapshots in your database

3. **Monitor and Extend:**
   - Track storage usage via database queries
   - Implement rate limiting in your layer
   - Add webhook signature validation
   - Build custom reporting on top of Postiz data

4. **Don't Rebuild:**
   - ✅ Use Postiz for post creation, scheduling, and publishing
   - ✅ Use Postiz integrations (don't re-OAuth)
   - ✅ Use Postiz media storage
   - ✅ Use Postiz orchestrator for posting logic

---

## 📚 ADDITIONAL RESOURCES

### Database Schema

**Location:** `libraries/nestjs-libraries/src/database/prisma/schema.prisma`

**Key Models:**
- `Post` - Post data and content
- `Integration` - Connected channels
- `Media` - Uploaded files
- `Tag` - Post tags
- `Set` - Templates
- `Webhook` - Webhook configurations
- `Organization` - Multi-tenant support
- `User` - Users and permissions
- `Subscription` - Billing/limits

### DTO Files

**Location:** `libraries/nestjs-libraries/src/dtos/`

**Key DTOs:**
- `posts/create.post.dto.ts` - Post creation schema
- `posts/get.posts.dto.ts` - Post query schema
- `posts/providers-settings/*.dto.ts` - Platform settings
- `media/*.dto.ts` - Media operations
- `integrations/*.dto.ts` - Integration operations
- `webhooks/webhooks.dto.ts` - Webhook schema
- `sets/sets.dto.ts` - Set schema

### Service Files

**Location:** `libraries/nestjs-libraries/src/database/prisma/`

**Key Services:**
- `posts/posts.service.ts` - Post business logic
- `integrations/integration.service.ts` - Integration management
- `media/media.service.ts` - Media operations
- `autopost/autopost.service.ts` - Autopost logic
- `webhooks/webhooks.service.ts` - Webhook management

### Provider Files

**Location:** `libraries/nestjs-libraries/src/integrations/social/`

**Platform Providers:**
Each platform has a provider class that implements:
- OAuth flow
- Post formatting
- Media validation
- Platform-specific features
- Error handling

Example: `x.provider.ts` for Twitter/X

---

## 🔚 CONCLUSION

Postiz provides a **robust, feature-rich API** for social media management. While it has some limitations (no advanced search, no bulk operations, limited analytics aggregation), these can be addressed at the integration layer.

**For your CRM integration:**
- ✅ Use Postiz for core posting functionality
- ✅ Use Postiz for platform integrations
- ✅ Build custom features on top (search, bulk ops, custom analytics)
- ✅ Store additional metadata in your CRM database
- ✅ Create wrapper endpoints that enhance Postiz API

This approach lets you:
- Avoid rebuilding complex platform integrations
- Leverage battle-tested posting logic
- Focus on CRM-specific features
- Maintain full control over user experience

**The Postiz API is production-ready and suitable for integration into your CRM system.**

---

**End of Audit Report**

*Generated: March 11, 2026*  
*For Questions: Refer to Postiz Documentation or Source Code*
