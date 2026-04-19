---
phase: 2-media-library-foundation
plan: 06
type: execute
wave: 1
depends_on:
  - 04
  - 05
files_modified:
  - src/components/media/LibraryBrowser.tsx
  - src/components/media/FileList.tsx
  - src/components/media/FolderTree.tsx
autonomous: true
requirements:
  - MEDIA-03: Build media library browser interface
user_setup: []

must_haves:
  truths:
    - "LibraryBrowser component displays hierarchical folder structure"
    - "FileList shows paginated files with search and filter controls"
    - "FolderTree renders collapsible tree with expand/collapse functionality"
    - "All components fetch data from Phase 2 APIs (plan 05)"
  artifacts:
    - path: "src/components/media/LibraryBrowser.tsx"
      provides: "Main library browser container with navigation"
      min_lines: 80
    - path: "src/components/media/FileList.tsx"
      provides: "Paginated file list with search/filter"
      min_lines: 60
    - path: "src/components/media/FolderTree.tsx"
      provides: "Collapsible folder tree component"
      min_lines: 70
  key_links:
    - from: "src/components/media/LibraryBrowser.tsx"
      to: "/api/media/folders"
      via: "fetches folder list on mount, refreshes on navigation"
      pattern: "fetch.*folders"
---

<objective>
Build media library browser interface with hierarchical navigation, file listing, and search/filter capabilities.

Purpose: Create the UI layer that consumes the APIs from plan 05 to display media content to users.
Output: Three React components for library browsing, file listing, and folder tree rendering.
</objective>

<execution_context>
@$HOME/.config/opencode/get-shit-done/workflows/execute-plan.md
@$HOME/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/2-CONTEXT.md
@.planning/phases/2-media-library-foundation/04-MEDIA-MODELS-PLAN.md
@.planning/phases/2-media-library-foundation/05-FILE-SYSTEM-API-PLAN.md
</context>

<tasks>

<task type="auto">
  <name>task 1: create LibraryBrowser main container component</name>
  <files>src/components/media/LibraryBrowser.tsx</files>
  <action>Create main library browser container that:
    - Fetches folder list from /api/media/folders on mount
    - Displays current folder contents with breadcrumb navigation
    - Shows "Back" button when not at root level
    - Renders FileList component for current folder's files
    - Implements keyboard shortcuts (Esc to go back, Ctrl+F for search)
    
    Use React hooks (useState, useEffect) for state management. Implement debounced search with 300ms delay.
  </action>
  <verify>Component renders folder contents; breadcrumb updates on navigation</verify>
  <done>src/components/media/LibraryBrowser.tsx created with full navigation logic</done>
</task>

<task type="auto">
  <name>task 2: create FileList component with search and filtering</name>
  <files>src/components/media/FileList.tsx</files>
  <action>Create file list component that:
    - Receives files array as prop from parent
    - Displays file icons, names, sizes, dates
    - Implements client-side search (filters by name)
    - Provides type filter dropdown (All, Videos, Audio, Images, Documents)
    - Shows skeleton loaders during data fetch
    - Handles empty state with helpful message
    
    Use memoization for efficient re-renders. Implement virtual scrolling for large lists (>100 items).
  </action>
  <verify>Component filters files by search query; type filter works correctly</verify>
  <done>src/components/media/FileList.tsx created with search and filtering capabilities</done>
</task>

<task type="auto">
  <name>task 3: create FolderTree component with collapsible nodes</name>
  <files>src/components/media/FolderTree.tsx</files>
  <action>Create folder tree component that:
    - Receives flat folder array and renders hierarchical structure
    - Implements expand/collapse for each folder node
    - Shows folder icon, name, item count (e.g., "Music (42 items)")
    - Highlights selected/active folder
    - Supports drag-and-drop reordering (future enhancement placeholder)
    
    Use recursive rendering for deep nesting. Implement lazy loading of subfolders when expanding.
  </action>
  <verify>Tree renders nested folders; expand/collapse toggles work correctly</verify>
  <done>src/components/media/FolderTree.tsx created with collapsible tree functionality</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| client→API | Untrusted input (search queries, filter values) crosses here |
| API→Database | Sensitive metadata stored; paths must be validated |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-02-01 | Spoofing | Search input | mitigate | Sanitize search queries, limit length to 100 chars |
| T-02-02 | Tampering | Folder tree state | accept | State is client-side only; no security impact |
| T-02-03 | DoS | Large file lists | mitigate | Virtual scrolling limits memory usage for large datasets |
</threat_model>

<verification>
## Phase Verification Checklist

- [x] All three components created in correct locations
- [x] TypeScript compiles without errors
- [x] Components fetch from /api/media/folders endpoint
- [x] Search and filtering work with debouncing
- [x] Tree expands/collapses correctly for deep nesting
- [ ] Unit tests written for component behavior (Wave 2 task)
</verification>

<success_criteria>
## Success Criteria

**Functional:**
- LibraryBrowser displays current folder contents with proper navigation
- FileList filters files by search query and type filter
- FolderTree renders hierarchical structure with expand/collapse

**Performance:**
- Search debouncing prevents excessive filtering (300ms delay)
- Virtual scrolling handles 1000+ items smoothly
- Tree lazy-loading prevents memory exhaustion on deep structures

**Code Quality:**
- Components use React best practices (hooks, memoization)
- Proper prop typing with TypeScript interfaces
- Accessibility attributes (aria-labels for navigation)
</success_criteria>

<output>
After completion, create `.planning/phases/2-media-library-foundation/06-LIBRARY-UI-SUMMARY.md`
</output>