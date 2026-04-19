---
phase: 2-media-library-foundation
plan: 04
type: execute
wave: 1
depends_on: []
files_modified:
  - src/models/media/file.ts
  - src/models/media/folder.ts
  - src/models/media/playlist.ts
  - src/types/media.types.ts
autonomous: true
requirements:
  - MEDIA-01: Define media entity models (files, folders, playlists)
user_setup: []

must_haves:
  truths:
    - "Media entities have proper type definitions with all required fields"
    - "File model includes metadata: path, size, mime-type, duration, createdAt"
    - "Folder model includes parent-child relationships and nested structure support"
    - "Playlist model supports multiple media items with ordering"
  artifacts:
    - path: "src/models/media/file.ts"
      provides: "File entity model with metadata fields"
      min_lines: 40
    - path: "src/models/media/folder.ts"
      provides: "Folder entity model with hierarchy support"
      min_lines: 35
    - path: "src/models/media/playlist.ts"
      provides: "Playlist entity model with item ordering"
      min_lines: 30
    - path: "src/types/media.types.ts"
      provides: "Shared media type definitions and interfaces"
      min_lines: 25
  key_links:
    - from: "src/models/media/file.ts"
      to: "src/api/media/files/route.ts"
      via: "API endpoint uses File model for request/response validation"
      pattern: "import.*File\s+from.*file\.ts"
---

<objective>
Define media entity models (files, folders, playlists) with proper type definitions and metadata fields.

Purpose: Establish the data contracts that will be used throughout Phase 2 for all media operations.
Output: Four TypeScript files defining File, Folder, and Playlist entities plus shared types.
</objective>

<execution_context>
@$HOME/.config/opencode/get-shit-done/workflows/execute-plan.md
@$HOME/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/2-CONTEXT.md
@.planning/ROADMAP.md
</context>

<tasks>

<task type="auto">
  <name>task 0: create shared media types file with interfaces</name>
  <files>src/types/media.types.ts</files>
  <action>Create shared type definitions for all media entities. Define:
    - `MediaItem` interface (common fields: id, name, createdAt)
    - `FileMetadata` interface (path, size, mimeType, duration, hash)
    - `FolderNode` interface (parentId, children reference, depth)
    - `PlaylistEntry` interface (mediaId, position, title override)
    
    Export all interfaces for use across models and APIs. Use JSDoc comments to document each field with expected types and constraints.
  </action>
  <verify>File exists with exported interfaces; TypeScript compiler validates no errors</verify>
  <done>src/types/media.types.ts created with MediaItem, FileMetadata, FolderNode, PlaylistEntry interfaces</done>
</task>

<task type="auto">
  <name>task 1: create File entity model with metadata fields</name>
  <files>src/models/media/file.ts</files>
  <action>Create File entity class/model that extends MediaItem. Include:
    - Required fields: id, name, path (normalized), size in bytes
    - Metadata fields: mimeType, duration (ms or null for non-video), fileHash (SHA-256 prefix)
    - Computed getters: formattedSize, isVideo, isAudio
    - Methods: validatePath(), normalizePath()
    
    Use JSDoc to document each field. Ensure path normalization handles Windows/Unix separators consistently.
  </action>
  <verify>File exports File entity; all required fields present in type definition</verify>
  <done>src/models/media/file.ts created with complete File entity model</done>
</task>

<task type="auto">
  <name>task 2: create Folder entity model with hierarchy support</name>
  <files>src/models/media/folder.ts</files>
  <action>Create Folder entity class/model that extends MediaItem. Include:
    - Required fields: id, name, path (normalized), parentId (null for root)
    - Optional fields: iconPath, description, sortOrder
    - Computed getters: isRoot, depthLevel, siblingCount
    - Methods: findChildByName(), getSubfolders(), buildTree()
    
    Implement recursive tree building that handles deep nesting. Use JSDoc to document the recursive algorithms.
  </action>
  <verify>File exports Folder entity; hierarchy methods work with nested folder structures</verify>
  <done>src/models/media/folder.ts created with complete Folder entity model and hierarchy support</done>
</task>

<task type="auto">
  <name>task 3: create Playlist entity model with item ordering</name>
  <files>src/models/media/playlist.ts</files>
  <action>Create Playlist entity class/model that extends MediaItem. Include:
    - Required fields: id, name, description
    - Optional fields: isPublic (boolean), createdAt, updatedAt
    - Relationship field: entries (array of PlaylistEntry)
    - Methods: addEntry(), removeEntry(), getOrderedEntries()
    
    Ensure entries maintain insertion order with position tracking. Use JSDoc to document entry management methods.
  </action>
  <verify>File exports Playlist entity; entry ordering is preserved correctly</verify>
  <done>src/models/media/playlist.ts created with complete Playlist entity model and entry management</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| client→API | Untrusted input (file paths, names) crosses here |
| API→Database | Sensitive metadata stored; paths must be validated |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-02-01 | Spoofing | File path input | mitigate | Validate and normalize all file paths at API boundary using allowlist patterns |
| T-02-02 | Tampering | Stored metadata | accept | Metadata is read-only after upload; no modification needed |
| T-02-03 | Repudiation | Playlist creation | transfer | Use user authentication (Phase 1) for attribution |
</threat_model>

<verification>
## Phase Verification Checklist

- [x] All four files created in correct locations
- [x] TypeScript compiles without errors
- [x] All interfaces exported and importable
- [x] Entity models extend base MediaItem appropriately
- [x] Hierarchy methods handle deep nesting (tested with 10+ levels)
- [x] Path normalization works cross-platform
- [ ] Unit tests written for entity methods (Wave 2 task)
</verification>

<success_criteria>
## Success Criteria

**Functional:**
- All four files exist and TypeScript compiles without errors
- File model validates paths and computes metadata correctly
- Folder model builds tree structure from flat data in <10ms for 1000 items
- Playlist maintains entry order through add/remove operations

**Code Quality:**
- JSDoc comments present on all public fields and methods
- No hardcoded strings or magic numbers
- Consistent naming conventions (camelCase for properties, PascalCase for types)

**Documentation:**
- Each file has module-level JSDoc header
- All interfaces documented with field descriptions
</success_criteria>

<output>
After completion, create `.planning/phases/2-media-library-foundation/04-MEDIA-MODELS-SUMMARY.md`
</output>