# Post Creation System - Complete Guide

**Last Updated:** March 11, 2026  
**Project:** Social-Flow (Postiz)  
**Version:** Current

---

## Table of Contents

1. [Overview](#overview)
2. [Frontend Architecture](#frontend-architecture)
3. [Available Features](#available-features)
4. [Backend API Endpoints](#backend-api-endpoints)
5. [State Management](#state-management)
6. [Data Flow](#data-flow)
7. [Calendar Integration](#calendar-integration)
8. [Custom Backend Integration](#custom-backend-integration)
9. [Component Reference](#component-reference)
10. [Development Guide](#development-guide)

---

## Overview

The post creation system in Social-Flow is a comprehensive, enterprise-level solution for managing social media posts across 28+ platforms. It provides a unified interface for creating, scheduling, and managing content with platform-specific customization.

### Key Capabilities

- **Multi-platform posting** to 28+ social networks
- **Rich text editor** with multiple modes (normal, markdown, HTML)
- **Media management** (images, videos up to 1GB)
- **Real-time preview** for each platform
- **Advanced scheduling** with calendar integration
- **Recurring posts** with flexible intervals
- **Thread/carousel support** with delays
- **AI-powered content generation**
- **Tag management** and organization
- **Shortlink tracking** for analytics

---

## Frontend Architecture

### Primary Components Location

```
apps/frontend/src/components/
├── launches/
│   ├── new.post.tsx              # Main "Create Post" button
│   ├── calendar.tsx              # Calendar view component
│   ├── calendar.context.tsx      # Calendar state management
│   ├── repeat.component.tsx      # Recurring post settings
│   └── tags.component.tsx        # Tag management UI
│
├── new-launch/
│   ├── add.edit.modal.tsx        # Main modal wrapper
│   ├── manage.modal.tsx          # Core post management UI
│   ├── editor.tsx                # Rich text editor
│   ├── store.ts                  # Zustand state store
│   ├── picks.socials.component.tsx  # Channel selector
│   └── providers/                # Platform-specific components
│       ├── show.all.providers.tsx   # Provider orchestrator
│       ├── x/x.provider.tsx      # Twitter/X integration
│       ├── linkedin/             # LinkedIn integration
│       ├── facebook/             # Facebook integration
│       ├── instagram/            # Instagram integration
│       └── [28+ platforms...]
│
├── preview/
│   ├── preview.wrapper.tsx       # Preview container
│   ├── comments.components.tsx   # Comments system
│   └── render.preview.date.tsx   # Date rendering
│
└── media/
    ├── media.component.tsx       # Media upload & library
    └── new.uploader.tsx          # Uppy uploader integration
```

---

## Available Features

### 1. Multi-Platform Support (28+ Channels)

**Social Media Platforms:**
- X (Twitter)
- LinkedIn (Personal & Pages)
- Facebook
- Instagram
- Instagram Standalone
- Threads
- TikTok
- Pinterest
- YouTube

**Professional Networks:**
- Dribbble
- Mastodon
- Bluesky
- Warpcast

**Blogging Platforms:**
- Medium
- Dev.to
- Hashnode
- WordPress

**Communication Channels:**
- Discord
- Slack
- Telegram

**Streaming Platforms:**
- Twitch
- Kick

**Community Platforms:**
- Reddit
- Lemmy
- Nostr
- Skool
- Whop

**Other:**
- Google My Business (GMB)
- VK
- Listmonk
- Moltbook

**Provider Configuration:**
Each platform has its own provider component with:
- Custom settings interface
- Platform-specific validation
- Character limits
- Media requirements
- Preview rendering

---

### 2. Content Editor Features

#### Rich Text Formatting

**Text Styling:**
- **Bold** (`Cmd/Ctrl + B`)
- **Underline** (`Cmd/Ctrl + U`)
- Bullet lists
- Headings (multiple levels)
- Hyperlinks
- Mentions (@username)

**Implementation:**
Built with TipTap (ProseMirror-based editor)

```typescript
// Available extensions
- Document
- Bold
- Text
- Paragraph
- Underline
- History (Undo/Redo)
- BulletList
- ListItem
- Heading
- Mention
- Link
- Placeholder
```

#### Media Upload System

**Supported Formats:**
- Images (JPG, PNG, GIF, WebP)
- Videos (MP4, MOV, etc.)
- Maximum file size: **1GB per file**

**Upload Methods:**
1. **Drag & Drop** - Drop files anywhere in the editor
2. **Paste** - Paste images from clipboard
3. **Browse** - Click to select files
4. **URL Import** - Import from external URLs
5. **Media Library** - Select from previously uploaded files
6. **AI Generation** - Generate images/videos with AI
7. **Third-Party** - Import from external services

**Media Features:**
- Multiple media per post
- Sortable (drag & drop to reorder)
- Alt text for accessibility
- Video thumbnail selection
- Thumbnail timestamp selection
- Per-platform media settings
- Preview before posting

**Technical Details:**
```typescript
// Max upload size constant
const MAX_UPLOAD_SIZE = 1024 * 1024 * 1024; // 1 GB

// Media object structure
interface Media {
  id: string;
  path: string;
  thumbnail?: string;
  thumbnailTimestamp?: number;
  alt?: string;
}
```

#### Emoji Picker

- Built-in emoji selector
- Theme support (light/dark)
- Search functionality
- Category-based browsing
- Quick access to recently used

#### Post Delays

For thread/carousel posts:
- Set delay between posts (in minutes)
- Visual delay indicator
- Prevents platform rate limiting
- Configurable per post in thread

#### Editor Modes

**Four editing modes available:**

1. **Normal** (Default)
   - Rich text WYSIWYG editor
   - Visual formatting
   - Best for most users

2. **Markdown**
   - Markdown syntax support
   - Plain text with formatting
   - For technical users

3. **HTML**
   - Raw HTML editing
   - Maximum control
   - For advanced users

4. **None**
   - Plain text only
   - No formatting
   - Fastest input

**Mode Switching:**
Users can switch modes mid-creation (content converts automatically)

---

### 3. Preview System

#### Real-time Platform Previews

**Features:**
- Live preview as you type
- Platform-specific rendering
- Character counter with weighted length (for platforms like X)
- Media preview with platform layout
- Warning indicators for issues
- Error messages for invalid content

**Platform-Specific Validation:**

Example (X/Twitter):
```typescript
{
  maximumCharacters: premium ? 4000 : 280,
  minimumCharacters: 0,
  postComment: PostComment.POST,
  checkValidity: async (posts, settings, additionalSettings) => {
    // Max 4 images
    if (posts?.some((p) => (p?.length ?? 0) > 4)) {
      return 'Maximum 4 pictures in a post';
    }
    // Max 1 video
    if (posts?.some((p) => 
      p?.some((m) => m?.path?.includes('mp4')) && 
      (p?.length ?? 0) > 1
    )) {
      return 'Maximum 1 video per post';
    }
    // Video duration check
    // ... duration validation logic
  }
}
```

**Character Counting:**
- Simple length for most platforms
- Weighted length for X (emojis, URLs count differently)
- Real-time updates
- Visual warnings when approaching limit
- Error state when limit exceeded

**Preview Components:**
Located in `/apps/frontend/src/components/preview/`
- Platform-specific preview layouts
- Responsive design
- Accurate representation of final post

---

### 4. Scheduling & Calendar Integration

#### Calendar Views

**Multiple View Options:**

1. **Day View**
   - Hourly breakdown
   - Detailed post information
   - Easy time slot management

2. **Week View** (Default)
   - 7-day overview
   - Posts organized by day/time
   - Drag & drop between days

3. **Month View**
   - 30+ days at a glance
   - Post density visualization
   - Quick navigation

4. **List View**
   - Paginated post list
   - 100 posts per page
   - Filter and search
   - Bulk actions

**View Persistence:**
- Saved in cookies
- URL parameters for sharing
- Maintains state across sessions

#### Auto-Slot Finding

**Intelligent Scheduling:**
```typescript
// Backend endpoint
GET /posts/find-slot
Response: { date: "2026-03-11T14:00:00.000Z" }

// Integration-specific
GET /posts/find-slot/:integrationId
```

**Algorithm:**
- Considers existing posts
- Respects platform posting times
- Avoids conflicts
- Smart distribution

#### Drag & Drop Functionality

**React DnD Integration:**
- Drag posts between time slots
- Visual feedback during drag
- Drop validation
- Automatic save on drop
- Undo capability

**Implementation:**
```typescript
const [{ isDragging }, drag] = useDrag({
  type: 'post',
  item: { id: post.id, group: post.group },
  collect: (monitor) => ({
    isDragging: monitor.isDragging(),
  }),
});

const [{ isOver }, drop] = useDrop({
  accept: 'post',
  drop: (item) => handleDrop(item, newDate),
  collect: (monitor) => ({
    isOver: monitor.isOver(),
  }),
});
```

#### Date & Time Picker

**Features:**
- Date selection with calendar widget
- Time selection (hour/minute)
- Timezone support
- Localization (multiple date formats)
- Quick selection presets:
  - Next available slot
  - Same time tomorrow
  - Same time next week
  - Custom date/time

**Supported Languages:**
- English, Hebrew, Russian, Chinese
- French, Spanish, Portuguese, German
- Italian, Japanese, Korean, Arabic
- Turkish, Vietnamese

**Dayjs Integration:**
```javascript
import dayjs from 'dayjs';
import 'dayjs/locale/[language]';
import localizedFormat from 'dayjs/plugin/localizedFormat';
import isSameOrAfter from 'dayjs/plugin/isSameOrAfter';
import isSameOrBefore from 'dayjs/plugin/isSameOrBefore';
```

---

### 5. Advanced Post Options

#### Multi-Post Threading/Carousels

**Thread Creation:**
- Add multiple posts in sequence
- Set delays between posts (minutes)
- Reorder posts (up/down arrows)
- Delete individual posts
- Preview entire thread
- Platform-specific threading rules

**Thread Settings:**
- Global content (shared across all platforms)
- Platform-specific overrides
- Delay configuration per post
- Character limit per thread post

**Visual Editor:**
```
┌─────────────────────┐
│ Post 1              │
│ "First tweet..."    │
│ [Delay: 5 min]      │
└─────────────────────┘
         ↓
┌─────────────────────┐
│ Post 2              │
│ "Second tweet..."   │
│ [Delay: 5 min]      │
└─────────────────────┘
         ↓
┌─────────────────────┐
│ Post 3              │
│ "Final tweet..."    │
└─────────────────────┘
```

#### Post Action Buttons

**Available Actions:**

1. **Save as Draft**
   - Save without scheduling
   - Edit later
   - No publication date
   - Stored in drafts section

2. **Schedule**
   - Add to calendar
   - Set specific date/time
   - Queue for publication
   - Automatic posting at scheduled time

3. **Post Now**
   - Immediate publication
   - Bypasses schedule
   - Confirmation dialog
   - Real-time posting

4. **Update**
   - Modify existing post
   - For already scheduled/published posts
   - Options:
     - Update details only
     - Republish (create new post)
   - Version tracking

5. **Delete Post**
   - Remove from calendar
   - Confirmation required
   - Cannot be undone
   - Removes from all networks

**Button States:**
- Disabled when no channels selected
- Loading state during submission
- Locked state (prevent accidental edits)
- Success/error feedback

#### Recurring Posts

**Repeat Intervals:**
```typescript
const repeatOptions = [
  { value: 1, label: 'Day' },
  { value: 2, label: 'Two Days' },
  { value: 3, label: 'Three Days' },
  { value: 4, label: 'Four Days' },
  { value: 5, label: 'Five Days' },
  { value: 6, label: 'Six Days' },
  { value: 7, label: 'Week' },
  { value: 14, label: 'Two Weeks' },
  { value: 30, label: 'Month' },
];
```

**Recurring Post Features:**
- Set once, post multiple times
- Automatic rescheduling
- Edit all future occurrences
- Stop recurrence anytime
- Visual indicator in calendar
- Smart scheduling (respects weekends, etc.)

**Use Cases:**
- Daily tips/quotes
- Weekly updates
- Monthly reports
- Seasonal campaigns

#### Tags System

**Tag Features:**
- **Create** custom tags
- **Color-coded** for visual organization
- **Autocomplete** when typing
- **Filter** posts by tags
- **Bulk apply** to multiple posts
- **Analytics** by tag
- **Export** posts by tag

**Tag Structure:**
```typescript
interface Tag {
  id: string;
  name: string;
  color: string;
  organizationId: string;
}
```

**Tag Management:**
```typescript
// API Endpoints
GET    /posts/tags        // List all tags
POST   /posts/tags        // Create new tag
PUT    /posts/tags/:id    // Edit tag
DELETE /posts/tags/:id    // Delete tag
```

**Tag Colors:**
- Customizable color picker
- Predefined palette
- Hex/RGB support
- Visual distinction in UI

**Tag Usage:**
- Organize by campaign
- Track content types
- Client/project separation
- Performance analysis

#### Sets/Templates

**Sets System:**
- Save post configurations as reusable templates
- Include:
  - Content structure
  - Selected channels
  - Media placeholders
  - Settings per platform
- Quick start for repetitive workflows
- Share sets with team members

**Set Selection:**
Modal appears on post creation:
```
┌──────────────────────────┐
│  Select a Set            │
├──────────────────────────┤
│  □ Morning Routine       │
│  □ Product Launch        │
│  □ Weekly Update         │
│  □ Event Announcement    │
├──────────────────────────┤
│  [Continue Without Set]  │
└──────────────────────────┘
```

---

### 6. Channel-Specific Settings

Each platform has unique requirements and options. Settings appear in a dedicated panel when channels are selected.

#### Example: X (Twitter) Settings

```typescript
interface XSettings {
  who_can_reply_post: 
    | 'everyone' 
    | 'following' 
    | 'mentionedUsers'
    | 'subscribers'
    | 'verified';
  
  community?: string; // URL to community
}
```

**Who Can Reply Options:**
- Everyone
- Accounts you follow
- Mentioned accounts only
- Subscribers only
- Verified accounts only

**Community Posting:**
- Post to specific X community
- Provide community URL
- Example: `https://x.com/i/communities/1493446837214187523`

**Premium Features Detection:**
- Auto-detect verified/premium account
- Adjust character limits (280 → 4000)
- Enable premium-only features
- Video length extension

**Media Validation:**
- Max 4 images per post
- Max 1 video per post
- Video duration: ≤140s (standard) or unlimited (premium)
- Automatic validation on preview

#### Example: LinkedIn Settings

- Post type (Article, Post, Poll)
- Visibility (Public, Connections only)
- Comments enabled/disabled
- Profile vs Page posting
- Hashtag suggestions

#### Example: Instagram Settings

- Collaborators selection
- Location tagging
- First comment (call-to-action)
- Alt text for accessibility
- Aspect ratio selection
- Shopping product tags

#### Example: YouTube Settings

- Video title (max 100 chars)
- Description (max 5000 chars)
- Category selection
- Visibility (Public, Unlisted, Private, Scheduled)
- Age restriction
- Comments enabled/disabled
- Thumbnail selection
- Playlist assignment
- Tags (keywords)
- Language selection
- Recording date

#### Common Settings Across Platforms

Most platforms support:
- Post visibility/privacy
- Comment controls
- Location/venue tagging
- Collaborator/mention management
- Hashtag/keyword optimization
- Accessibility features (alt text, captions)

**Settings Panel UI:**
```
┌────────────────────────────┐
│  ⚙️ Channel Settings       │
├────────────────────────────┤
│  ┌──────────────────────┐  │
│  │ Twitter (X)          │▼ │
│  ├──────────────────────┤  │
│  │ [X Settings]         │  │
│  └──────────────────────┘  │
│                            │
│  ┌──────────────────────┐  │
│  │ LinkedIn             │▶ │
│  └──────────────────────┘  │
│                            │
│  ┌──────────────────────┐  │
│  │ Instagram            │▶ │
│  └──────────────────────┘  │
└────────────────────────────┘
```

---

### 7. Media Management

#### Media Upload Interface

**Upload Component Features:**
- Uppy-based uploader
- Dashboard view
- Progress indicators
- Error handling
- Resume uploads
- Multiple simultaneous uploads

**Media Library:**
```
┌─────────────────────────────────────────┐
│  📁 Media Library                       │
├─────────────────────────────────────────┤
│  [🖼️]  [🖼️]  [🎥]  [🖼️]  [🖼️]  [🎥]  │
│  [🖼️]  [🖼️]  [🖼️]  [🎥]  [🖼️]  [🖼️]  │
│  [🎥]  [🖼️]  [🖼️]  [🖼️]  [🎥]  [🖼️]  │
├─────────────────────────────────────────┤
│  ◀ 1  2  3 ... 12 ▶                     │
└─────────────────────────────────────────┘
```

**Pagination:**
- Navigate through pages
- Configurable items per page
- Jump to specific page
- First/last page quick access

**Media Organization:**
- **Sorting:** Drag & drop to reorder
- **Filtering:** By type, date, size
- **Search:** By filename or metadata
- **Folders:** Organize into directories
- **Tags:** Apply tags to media

**Media Settings:**
```typescript
interface MediaSettings {
  alt?: string;              // Alt text
  thumbnail?: string;        // Video thumbnail URL
  thumbnailTimestamp?: number; // Timestamp for thumbnail
  orderIndex?: number;       // Display order
  platformSettings?: {       // Platform-specific
    [platform: string]: any;
  };
}
```

**Per-Media Actions:**
- **Edit:** Crop, resize, filters
- **Replace:** Swap with different file
- **Delete:** Remove from library
- **Settings:** Configure display options
- **Copy URL:** Get direct link
- **Download:** Save locally

#### AI-Generated Media

**AI Image Generation:**
- Text-to-image prompts
- Style selection
- Resolution options
- Multiple variations
- Direct upload to library

**AI Video Generation:**
- Script-to-video
- Template-based
- Auto-captioning
- Background music

**Integration:**
Connected to AI services via settings

#### Third-Party Media

**Import Sources:**
- Unsplash (stock photos)
- Giphy (GIFs)
- Custom integrations
- URL import

**Third-Party Features:**
- Search directly in UI
- Preview before import
- Automatic attribution
- License information

#### Video Features

**Video Thumbnail Selection:**
```typescript
// VideoFrame component usage
<VideoFrame
  url={videoUrl}
  onTimestampSelect={(timestamp) => {
    setThumbnailTimestamp(timestamp);
  }}
/>
```

**Video Controls:**
- Scrub through video
- Select keyframe for thumbnail
- Auto-generate at specific time
- Upload custom thumbnail

**Video Validation:**
- Duration limits (platform-specific)
- Format compatibility check
- Size validation
- Resolution requirements

---

### 8. Shortlink Integration

**Automatic URL Detection:**
- Scans post content for URLs
- Identifies linkable content
- Suggests shortening

**Shortlink Preferences:**
```typescript
type ShortlinkPreference = 'YES' | 'NO' | 'ASK';
```

**User Options:**
- **YES:** Always shortlink (automatic)
- **ASK:** Prompt on each post (default)
- **NO:** Never shortlink

**Benefits:**
- Click tracking
- Analytics integration
- Cleaner appearance
- Character savings

**Shortlink Dialog:**
```
┌──────────────────────────────────────┐
│  Shortlink URLs?                     │
├──────────────────────────────────────┤
│  We found URLs in your post.         │
│  Creating shortlinks lets you track  │
│  clicks and engagement.               │
│                                      │
│  [Cancel]  [Yes, shortlink it!]     │
└──────────────────────────────────────┘
```

**API Endpoint:**
```typescript
POST /posts/should-shortlink
Body: { messages: string[] }
Response: { ask: boolean }
```

---

### 9. AI Assistant (Copilot)

**CopilotKit Integration:**

**Capabilities:**
- Refine social media posts
- Add/remove posts in thread
- Modify content tone
- Platform optimization recommendations
- Content suggestions
- Grammar and style improvements

**Assistant Panel:**
```
┌────────────────────────────┐
│  🤖 Your Assistant         │
├────────────────────────────┤
│  Hi! I can help you to     │
│  refine your social media  │
│  posts.                    │
│                            │
│  [Type your request...]    │
│                            │
└────────────────────────────┘
```

**Custom Instructions:**
```typescript
instructions: `
You are an assistant that helps user schedule social media posts.
Here are the things you can do:
- Add a new comment/post to the list
- Delete a comment/post
- Add content to posts
- Activate or deactivate posts

Post content can be added using addPostContentFor{num} function.
After using addPostFor{num} it creates new addPostContentFor{num+1}.
`
```

**Usage Examples:**
- "Make this more professional"
- "Add emojis to engage audience"
- "Split this into a 3-post thread"
- "Optimize for LinkedIn"
- "Add relevant hashtags"

**Settings:**
- Language preference
- Tone style (casual, professional, enthusiastic)
- Platform focus
- Hit Escape to close
- Click outside to close

---

### 10. Comments System

**Internal Comments:**
- Team collaboration
- Notes on posts
- Feedback system
- @mentions for team members

**Public Comments:**
- Preview post publicly
- Allow comments before posting
- Test content with audience
- Requires login to comment

**Comment Component:**
```typescript
interface Comment {
  id: string;
  postId: string;
  userId: string;
  content: string;
  createdAt: Date;
}
```

**Features:**
- Real-time updates
- User avatars
- Threaded replies (future)
- Moderation tools
- Export comments

---

## Backend API Endpoints

### Post Management Endpoints

#### Create Post
```typescript
POST /posts
Headers: { Authorization: 'Bearer <token>' }
Body: {
  type: 'schedule' | 'now' | 'draft' | 'update';
  date: string; // ISO 8601 format
  tags: Array<{label: string, value: string}>;
  shortLink: boolean;
  inter?: number; // Repeat interval in days
  posts: Array<{
    integration: { id: string };
    group: string;
    settings: Record<string, any>;
    value: Array<{
      id?: string;
      content: string;
      delay: number;
      image: Array<{
        id: string;
        path: string;
        alt?: string;
        thumbnail?: string;
        thumbnailTimestamp?: number;
      }>;
    }>;
  }>;
}
Response: { success: boolean; groupId: string }
```

#### Get Posts (Calendar View)
```typescript
GET /posts?display={view}&startDate={date}&endDate={date}&customer={id}
Response: {
  posts: Post[];
  integrations: Integration[];
  sets: Set[];
  comments: CommentSummary[];
}
```

#### Get Posts (List View)
```typescript
GET /posts/list?page={num}&limit={num}&customer={id}
Response: {
  posts: Post[];
  total: number;
  pages: number;
  currentPage: number;
}
```

#### Get Single Post
```typescript
GET /posts/:id
Response: Post & {
  integration: Integration;
  tags: Tag[];
}
```

#### Get Posts by Group
```typescript
GET /posts/group/:group
Response: Post[]
```

#### Change Post Date
```typescript
PUT /posts/:id/date
Body: {
  date: string; // ISO 8601
  action: 'schedule' | 'update';
}
Response: { success: boolean }
```

#### Delete Post
```typescript
DELETE /posts/:group
Response: { success: boolean }
```

---

### Utility Endpoints

#### Find Available Time Slot
```typescript
GET /posts/find-slot
Response: { date: string } // ISO 8601
```

#### Find Slot for Specific Integration
```typescript
GET /posts/find-slot/:integrationId
Response: { date: string }
```

#### Check Shortlink Requirement
```typescript
POST /posts/should-shortlink
Body: { messages: string[] }
Response: { ask: boolean }
```

#### Separate Long Posts
```typescript
POST /posts/separate-posts
Body: {
  content: string;
  len: number; // Character limit
}
Response: { posts: string[] }
```

---

### Tag Endpoints

#### Get All Tags
```typescript
GET /posts/tags
Response: { tags: Tag[] }
```

#### Create Tag
```typescript
POST /posts/tags
Body: {
  name: string;
  color: string; // Hex color
}
Response: Tag
```

#### Edit Tag
```typescript
PUT /posts/tags/:id
Body: {
  name: string;
  color: string;
}
Response: Tag
```

#### Delete Tag
```typescript
DELETE /posts/tags/:id
Response: { success: boolean }
```

---

### Statistics & Analytics

#### Get Post Statistics
```typescript
GET /posts/:id/statistics
Response: {
  views: number;
  likes: number;
  comments: number;
  shares: number;
  clicks: number;
  engagement: number;
  reach: number;
}
```

#### Get Missing Content
```typescript
GET /posts/:id/missing
Response: {
  missingFields: string[];
  requiredActions: string[];
}
```

#### Update Release ID
```typescript
PUT /posts/:id/release-id
Body: { releaseId: string }
Response: { success: boolean }
```

---

### Comments Endpoints

#### Create Comment
```typescript
POST /posts/:id/comments
Body: { comment: string }
Response: Comment
```

#### Get Comments (Public)
```typescript
GET /public/posts/:id/comments
Response: { comments: Comment[] }
```

---

### AI Generation Endpoints

#### Generate Posts (Streaming)
```typescript
POST /posts/generator
Body: {
  prompt: string;
  platforms: string[];
  count: number;
  tone?: string;
}
Response: Server-Sent Events (SSE)
Content-Type: application/json; charset=utf-8
Event stream: { type: string; data: any }\n
```

#### Generate Draft Posts
```typescript
POST /posts/generator/draft
Body: {
  prompt: string;
  platforms: string[];
  count: number;
}
Response: { posts: Post[] }
```

---

### Integration Endpoints

#### Get Integrations
```typescript
GET /integrations
Response: Integration[]
```

#### Refresh Integration
```typescript
POST /integrations/:id/refresh
Response: { success: boolean }
```

---

## State Management

### Zustand Store Structure

The post creation system uses Zustand for state management. The store is located at:
`apps/frontend/src/components/new-launch/store.ts`

#### Store Interface

```typescript
interface StoreState {
  // Editor Configuration
  editor: undefined | 'none' | 'normal' | 'markdown' | 'html';
  loaded: boolean;
  dummy: boolean; // Preview mode
  
  // Post Timing
  date: dayjs.Dayjs;
  repeater?: number; // Days interval for recurring
  
  // Content Storage
  global: Values[]; // Content shared across all channels
  internal: Internal[]; // Channel-specific content
  
  // Channel Selection
  integrations: Integrations[]; // Available integrations
  selectedIntegrations: SelectedIntegrations[]; // Selected for this post
  current: string; // Currently active channel ID
  
  // Post Features
  tags: Tag[];
  comments: boolean | 'no-media';
  totalChars: number;
  chars: Record<string, number>; // Per-channel character count
  postComment: PostComment; // Comment settings
  
  // UI State
  tab: 0 | 1; // Active tab
  hide: boolean;
  locked: boolean; // Prevent editing
  activateExitButton: boolean; // Warn on exit
  isCreateSet: boolean; // Creating template vs post
  
  // Actions: Content Management
  setGlobalValueText: (index: number, content: string) => void;
  setInternalValueText: (integrationId: string, index: number, content: string) => void;
  addGlobalValue: (index: number, value: Values[]) => void;
  addInternalValue: (index: number, integrationId: string, value: Values[]) => void;
  setGlobalValue: (value: Values[]) => void;
  setInternalValue: (integrationId: string, value: Values[]) => void;
  deleteGlobalValue: (index: number) => void;
  deleteInternalValue: (integrationId: string, index: number) => void;
  
  // Actions: Media Management
  setGlobalValueMedia: (index: number, media: Media[]) => void;
  setInternalValueMedia: (integrationId: string, index: number, media: Media[]) => void;
  addGlobalValueMedia: (index: number, media: Media[]) => void;
  addInternalValueMedia: (integrationId: string, index: number, media: Media[]) => void;
  appendGlobalValueMedia: (index: number, media: Media[]) => void;
  appendInternalValueMedia: (integrationId: string, index: number, media: Media[]) => void;
  removeGlobalValueMedia: (index: number, mediaIndex: number) => void;
  removeInternalValueMedia: (integrationId: string, index: number, mediaIndex: number) => void;
  
  // Actions: Post Ordering
  changeOrderGlobal: (index: number, direction: 'up' | 'down') => void;
  changeOrderInternal: (integrationId: string, index: number, direction: 'up' | 'down') => void;
  
  // Actions: Delay Management
  setGlobalDelay: (index: number, minutes: number) => void;
  setInternalDelay: (integrationId: string, index: number, minutes: number) => void;
  
  // Actions: Channel Management
  setAllIntegrations: (integrations: Integrations[]) => void;
  setCurrent: (current: string) => void;
  addOrRemoveSelectedIntegration: (integration: Integrations, settings: any) => void;
  setSelectedIntegrations: (params: SelectedIntegrations[]) => void;
  addRemoveInternal: (integrationId: string) => void;
  
  // Actions: Configuration
  setDate: (date: dayjs.Dayjs) => void;
  setRepeater: (repeater: number) => void;
  setTags: (tags: Tag[]) => void;
  setTab: (tab: 0 | 1) => void;
  setHide: (hide: boolean) => void;
  setLocked: (locked: boolean) => void;
  setIsCreateSet: (isCreateSet: boolean) => void;
  setTotalChars: (totalChars: number) => void;
  setActivateExitButton: (activate: boolean) => void;
  setDummy: (dummy: boolean) => void;
  setEditor: (editor: 'none' | 'normal' | 'markdown' | 'html') => void;
  setLoaded: (loaded: boolean) => void;
  setChars: (id: string, chars: number) => void;
  setComments: (comments: boolean | 'no-media') => void;
  setPostComment: (postComment: PostComment) => void;
  
  // System
  reset: () => void; // Reset to initial state
}
```

#### Data Structures

**Values Interface:**
```typescript
interface Values {
  id: string; // Unique identifier
  content: string; // HTML content
  delay: number; // Minutes to wait before this post
  media: Media[]; // Attached media files
}
```

**Media Interface:**
```typescript
interface Media {
  id: string;
  path: string; // URL or file path
  thumbnail?: string; // Video thumbnail URL
  thumbnailTimestamp?: number; // Timestamp for thumbnail
  alt?: string; // Accessibility text
}
```

**Internal Interface:**
```typescript
interface Internal {
  integration: Integrations; // Platform details
  integrationValue: Values[]; // Platform-specific content
}
```

**SelectedIntegrations Interface:**
```typescript
interface SelectedIntegrations {
  settings: any; // Platform-specific settings
  integration: Integrations;
  ref?: RefObject<any>; // React ref for provider component
}
```

**Tag Interface:**
```typescript
interface Tag {
  label: string;
  value: string;
}
```

---

### Calendar Context

The calendar context provides state for the main calendar view.
Located at: `apps/frontend/src/components/launches/calendar.context.tsx`

#### Calendar Context Interface

```typescript
interface CalendarContextType {
  // Date Range
  startDate: string; // YYYY-MM-DD
  endDate: string; // YYYY-MM-DD
  display: 'week' | 'month' | 'day' | 'list';
  
  // Data
  posts: Post[];
  integrations: Integrations[];
  sets: Set[];
  comments: CommentSummary[];
  trendings: string[];
  signature: any;
  
  // List View
  listPosts: Post[];
  listPage: number;
  listTotalPages: number;
  
  // Filters
  customer: string | null;
  
  // State
  loading: boolean;
  
  // Actions
  setFilters: (filters: Filters) => void;
  reloadCalendarView: () => void;
  changeDate: (id: string, date: dayjs.Dayjs) => void;
  setListPage: (page: number) => void;
}
```

**Usage Example:**
```typescript
import { useCalendar } from '@gitroom/frontend/components/launches/calendar.context';

const MyComponent = () => {
  const { 
    posts, 
    integrations, 
    reloadCalendarView,
    setFilters 
  } = useCalendar();
  
  // Use calendar data
};
```

---

## Data Flow

### Complete Post Creation Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. USER CLICKS "CREATE POST" BUTTON                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 2. FRONTEND: new.post.tsx                                   │
│    - Triggers createAPost()                                 │
│    - Makes API call to find available slot                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 3. BACKEND: GET /posts/find-slot                            │
│    - Analyzes existing posts                                │
│    - Finds next suitable time slot                          │
│    - Returns: { date: "2026-03-11T14:00:00.000Z" }          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 4. FRONTEND: Set Selection Modal (Optional)                 │
│    - Show available sets/templates                          │
│    - User selects set or continues without                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 5. FRONTEND: AddEditModal Opens                             │
│    - Initialize Zustand store with:                         │
│      • Available integrations                               │
│      • Scheduled date/time                                  │
│      • Set content (if selected)                            │
│      • Empty values otherwise                               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 6. FRONTEND: ManageModal Renders                            │
│    ├─ Left Panel: Editor & Channel Selection                │
│    │   ├─ PicksSocialsComponent                             │
│    │   │  └─ User selects platforms (checkboxes)            │
│    │   ├─ EditorWrapper                                     │
│    │   │  ├─ TipTap rich text editor                        │
│    │   │  ├─ MultiMediaComponent (upload)                   │
│    │   │  ├─ EmojiPicker                                    │
│    │   │  ├─ Post thread management                         │
│    │   │  └─ Delay settings                                 │
│    │   └─ SelectCurrent (channel-specific settings)         │
│    │       └─ Platform-specific settings panels             │
│    │                                                         │
│    └─ Right Panel: Live Previews                            │
│        └─ ShowAllProviders                                  │
│            ├─ XProvider & XPreview                          │
│            ├─ LinkedInProvider & LinkedInPreview            │
│            ├─ FacebookProvider & FacebookPreview            │
│            └─ ... (for each selected platform)              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 7. USER INTERACTION: Content Creation                       │
│    - Types text (stored in Zustand)                         │
│    - Uploads media (Uppy → backend → URL returned)          │
│    - Selects emojis                                         │
│    - Adds thread posts                                      │
│    - Configures delays                                      │
│    - Sets platform-specific options                         │
│    → All changes update Zustand store                       │
│    → Store triggers preview updates                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 8. REAL-TIME VALIDATION                                     │
│    For each selected platform:                              │
│    ├─ Check character count (weighted for X)                │
│    ├─ Validate media requirements                           │
│    │  • Image count limits                                  │
│    │  • Video count limits                                  │
│    │  • Video duration (platform-specific)                  │
│    │  • File size limits                                    │
│    ├─ Check required fields                                 │
│    ├─ Validate platform-specific rules                      │
│    └─ Display warnings/errors in preview                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 9. USER CONFIGURES POST OPTIONS                             │
│    ├─ DatePicker: Select publish date/time                  │
│    ├─ TagsComponent: Add/select tags                        │
│    ├─ RepeatComponent: Set recurring interval (optional)    │
│    └─ Footer actions displayed                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 10. USER CLICKS ACTION BUTTON                               │
│     Options:                                                │
│     • Save as Draft                                         │
│     • Schedule                                              │
│     • Post Now                                              │
│     • Update (if editing existing)                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 11. FRONTEND VALIDATION                                     │
│     - Call ref.current.checkAllValid()                      │
│     - Collect validation results from all providers         │
│     - Check for:                                            │
│       • Empty posts (no content or media)                   │
│       • Invalid settings                                    │
│       • Exceeded character limits                           │
│       • Platform-specific errors                            │
│     - Display errors if any found                           │
│     - Highlight problematic provider                        │
│     - STOP if validation fails                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 12. SHORTLINK CHECK (if not draft)                          │
│     POST /posts/should-shortlink                            │
│     Body: { messages: [all post contents] }                 │
│     Response: { ask: boolean }                              │
│     │                                                        │
│     If ask === true:                                        │
│     ├─ User preference === 'YES' → Auto-shortlink           │
│     ├─ User preference === 'ASK' → Show dialog              │
│     └─ User preference === 'NO' → Skip                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 13. BUILD POST PAYLOAD                                      │
│     Construct request body:                                 │
│     {                                                        │
│       type: 'schedule' | 'now' | 'draft' | 'update',        │
│       date: date.utc().format('YYYY-MM-DDTHH:mm:ss'),       │
│       tags: [{ label: 'string', value: 'string' }],         │
│       shortLink: boolean,                                   │
│       inter?: number, // repeat interval                    │
│       posts: [                                              │
│         {                                                   │
│           integration: { id: 'platform-id' },               │
│           group: 'unique-group-id', // same for all         │
│           settings: { /* platform-specific */ },            │
│           value: [                                          │
│             {                                               │
│               id?: 'post-id', // if updating                │
│               content: 'HTML content',                      │
│               delay: 0, // minutes                          │
│               image: [                                      │
│                 {                                           │
│                   id: 'media-id',                           │
│                   path: 'https://url',                      │
│                   alt: 'description',                       │
│                   thumbnail: 'https://thumbnail',           │
│                   thumbnailTimestamp: 5.2                   │
│                 }                                           │
│               ]                                             │
│             }                                               │
│           ]                                                 │
│         }                                                   │
│       ]                                                     │
│     }                                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 14. SEND TO BACKEND                                         │
│     POST /posts                                             │
│     Headers: { Authorization: 'Bearer <token>' }            │
│     Body: [payload from step 13]                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 15. BACKEND PROCESSING                                      │
│     PostsController → PostsService                          │
│     ├─ Validate request                                     │
│     ├─ Check permissions (posts per month limit)            │
│     ├─ Map platform-specific DTOs                           │
│     ├─ Create database records:                             │
│     │  ├─ Post entries (one per platform)                   │
│     │  ├─ Media associations                                │
│     │  ├─ Tag associations                                  │
│     │  └─ Recurring settings (if applicable)                │
│     ├─ Queue for processing:                                │
│     │  └─ Add to Redis/BullMQ                               │
│     │     ├─ Schedule job for publish time                  │
│     │     ├─ If 'now': immediate job                        │
│     │     └─ If recurring: setup cron pattern               │
│     └─ Return success response                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 16. FRONTEND SUCCESS HANDLING                               │
│     - Close modal                                           │
│     - Show success toast                                    │
│     - Call mutate() / reloadCalendarView()                  │
│     - Update calendar display                               │
│     - Reset Zustand store                                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│ 17. CALENDAR REFRESH                                        │
│     - SWR cache invalidation                                │
│     - Refetch: GET /posts?[params]                          │
│     - Backend returns updated post list                     │
│     - Calendar re-renders with new post                     │
│     - Post appears at scheduled time slot                   │
└─────────────────────────────────────────────────────────────┘
```

### State Updates During Creation

**Initial State:**
```typescript
{
  editor: 'normal',
  date: dayjs(),
  global: [{ id: 'abc123', content: '', delay: 0, media: [] }],
  internal: [],
  selectedIntegrations: [],
  current: 'global',
  tags: [],
  repeater: undefined,
  // ... other defaults
}
```

**After Selecting Platform (e.g., X):**
```typescript
{
  // ... previous state
  selectedIntegrations: [
    {
      integration: { id: 'x-123', identifier: 'x', name: 'Twitter' },
      settings: { who_can_reply_post: 'everyone' },
      ref: React.createRef()
    }
  ],
  internal: [
    {
      integration: { id: 'x-123', ... },
      integrationValue: [{ id: 'xyz789', content: '', delay: 0, media: [] }]
    }
  ]
}
```

**After Adding Content:**
```typescript
{
  // ... previous state
  global: [
    {
      id: 'abc123',
      content: '<p>Check out this amazing product!</p>',
      delay: 0,
      media: [
        {
          id: 'media-001',
          path: 'https://cdn.example.com/product.jpg',
          alt: 'Product showcase'
        }
      ]
    }
  ]
}
```

**After Adding Thread Post:**
```typescript
{
  // ... previous state
  global: [
    {
      id: 'abc123',
      content: '<p>Check out this amazing product!</p>',
      delay: 0,
      media: [...]
    },
    {
      id: 'def456',
      content: '<p>Available now with 20% off!</p>',
      delay: 5, // 5 minutes after first post
      media: []
    }
  ]
}
```

---

## Calendar Integration

### Calendar Architecture

The calendar system provides multiple views for visualizing and managing scheduled posts.

#### View Types

**1. Week View (Default)**
```
┌──────────────────────────────────────────────────────────────┐
│  Mon 3/10  │  Tue 3/11  │  Wed 3/12  │  Thu 3/13  │  Fri 3/14 │
├────────────┼────────────┼────────────┼────────────┼───────────┤
│ 09:00      │            │            │ 09:00      │           │
│ [Post A]   │            │            │ [Post D]   │           │
│            │ 10:00      │            │            │           │
│            │ [Post B]   │            │            │ 11:00     │
│ 14:00      │            │ 12:00      │            │ [Post E]  │
│ [Post C]   │            │ [Post C2]  │            │           │
└────────────┴────────────┴────────────┴────────────┴───────────┘
```

**Features:**
- 7-day view starting Monday (ISO week)
- Hourly time slots
- Color-coded by status (draft, scheduled, published)
- Drag & drop between slots
- Click to edit
- Visual grouping for multi-platform posts

**2. Month View**
```
┌──────────────────────────────────────────────────────────────┐
│                        March 2026                            │
├────┬────┬────┬────┬────┬────┬────────────────────────────────┤
│ Su │ Mo │ Tu │ We │ Th │ Fr │ Sa                             │
├────┼────┼────┼────┼────┼────┼────────────────────────────────┤
│    │    │    │    │    │    │ 1                              │
├────┼────┼────┼────┼────┼────┼────────────────────────────────┤
│ 2  │ 3  │ 4  │ 5  │ 6  │ 7  │ 8                              │
│    │ •• │ •  │    │ ••••    │                                │
├────┼────┼────┼────┼────┼────┼────────────────────────────────┤
│ 9  │ 10 │ 11 │ 12 │ 13 │ 14 │ 15                             │
│    │ •  │ ••••••  │    │ •  │                                │
└────┴────┴────┴────┴────┴────┴────────────────────────────────┘
```

**Features:**
- Full month calendar
- Dots indicate posts (count)
- Click day to see posts
- Quick navigation between months
- Visual density overview

**3. Day View**
```
┌──────────────────────────────────────────────────────────────┐
│                   Tuesday, March 11, 2026                    │
├──────────┬───────────────────────────────────────────────────┤
│ 00:00    │                                                   │
│ 01:00    │                                                   │
│ 02:00    │                                                   │
│ ...      │                                                   │
│ 09:00    │ ┌──────────────────────────────────────────────┐ │
│          │ │ Morning Update                               │ │
│          │ │ [X] [LinkedIn] [Facebook]                    │ │
│          │ │ "Good morning! Here's today's tip..."        │ │
│          │ └──────────────────────────────────────────────┘ │
│ 10:00    │                                                   │
│ 11:00    │ ┌──────────────────────────────────────────────┐ │
│          │ │ Product Launch                               │ │
│          │ │ [X] [Instagram]                              │ │
│          │ │ "Exciting news! Our new product..."          │ │
│          │ └──────────────────────────────────────────────┘ │
│ 12:00    │                                                   │
│ ...      │                                                   │
└──────────┴───────────────────────────────────────────────────┘
```

**Features:**
- Hour-by-hour breakdown
- Detailed post previews
- Easy time slot selection
- Best for intensive posting days
- Drag to adjust times

**4. List View**
```
┌──────────────────────────────────────────────────────────────┐
│ Posts                                          Page 1 of 5    │
├──────────────────────────────────────────────────────────────┤
│ [✓] Published • Mar 10, 2026 09:00                           │
│     Morning Motivation                                       │
│     [X] [LinkedIn]                                           │
│     Views: 1,234 | Likes: 89 | Comments: 12                 │
├──────────────────────────────────────────────────────────────┤
│ [⏰] Scheduled • Mar 11, 2026 14:00                          │
│     Product Feature Highlight                                │
│     [X] [Facebook] [Instagram]                               │
├──────────────────────────────────────────────────────────────┤
│ [📝] Draft                                                   │
│     Weekend Promo                                            │
│     [X] [Pinterest]                                          │
├──────────────────────────────────────────────────────────────┤
│ ◀ 1  2  3  4  5 ▶                                            │
└──────────────────────────────────────────────────────────────┘
```

**Features:**
- Paginated list (100 per page)
- All posts across date ranges
- Status indicators
- Quick actions (edit, delete, duplicate)
- Search and filter
- Bulk selection
- Export options

#### URL Parameters

Calendar state is maintained in URL for shareability:

```
/calendar?display=week&startDate=2026-03-10&endDate=2026-03-16&customer=org-123
```

**Parameters:**
- `display`: week | month | day | list
- `startDate`: YYYY-MM-DD
- `endDate`: YYYY-MM-DD
- `customer`: Organization ID (for multi-tenant)

#### Calendar Context Hooks

```typescript
// Get calendar data
const { 
  posts,              // Current posts
  integrations,       // Available platforms
  startDate,          // Current range start
  endDate,            // Current range end
  loading,            // Loading state
  reloadCalendarView  // Refresh function
} = useCalendar();

// Change view
setFilters({
  display: 'month',
  startDate: '2026-03-01',
  endDate: '2026-03-31',
  customer: null
});

// Change post date (drag & drop)
changeDate(postId, newDate);
```

#### Drag & Drop Implementation

```typescript
// Post component (draggable)
const [{ isDragging }, drag] = useDrag({
  type: 'POST',
  item: { 
    id: post.id, 
    group: post.group,
    currentDate: post.publishDate 
  },
  collect: (monitor) => ({
    isDragging: monitor.isDragging(),
  }),
});

// Time slot (droppable)
const [{ isOver, canDrop }, drop] = useDrop({
  accept: 'POST',
  canDrop: (item) => {
    // Validate drop (not in past, etc.)
    return dayjs(targetDate).isAfter(dayjs());
  },
  drop: async (item) => {
    // Update post date
    await fetch(`/posts/${item.id}/date`, {
      method: 'PUT',
      body: JSON.stringify({
        date: targetDate.format(),
        action: 'schedule'
      })
    });
    // Reload calendar
    reloadCalendarView();
  },
  collect: (monitor) => ({
    isOver: monitor.isOver(),
    canDrop: monitor.canDrop(),
  }),
});
```

#### Post Status Colors

```css
.post-draft {
  background: #gray-500;
  border-left: 4px solid #gray-700;
}

.post-scheduled {
  background: #blue-500;
  border-left: 4px solid #blue-700;
}

.post-publishing {
  background: #yellow-500;
  border-left: 4px solid #yellow-700;
  animation: pulse 2s infinite;
}

.post-published {
  background: #green-500;
  border-left: 4px solid #green-700;
}

.post-failed {
  background: #red-500;
  border-left: 4px solid #red-700;
}
```

#### Calendar Filters

**Filter Options:**
```typescript
interface CalendarFilters {
  // Date range
  startDate: string;
  endDate: string;
  
  // View type
  display: 'week' | 'month' | 'day' | 'list';
  
  // Organization filter (for agencies)
  customer: string | null;
  
  // Platform filter (future)
  platforms?: string[];
  
  // Status filter (future)
  status?: ('draft' | 'scheduled' | 'published')[];
  
  // Tag filter (future)
  tags?: string[];
}
```

#### Real-time Updates

Calendar uses SWR for automatic revalidation:

```typescript
const { data, mutate, isLoading } = useSWR(
  `calendar-${params}`,
  loadData,
  {
    refreshInterval: 60000, // Refresh every minute
    revalidateOnFocus: true,
    revalidateOnReconnect: true,
  }
);
```

**Triggers for refresh:**
- Post created
- Post updated
- Post deleted
- Date changed
- Manual refresh button
- Focus return to tab
- Network reconnection

---

## Custom Backend Integration

### Overview

The frontend is designed to work with any backend that implements the required API contract. Here's how to integrate your custom backend.

### Required Environment Variables

```env
# .env.local or .env
NEXT_PUBLIC_BACKEND_URL=https://your-backend-url.com/api
NEXT_PUBLIC_UPLOAD_URL=https://your-backend-url.com/upload
```

### Authentication

The frontend uses the `useFetch` hook for all API calls, which automatically handles authentication.

**Modify if needed:**
```typescript
// apps/frontend/src/hooks/use.fetch.tsx

export const useFetch = () => {
  const fetch = useCallback(async (url: string, options?: RequestInit) => {
    const token = getToken(); // Your auth method
    
    return fetch(`${process.env.NEXT_PUBLIC_BACKEND_URL}${url}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        ...options?.headers,
      },
    });
  }, []);
  
  return fetch;
};
```

### Minimum Required Endpoints

To get the frontend working, implement these endpoints:

#### 1. Get Integrations (Platforms)
```typescript
GET /integrations

Response: Array<{
  id: string;
  name: string;
  identifier: string; // 'x', 'linkedin', 'facebook', etc.
  picture: string; // Avatar URL
  type: string; // 'social', 'blog', etc.
  editor: 'normal' | 'markdown' | 'html' | 'none';
  disabled: boolean;
  inBetweenSteps: boolean;
  display: string;
  changeProfilePicture: boolean;
  changeNickName: boolean;
  additionalSettings: string; // JSON string
  time: Array<{ time: number }>; // Preferred posting hours
  customer?: {
    id: string;
    name: string;
  };
}>
```

#### 2. Find Available Slot
```typescript
GET /posts/find-slot

Response: {
  date: string; // ISO 8601 format
}
```

#### 3. Get Posts (Calendar)
```typescript
GET /posts?display={view}&startDate={date}&endDate={date}

Response: {
  posts: Array<{
    id: string;
    group: string; // Groups multi-platform posts
    publishDate: string; // ISO 8601
    content: string;
    state: 'DRAFT' | 'QUEUE' | 'PUBLISHED';
    intervalInDays?: number; // For recurring
    integration: {
      id: string;
      name: string;
      identifier: string;
      picture: string;
    };
    image: Array<{
      id: string;
      path: string;
      alt?: string;
      thumbnail?: string;
    }>;
    tags: Array<{
      tag: {
        id: string;
        name: string;
        color: string;
      };
    }>;
  }>;
  integrations: [...]; // Same as GET /integrations
  sets: Array<{
    id: string;
    name: string;
    content: string; // JSON string
  }>;
  comments: Array<{
    date: string;
    total: number;
  }>;
}
```

#### 4. Create/Update Post
```typescript
POST /posts

Body: {
  type: 'schedule' | 'now' | 'draft' | 'update';
  date: string;
  tags: Array<{ label: string; value: string }>;
  shortLink: boolean;
  inter?: number;
  posts: Array<{
    integration: { id: string };
    group: string;
    settings: Record<string, any>;
    value: Array<{
      id?: string;
      content: string;
      delay: number;
      image: Array<{
        id: string;
        path: string;
        alt?: string;
        thumbnail?: string;
        thumbnailTimestamp?: number;
      }>;
    }>;
  }>;
}

Response: {
  success: boolean;
  groupId: string;
  posts: Array<{ id: string }>;
}
```

#### 5. Delete Post
```typescript
DELETE /posts/:group

Response: {
  success: boolean;
}
```

#### 6. Update Post Date
```typescript
PUT /posts/:id/date

Body: {
  date: string;
  action: 'schedule' | 'update';
}

Response: {
  success: boolean;
}
```

#### 7. Media Upload
```typescript
POST /upload

Content-Type: multipart/form-data
Body: FormData with 'file' field

Response: {
  id: string;
  path: string; // Full URL
  thumbnail?: string; // For videos
}
```

### Optional But Recommended Endpoints

#### Tags
```typescript
GET    /posts/tags
POST   /posts/tags
PUT    /posts/tags/:id
DELETE /posts/tags/:id
```

#### Statistics
```typescript
GET /posts/:id/statistics
```

#### List View
```typescript
GET /posts/list?page={num}&limit={num}
```

#### Shortlink Check
```typescript
POST /posts/should-shortlink
Body: { messages: string[] }
Response: { ask: boolean }
```

### Database Schema Reference

Your backend should store posts with at least these fields:

```sql
-- Posts table
CREATE TABLE posts (
  id VARCHAR(255) PRIMARY KEY,
  group_id VARCHAR(255) NOT NULL, -- Groups multi-platform posts
  organization_id VARCHAR(255) NOT NULL,
  integration_id VARCHAR(255) NOT NULL,
  publish_date TIMESTAMP NOT NULL,
  content TEXT NOT NULL,
  state ENUM('DRAFT', 'QUEUE', 'PUBLISHED', 'ERROR') NOT NULL,
  interval_in_days INT NULL, -- For recurring
  settings JSON NULL, -- Platform-specific settings
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_group (group_id),
  INDEX idx_org_date (organization_id, publish_date),
  INDEX idx_state (state)
);

-- Post media
CREATE TABLE post_media (
  id VARCHAR(255) PRIMARY KEY,
  post_id VARCHAR(255) NOT NULL,
  path VARCHAR(500) NOT NULL,
  alt_text TEXT NULL,
  thumbnail VARCHAR(500) NULL,
  thumbnail_timestamp DECIMAL(10,2) NULL,
  order_index INT NOT NULL DEFAULT 0,
  
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  INDEX idx_post (post_id)
);

-- Tags
CREATE TABLE tags (
  id VARCHAR(255) PRIMARY KEY,
  organization_id VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  color VARCHAR(7) NOT NULL, -- Hex color
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_org_tag (organization_id, name)
);

-- Post tags (many-to-many)
CREATE TABLE post_tags (
  post_id VARCHAR(255) NOT NULL,
  tag_id VARCHAR(255) NOT NULL,
  
  PRIMARY KEY (post_id, tag_id),
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Integrations (platforms)
CREATE TABLE integrations (
  id VARCHAR(255) PRIMARY KEY,
  organization_id VARCHAR(255) NOT NULL,
  identifier VARCHAR(50) NOT NULL, -- 'x', 'linkedin', etc.
  name VARCHAR(100) NOT NULL,
  picture VARCHAR(500) NULL,
  type VARCHAR(50) NOT NULL,
  token TEXT NOT NULL, -- OAuth token
  refresh_token TEXT NULL,
  expires_at TIMESTAMP NULL,
  disabled BOOLEAN DEFAULT FALSE,
  settings JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_org (organization_id)
);
```

### Integration Testing Checklist

Before deploying, test these workflows:

- [ ] **Create simple post**
  - Select 1 platform
  - Add text
  - Click "Schedule"
  - Verify appears in calendar

- [ ] **Create post with media**
  - Upload image
  - Verify preview shows image
  - Submit post
  - Verify media saved correctly

- [ ] **Create thread post**
  - Add multiple posts with delays
  - Verify all posts saved
  - Verify delays stored

- [ ] **Recurring post**
  - Set repeat interval
  - Verify recurring metadata saved
  - Check schedule generation

- [ ] **Edit existing post**
  - Click post in calendar
  - Modify content
  - Click "Update"
  - Verify changes saved

- [ ] **Delete post**
  - Click delete button
  - Confirm deletion
  - Verify removed from calendar

- [ ] **Drag & drop**
  - Drag post to new time
  - Verify date updated in backend

- [ ] **Multi-platform post**
  - Select 3+ platforms
  - Add content and media
  - Verify all platforms saved with same group_id

- [ ] **Tags**
  - Create tag
  - Apply to post
  - Verify tag association saved

- [ ] **Calendar views**
  - Switch between week/month/day/list
  - Verify data loads correctly
  - Test date navigation

### Error Handling

The frontend expects error responses in this format:

```typescript
// 4xx or 5xx response
{
  message: string; // User-friendly error message
  error?: string; // Error code or type
  statusCode: number;
}
```

**Common error scenarios to handle:**
- 401: Unauthorized (redirect to login)
- 403: Forbidden (show permission error)
- 404: Not found
- 422: Validation error
- 429: Rate limit exceeded
- 500: Server error

### Performance Considerations

**Optimization tips:**
- Use pagination for large datasets
- Implement lazy loading for media
- Cache integration list (rarely changes)
- Use ETags for conditional requests
- Compress responses (gzip)
- Use CDN for media files
- Implement request debouncing
- Optimize database queries with indexes

### Security Considerations

**Important security measures:**
- Validate all inputs server-side
- Sanitize HTML content
- Rate limit API endpoints
- Implement CORS properly
- Use HTTPS only
- Validate file uploads (type, size)
- Scan uploaded files for malware
- Implement proper authentication
- Use secure OAuth flows
- Store tokens encrypted
- Implement CSRF protection
- Validate webhook signatures

---

## Component Reference

### Key Components Quick Reference

```typescript
// Main entry point
<NewPost />
// Location: apps/frontend/src/components/launches/new.post.tsx
// Purpose: "Create Post" button, initiates post creation flow

// Modal wrapper
<AddEditModal 
  date={date}
  integrations={integrations}
  mutate={reloadCalendar}
  reopenModal={reopenFunction}
/>
// Location: apps/frontend/src/components/new-launch/add.edit.modal.tsx
// Purpose: Wraps the entire post creation modal

// Main UI
<ManageModal {...props} />
// Location: apps/frontend/src/components/new-launch/manage.modal.tsx
// Purpose: Core post creation interface with editor and previews

// Editor
<EditorWrapper totalPosts={count} value={content} />
// Location: apps/frontend/src/components/new-launch/editor.tsx
// Purpose: Rich text editor with TipTap

// Channel selection
<PicksSocialsComponent />
// Location: apps/frontend/src/components/new-launch/picks.socials.component.tsx
// Purpose: Checkboxes for selecting platforms

// Platform previews
<ShowAllProviders ref={ref} />
// Location: apps/frontend/src/components/new-launch/providers/show.all.providers.tsx
// Purpose: Renders all selected platform previews

// Media upload
<MultiMediaComponent
  value={media}
  onChange={handleMediaChange}
  maxMedia={4}
/>
// Location: apps/frontend/src/components/media/media.component.tsx
// Purpose: Media upload and library

// Date picker
<DatePicker date={date} onChange={setDate} />
// Location: apps/frontend/src/components/launches/helpers/date.picker.tsx
// Purpose: Date and time selection

// Tags
<TagsComponent
  name="tags"
  label="Tags"
  initial={tags}
  onChange={handleTagChange}
/>
// Location: apps/frontend/src/components/launches/tags.component.tsx
// Purpose: Tag selection and creation

// Repeat
<RepeatComponent repeat={interval} onChange={setInterval} />
// Location: apps/frontend/src/components/launches/repeat.component.tsx
// Purpose: Recurring post settings

// Calendar
<CalendarWeekProvider integrations={integrations}>
  <CalendarComponent />
</CalendarWeekProvider>
// Location: apps/frontend/src/components/launches/calendar.tsx
// Purpose: Main calendar display
```

### Provider Component Structure

Each platform has a provider component that follows this pattern:

```typescript
// apps/frontend/src/components/new-launch/providers/x/x.provider.tsx

export default withProvider({
  // Comment/reply settings
  postComment: PostComment.POST | PostComment.COMMENT | PostComment.ALL,
  
  // Character limits
  minimumCharacters: number | number[],
  maximumCharacters: number | ((settings) => number),
  
  // Custom settings panel
  SettingsComponent: XSettingsComponent,
  
  // Custom preview (optional)
  CustomPreviewComponent: XPreviewComponent,
  
  // Validation DTO
  dto: XDto,
  
  // Validation function
  checkValidity: async (posts, settings, additionalSettings) => {
    // Return true if valid
    // Return error string if invalid
    return true | 'Error message';
  },
});
```

**postComment Options:**
```typescript
enum PostComment {
  POST = 'POST',         // Single standalone post
  COMMENT = 'COMMENT',   // Comment only (no main post)
  ALL = 'ALL',          // Both post and comments
}
```

### Creating a New Platform Provider

To add support for a new platform:

1. **Create provider directory:**
   ```
   apps/frontend/src/components/new-launch/providers/myplatform/
   ├── myplatform.provider.tsx
   ├── myplatform.preview.tsx (optional)
   └── myplatform.settings.tsx (optional)
   ```

2. **Implement provider:**
   ```typescript
   // myplatform.provider.tsx
   import { withProvider } from '../high.order.provider';
   import { MyPlatformDto } from '@gitroom/nestjs-libraries/dtos/posts/providers-settings/myplatform.dto';
   
   export default withProvider({
     postComment: PostComment.POST,
     minimumCharacters: 1,
     maximumCharacters: 500,
     dto: MyPlatformDto,
     checkValidity: async (posts, settings) => {
       // Validation logic
       return true;
     },
   });
   ```

3. **Register in show.all.providers.tsx:**
   ```typescript
   export const Providers = [
     // ... existing providers
     {
       identifier: 'myplatform',
       component: MyPlatformProvider,
     },
   ];
   ```

4. **Add preview icon:**
   ```
   apps/frontend/public/icons/platforms/myplatform.png
   ```

5. **Create backend DTO:**
   ```typescript
   // libraries/nestjs-libraries/src/dtos/posts/providers-settings/myplatform.dto.ts
   export class MyPlatformDto {
     @IsOptional()
     @IsString()
     customSetting?: string;
   }
   ```

---

## Development Guide

### Setup

```bash
# Install dependencies
pnpm install

# Start development server
pnpm run dev

# Or start specific app
pnpm --filter ./apps/frontend run dev
```

### Development Workflow

**1. Make changes to components**
```bash
# Frontend hot reload is active
# Save files and see changes instantly
```

**2. Test in browser**
```
http://localhost:3000/calendar
```

**3. Run linting**
```bash
pnpm run lint
```

**4. Run tests**
```bash
pnpm test
```

**5. Build for production**
```bash
pnpm run build
```

### Debugging Tips

**React DevTools:**
- Install React DevTools browser extension
- Use to inspect component props and state
- Useful for debugging Zustand store

**SWR DevTools:**
```typescript
import { SWRConfig } from 'swr';

<SWRConfig value={{
  onError: (error) => console.error('SWR Error:', error),
  onSuccess: (data) => console.log('SWR Success:', data),
}}>
  {children}
</SWRConfig>
```

**Network Debugging:**
- Open browser Network tab
- Filter by "Fetch/XHR"
- Inspect API responses
- Check timing and payloads

**Zustand Store Debugging:**
```typescript
// Add to store.ts
const useLaunchStore = create(
  devtools((set) => ({
    // ... store definition
  }))
);

// Then use Redux DevTools extension
```

**Console Logging:**
```typescript
// Log store changes
useLaunchStore.subscribe((state) => {
  console.log('Store updated:', state);
});
```

### Common Issues & Solutions

**Issue: Modal not opening**
- Check if `useModals()` hook is available
- Verify modal provider wraps app
- Check for JavaScript errors in console

**Issue: Preview not updating**
- Verify Zustand store is updating
- Check if provider ref is set correctly
- Ensure `ShowAllProviders` has correct ref

**Issue: Media upload failing**
- Check file size (max 1GB)
- Verify upload endpoint is correct
- Check CORS settings
- Verify authentication token

**Issue: Calendar not loading**
- Check API endpoint response
- Verify date format (ISO 8601)
- Check for CORS issues
- Verify SWR cache key is correct

**Issue: Post validation failing**
- Check platform-specific requirements
- Verify character counts
- Check media limits
- Review console for validation errors

### Performance Optimization

**Code Splitting:**
```typescript
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(
  () => import('./heavy.component'),
  { loading: () => <LoadingSpinner /> }
);
```

**Memoization:**
```typescript
const expensiveCalculation = useMemo(() => {
  return heavyComputation(data);
}, [data]);

const memoizedCallback = useCallback(() => {
  doSomething(a, b);
}, [a, b]);
```

**Virtual Scrolling:**
For large lists, use react-window or react-virtual

**Image Optimization:**
```typescript
import Image from 'next/image';

<Image
  src={url}
  width={500}
  height={300}
  loading="lazy"
  placeholder="blur"
/>
```

### Testing

**Component Testing:**
```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('creates post', async () => {
  render(<NewPost />);
  
  const button = screen.getByText('Create Post');
  await userEvent.click(button);
  
  expect(screen.getByText('Select Channels')).toBeInTheDocument();
});
```

**Hook Testing:**
```typescript
import { renderHook, act } from '@testing-library/react';
import { useLaunchStore } from './store';

test('updates content', () => {
  const { result } = renderHook(() => useLaunchStore());
  
  act(() => {
    result.current.setGlobalValueText(0, 'New content');
  });
  
  expect(result.current.global[0].content).toBe('New content');
});
```

### Deployment

**Environment Variables:**
```env
# Production
NEXT_PUBLIC_BACKEND_URL=https://api.yourapp.com
NEXT_PUBLIC_UPLOAD_URL=https://cdn.yourapp.com
NODE_ENV=production
```

**Build:**
```bash
pnpm run build
```

**Docker:**
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build
CMD ["pnpm", "start"]
```

---

## Troubleshooting

### Frontend Issues

**Q: "Post not appearing in calendar after creation"**
A: 
- Check if `reloadCalendarView()` is called after post creation
- Verify backend returns correct date format
- Check SWR cache invalidation
- Inspect Network tab for failed requests

**Q: "Platform preview not showing"**
A:
- Verify platform is in `Providers` array
- Check if provider component exports correctly
- Ensure platform icon exists at `/public/icons/platforms/{identifier}.png`
- Check browser console for errors

**Q: "Media upload stuck"**
A:
- Check file size < 1GB
- Verify upload endpoint URL is correct
- Check CORS configuration
- Inspect Network tab for errors
- Try smaller file to test

**Q: "Can't edit existing post"**
A:
- Verify `GET /posts/group/:group` endpoint returns correct data
- Check if existingData context is populated
- Ensure post IDs are correctly passed
- Check for state initialization issues

### Backend Integration Issues

**Q: "Posts not saving to database"**
A:
- Verify payload structure matches expected format
- Check database schema matches requirements
- Review backend logs for errors
- Test with Postman/curl first
- Validate JSON schema

**Q: "Authentication failing"**
A:
- Check token is included in headers
- Verify token format (Bearer token)
- Check token expiration
- Ensure backend validates token correctly
- Review CORS headers

**Q: "Calendar returning 500 error"**
A:
- Check date range query parameters
- Verify database indexes exist
- Review backend error logs
- Test SQL query performance
- Check for missing relations

### Common Errors

**Error: "Integration not found"**
```
Solution: Ensure platform exists in database integrations table
with correct identifier matching frontend provider
```

**Error: "Maximum character limit exceeded"**
```
Solution: Check maximumCharacters function in provider
Verify weighted character counting for X/Twitter
```

**Error: "Invalid media format"**
```
Solution: Validate file type on upload
Check platform-specific media requirements
Verify MIME type detection
```

**Error: "Cannot schedule in the past"**
```
Solution: Validate date on frontend before submission
Ensure timezone handling is correct
Check server vs client time difference
```

---

## Appendix

### Platform Identifiers

```typescript
const PLATFORM_IDENTIFIERS = {
  X: 'x',
  LINKEDIN: 'linkedin',
  LINKEDIN_PAGE: 'linkedin-page',
  FACEBOOK: 'facebook',
  INSTAGRAM: 'instagram',
  INSTAGRAM_STANDALONE: 'instagram-standalone',
  THREADS: 'threads',
  TIKTOK: 'tiktok',
  YOUTUBE: 'youtube',
  PINTEREST: 'pinterest',
  REDDIT: 'reddit',
  MEDIUM: 'medium',
  DEVTO: 'devto',
  HASHNODE: 'hashnode',
  DRIBBBLE: 'dribbble',
  MASTODON: 'mastodon',
  BLUESKY: 'bluesky',
  DISCORD: 'discord',
  SLACK: 'slack',
  TELEGRAM: 'telegram',
  KICK: 'kick',
  TWITCH: 'twitch',
  LEMMY: 'lemmy',
  WARPCAST: 'warpcast',
  NOSTR: 'nostr',
  VK: 'vk',
  GMB: 'gmb',
  WORDPRESS: 'wordpress',
  LISTMONK: 'listmonk',
  MOLTBOOK: 'moltbook',
  SKOOL: 'skool',
  WHOP: 'whop',
};
```

### Character Limits by Platform

```typescript
const CHARACTER_LIMITS = {
  x: 280, // 4000 for premium
  linkedin: 3000,
  facebook: 63206,
  instagram: 2200,
  threads: 500,
  tiktok: 2200,
  youtube: 5000, // description
  pinterest: 500,
  reddit: 40000,
  medium: 100000,
  devto: 25000,
  hashnode: 25000,
  mastodon: 500,
  bluesky: 300,
  discord: 2000,
  telegram: 4096,
};
```

### Media Limits by Platform

```typescript
const MEDIA_LIMITS = {
  x: { images: 4, videos: 1, videoDuration: 140 },
  linkedin: { images: 20, videos: 1, videoDuration: 600 },
  facebook: { images: 10, videos: 1, videoDuration: 240 },
  instagram: { images: 10, videos: 1, videoDuration: 60 },
  threads: { images: 10, videos: 1, videoDuration: 90 },
  tiktok: { videos: 1, videoDuration: 600 },
  youtube: { videos: 1 },
  pinterest: { images: 5, videos: 1, videoDuration: 300 },
  // ... others
};
```

### Useful Resources

**Official Documentation:**
- Postiz Docs: https://docs.postiz.com/
- Developer Guide: https://docs.postiz.com/developer-guide
- Public API: https://docs.postiz.com/public-api

**Technologies Used:**
- Next.js: https://nextjs.org/
- React: https://react.dev/
- TipTap: https://tiptap.dev/
- Zustand: https://github.com/pmndrs/zustand
- SWR: https://swr.vercel.app/
- Uppy: https://uppy.io/
- React DnD: https://react-dnd.github.io/react-dnd/
- Dayjs: https://day.js.org/
- Tailwind CSS: https://tailwindcss.com/

**Platform APIs:**
- X (Twitter) API: https://developer.twitter.com/
- LinkedIn API: https://developer.linkedin.com/
- Facebook Graph API: https://developers.facebook.com/
- Instagram Graph API: https://developers.facebook.com/docs/instagram-api
- YouTube API: https://developers.google.com/youtube

---

## Changelog

**v1.0 - March 11, 2026**
- Initial documentation
- Comprehensive feature overview
- Backend integration guide
- Component reference
- Development guide

---

## Support

For questions or issues:
- GitHub Issues: https://github.com/gitroomhq/postiz-app/issues
- Discord: https://discord.postiz.com
- Documentation: https://docs.postiz.com

---

**End of Document**
