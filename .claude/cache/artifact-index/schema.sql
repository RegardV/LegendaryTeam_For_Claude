-- =============================================================================
-- Legendary Team v2026 - Artifact Index Database Schema
-- =============================================================================
-- Purpose: Store and search handoffs, plans, and learnings across sessions
-- Engine: SQLite 3.x with FTS5 (Full-Text Search)
-- Created: 2026-01-09
-- =============================================================================

-- =============================================================================
-- Main Artifacts Table
-- =============================================================================

CREATE TABLE IF NOT EXISTS artifacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Identification
    type TEXT NOT NULL CHECK(type IN ('handoff', 'plan', 'learning', 'ledger')),
    title TEXT NOT NULL,
    file_path TEXT UNIQUE NOT NULL,

    -- Metadata
    session_id TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    created_by TEXT, -- Agent name (@chief, @PlanAgent, etc.)

    -- Content
    summary TEXT, -- Brief summary for quick reference
    content TEXT, -- Full markdown content

    -- Outcome tracking (for handoffs)
    outcome TEXT CHECK(outcome IN ('SUCCEEDED', 'PARTIAL', 'FAILED', NULL)),
    completion_percentage INTEGER CHECK(completion_percentage BETWEEN 0 AND 100),

    -- Context
    tags TEXT, -- Comma-separated tags for categorization
    related_files TEXT, -- Comma-separated list of files touched
    keywords TEXT, -- Comma-separated keywords for search

    -- Session metrics
    duration_minutes INTEGER,
    cost_dollars REAL,
    tokens_used INTEGER,

    -- Tracing (optional Braintrust integration)
    trace_id TEXT,
    trace_url TEXT,

    -- Version control
    git_commit TEXT,
    git_branch TEXT,

    -- Indexing
    indexed_at TEXT
);

-- =============================================================================
-- Indexes for Performance
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_artifacts_type
    ON artifacts(type);

CREATE INDEX IF NOT EXISTS idx_artifacts_created_at
    ON artifacts(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_artifacts_session_id
    ON artifacts(session_id);

CREATE INDEX IF NOT EXISTS idx_artifacts_outcome
    ON artifacts(outcome);

CREATE INDEX IF NOT EXISTS idx_artifacts_created_by
    ON artifacts(created_by);

-- =============================================================================
-- Full-Text Search Virtual Table (FTS5)
-- =============================================================================

CREATE VIRTUAL TABLE IF NOT EXISTS artifacts_fts USING fts5(
    title,
    summary,
    content,
    tags,
    keywords,
    content='artifacts',
    content_rowid='id',
    tokenize='porter unicode61' -- Porter stemming + Unicode support
);

-- =============================================================================
-- Triggers to Keep FTS5 in Sync
-- =============================================================================

-- Insert trigger
CREATE TRIGGER IF NOT EXISTS artifacts_fts_insert
AFTER INSERT ON artifacts
BEGIN
    INSERT INTO artifacts_fts(rowid, title, summary, content, tags, keywords)
    VALUES (new.id, new.title, new.summary, new.content, new.tags, new.keywords);
END;

-- Update trigger
CREATE TRIGGER IF NOT EXISTS artifacts_fts_update
AFTER UPDATE ON artifacts
BEGIN
    UPDATE artifacts_fts
    SET title = new.title,
        summary = new.summary,
        content = new.content,
        tags = new.tags,
        keywords = new.keywords
    WHERE rowid = new.id;
END;

-- Delete trigger
CREATE TRIGGER IF NOT EXISTS artifacts_fts_delete
AFTER DELETE ON artifacts
BEGIN
    DELETE FROM artifacts_fts WHERE rowid = old.id;
END;

-- =============================================================================
-- File Changes Tracking
-- =============================================================================

CREATE TABLE IF NOT EXISTS file_changes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    artifact_id INTEGER NOT NULL,
    file_path TEXT NOT NULL,
    change_type TEXT NOT NULL CHECK(change_type IN ('NEW', 'MODIFIED', 'DELETED')),
    line_start INTEGER,
    line_end INTEGER,
    description TEXT,
    FOREIGN KEY (artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_file_changes_artifact
    ON file_changes(artifact_id);

CREATE INDEX IF NOT EXISTS idx_file_changes_file_path
    ON file_changes(file_path);

-- =============================================================================
-- Learnings Table (What Worked / What Didn't)
-- =============================================================================

CREATE TABLE IF NOT EXISTS learnings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    artifact_id INTEGER NOT NULL,
    learning_type TEXT NOT NULL CHECK(learning_type IN ('worked', 'failed', 'decision', 'gotcha')),
    title TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_learnings_artifact
    ON learnings(artifact_id);

CREATE INDEX IF NOT EXISTS idx_learnings_type
    ON learnings(learning_type);

-- =============================================================================
-- Dependencies Table (Tracks what depends on what)
-- =============================================================================

CREATE TABLE IF NOT EXISTS dependencies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    artifact_id INTEGER NOT NULL,
    dependency_type TEXT NOT NULL CHECK(dependency_type IN ('requires', 'blocks', 'related')),
    dependency_artifact_id INTEGER,
    dependency_external TEXT, -- For external dependencies (libraries, services)
    FOREIGN KEY (artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE,
    FOREIGN KEY (dependency_artifact_id) REFERENCES artifacts(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_dependencies_artifact
    ON dependencies(artifact_id);

-- =============================================================================
-- Metadata Table (Store database version and settings)
-- =============================================================================

CREATE TABLE IF NOT EXISTS metadata (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO metadata (key, value) VALUES ('schema_version', '1.0');
INSERT OR IGNORE INTO metadata (key, value) VALUES ('created_at', datetime('now'));
INSERT OR IGNORE INTO metadata (key, value) VALUES ('legendary_version', '2026-continuity');

-- =============================================================================
-- Views for Common Queries
-- =============================================================================

-- Recent handoffs view
CREATE VIEW IF NOT EXISTS recent_handoffs AS
SELECT
    id,
    title,
    outcome,
    completion_percentage,
    created_at,
    created_by,
    duration_minutes,
    summary
FROM artifacts
WHERE type = 'handoff'
ORDER BY created_at DESC
LIMIT 50;

-- Failed handoffs view (for learning)
CREATE VIEW IF NOT EXISTS failed_work AS
SELECT
    id,
    title,
    created_at,
    created_by,
    summary,
    file_path
FROM artifacts
WHERE type = 'handoff' AND outcome = 'FAILED'
ORDER BY created_at DESC;

-- Recent learnings view
CREATE VIEW IF NOT EXISTS recent_learnings AS
SELECT
    l.learning_type,
    l.title,
    l.description,
    l.created_at,
    a.title as artifact_title
FROM learnings l
JOIN artifacts a ON l.artifact_id = a.id
ORDER BY l.created_at DESC
LIMIT 100;

-- =============================================================================
-- Helper Functions (Implemented via Application Layer)
-- =============================================================================

-- Note: These are pseudo-functions showing what the application layer should implement

-- FUNCTION: search_artifacts(query TEXT) -> artifacts
--   Uses FTS5 to search across all content
--   Example: SELECT * FROM artifacts WHERE id IN (SELECT rowid FROM artifacts_fts WHERE artifacts_fts MATCH 'authentication')

-- FUNCTION: get_related_handoffs(file_path TEXT) -> artifacts
--   Find all handoffs that touched a specific file
--   Example: SELECT * FROM artifacts WHERE type='handoff' AND related_files LIKE '%' || file_path || '%'

-- FUNCTION: get_session_timeline(session_id TEXT) -> artifacts
--   Get all artifacts from a specific session chronologically
--   Example: SELECT * FROM artifacts WHERE session_id = ? ORDER BY created_at

-- FUNCTION: get_learnings_by_type(type TEXT) -> learnings
--   Get all learnings of a specific type
--   Example: SELECT * FROM learnings WHERE learning_type = ?

-- =============================================================================
-- Example Queries
-- =============================================================================

-- Full-text search for authentication-related work:
-- SELECT a.*
-- FROM artifacts a
-- JOIN artifacts_fts fts ON a.id = fts.rowid
-- WHERE artifacts_fts MATCH 'authentication OR jwt OR login'
-- ORDER BY rank;

-- Find all handoffs from last week that succeeded:
-- SELECT * FROM artifacts
-- WHERE type = 'handoff'
--   AND outcome = 'SUCCEEDED'
--   AND created_at >= date('now', '-7 days');

-- Find all work related to a specific file:
-- SELECT * FROM artifacts
-- WHERE related_files LIKE '%src/auth/middleware.ts%';

-- Get all learnings from failed attempts:
-- SELECT l.*
-- FROM learnings l
-- JOIN artifacts a ON l.artifact_id = a.id
-- WHERE a.outcome = 'FAILED' AND l.learning_type = 'failed';

-- =============================================================================
-- Maintenance Queries
-- =============================================================================

-- Rebuild FTS5 index (if needed):
-- INSERT INTO artifacts_fts(artifacts_fts) VALUES('rebuild');

-- Optimize database:
-- VACUUM;
-- ANALYZE;

-- Check database integrity:
-- PRAGMA integrity_check;

-- Get database statistics:
-- SELECT
--     (SELECT COUNT(*) FROM artifacts) as total_artifacts,
--     (SELECT COUNT(*) FROM artifacts WHERE type='handoff') as handoffs,
--     (SELECT COUNT(*) FROM artifacts WHERE type='plan') as plans,
--     (SELECT COUNT(*) FROM learnings) as learnings,
--     (SELECT COUNT(*) FROM file_changes) as file_changes;

-- =============================================================================
-- Schema Complete
-- =============================================================================

-- Log schema initialization
INSERT OR REPLACE INTO metadata (key, value, updated_at)
VALUES ('schema_initialized', 'true', datetime('now'));
