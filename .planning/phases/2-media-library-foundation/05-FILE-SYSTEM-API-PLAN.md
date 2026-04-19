---
phase: 2-media-library-foundation
plan: 05
type: execute
wave: 1
depends_on:
  - 04
files_modified:
  - src/api/media/files/route.ts
  - src/api/media/folders/route.ts
  - src/api/media/playlists/route.ts
autonomous: true
requirements:
  - MEDIA-02: Create API endpoints for media CRUD operations
user_setup: []

must_haves:
  truths:
    - "GET /api/media/files returns paginated list of files with metadata"
    - "POST /api/media/folders creates a new folder with validation"
    - "DELETE /api/media/playlists/{id} removes playlist and all entries"
    - "All endpoints use proper error handling and status codes"
  artifacts:
    - path: "src/api/media/files/route.ts"
      provides: "File CRUD API (GET list, POST upload, DELETE remove)"
      exports: ["GET", "POST", "DELETE"]
    - path: "src/api/media/folders/route.ts"
      provides: "Folder CRUD API with tree operations"
      exports: ["GET", "POST", "PUT", "DELETE"]
    - path: "src/api/media/playlists/rource.ts"
      provides: "Playlist management API"
      exports: ["GET", "POST", "PUT", "DELETE"]
  key_links:
    - from: "src/api/media/files/route.ts"
      to: "src/models/media/file.ts"
      via: "API uses File model for request/response validation"
      pattern: "import.*File\s+from.*file\.ts"
---

<objective>
Create API endpoints for media CRUD operations (files, folders, playlists) with proper error handling and pagination.

Purpose: Build the backend infrastructure that will serve media data to the UI layer in plan 06.
Output: Three route files implementing RESTful APIs for all media entity types.
</objective>

<execution_context>
@$HOME/.config/opencode/get-shit-done/workflows/execute-plan.md
@$HOME/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/2-CONTEXT.md
@.planning/phases/2-media-library-foundation/04-MEDIA-MODELS-PLAN.md
</context>

<tasks>

<task type="auto">
  <name>task 1: create Files API route with pagination and search</name>
  <files>src/api/media/files/route.ts</files>
  <action>Create RESTful API for file operations:
    - GET /api/media/files?offset=0&limit=50&search=<query>&type=<filter>
      Returns paginated list with optional search and type filtering
    - POST /api/media/files (multipart/form-data)
      Accepts file upload, returns created file metadata
    - DELETE /api/media/files/{id}
      Removes file from system
    
    Implement pagination using offset/limit. Add query parameter validation. Return 400 for invalid requests, 201 for successful uploads, 204 for deletions.
  </action>
  <verify>Route handles GET with pagination params; POST accepts multipart form</verify>
  <done>src/api/media/files/route.ts created with full CRUD operations</done>
</task>

<task type="auto">
  <name>task 2: create Folders API route with tree operations</name>
  <files>src/api/media/folders/route.ts</files>
  <action>Create RESTful API for folder operations:
    - GET /api/media/folders?path=<folderPath>&recursive=true
      Returns folder contents, optionally recursively
    - POST /api/media/folders
      Creates new folder with name validation (no duplicates)
    - PUT /api/media/folders/{id}
      Renames or moves folder (updates path)
    - DELETE /api/media/folders/{id}
      Removes folder and all contents (recursive delete)
    
    Implement recursive tree building for GET requests. Validate folder name length (1-100 chars). Return 409 for duplicate names, 201 for successful creation.
  </action>
  <verify>Route handles recursive folder listing; POST validates unique names</verify>
  <done>src/api/media/folders/route.ts created with tree operations API</done>
</task>

<task type="auto">
  <name>task 3: create Playlists API route with entry management</name>
  <files>src/api/media/playlists/route.ts</files>
  <action>Create RESTful API for playlist operations:
    - GET /api/media/playlists?public=true
      Returns playlists, optionally filtered by public/private
    - POST /api/media/playlists
      Creates new empty playlist with name validation
    - PUT /api/media/playlists/{id}
      Updates playlist metadata (name, description)
    - DELETE /api/media/playlists/{id}
      Removes playlist and all entries atomically
    
    Implement atomic operations for data consistency. Validate playlist name uniqueness. Return 409 for duplicate names, 201 for successful creation.
  </action>
  <verify>Route handles public/private filtering; POST validates unique names</verify>
  <done>src/api/media/playlists/route.ts created with entry management API</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| client→API | Untrusted input (file paths, names) crosses here |
| API→Filesystem | Sensitive file operations; paths must be validated |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-02-01 | Spoofing | File path input | mitigate | Validate and normalize all file paths at API boundary using allowlist patterns |
| T-02-02 | Tampering | Stored metadata | accept | Metadata is read-only after upload; no modification needed |
| T-02-03 | Repudiation | Playlist creation | transfer | Use user authentication (Phase 1) for attribution |
| T-02-04 | DoS | Large file uploads | mitigate | Implement size limits and rate limiting on POST endpoints |
</threat_model>

<verification>
## Phase Verification Checklist

- [x] All three route files created in correct locations
- [x] TypeScript compiles without errors
- [x] All CRUD operations implemented with proper HTTP methods
- [x] Pagination implemented correctly (offset/limit)
- [x] Error handling returns appropriate status codes
- [ ] Integration tests written for API endpoints (Wave 2 task)
</verification>

<success_criteria>
## Success Criteria

**Functional:**
- All three routes exist and TypeScript compiles without errors
- Files API supports pagination, search, and type filtering
- Folders API handles recursive tree operations correctly
- Playlists API manages entries atomically with proper validation

**Code Quality:**
- Consistent error handling across all endpoints
- Proper HTTP status codes (201 for creation, 204 for deletion)
- Input validation prevents injection attacks

**Documentation:**
- JSDoc comments on all route handlers and exports
</success_criteria>

<output>
After completion, create `.planning/phases/2-media-library-foundation/05-FILE-SYSTEM-API-SUMMARY.md`
</output>