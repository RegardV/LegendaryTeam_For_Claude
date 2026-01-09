#!/bin/bash
# =============================================================================
# Initialize Artifact Index Database
# Creates SQLite database with FTS5 for searchable continuity system
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT="$(pwd)"
CACHE_DIR="$ROOT/.claude/cache/artifact-index"
DB_FILE="$CACHE_DIR/context.db"
SCHEMA_FILE="$CACHE_DIR/schema.sql"

echo -e "\n🗄️  Initializing Artifact Index Database...\n"

# =============================================================================
# 1. CHECK DEPENDENCIES
# =============================================================================

check_sqlite() {
    if ! command -v sqlite3 &>/dev/null; then
        echo -e "${RED}✗ sqlite3 not found${NC}"
        echo -e "${YELLOW}Install with:${NC}"
        echo "  Ubuntu/Debian: sudo apt-get install sqlite3"
        echo "  macOS: brew install sqlite3"
        echo "  Fedora: sudo dnf install sqlite"
        exit 1
    fi

    # Check SQLite version (need 3.9.0+ for FTS5)
    local version=$(sqlite3 --version | awk '{print $1}')
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)

    if [ "$major" -lt 3 ] || ([ "$major" -eq 3 ] && [ "$minor" -lt 9 ]); then
        echo -e "${RED}✗ SQLite version $version is too old (need 3.9.0+ for FTS5)${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ sqlite3 version $version${NC}"
}

check_sqlite

# =============================================================================
# 2. CREATE DIRECTORY
# =============================================================================

if [ ! -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR"
    echo -e "${GREEN}✓ Created cache directory${NC}"
else
    echo -e "${GREEN}⊘ Cache directory exists${NC}"
fi

# =============================================================================
# 3. CHECK EXISTING DATABASE
# =============================================================================

if [ -f "$DB_FILE" ]; then
    echo -e "${YELLOW}⚠ Database already exists: $DB_FILE${NC}"
    echo -e "${YELLOW}Choose an action:${NC}"
    echo "  1) Keep existing database (safe)"
    echo "  2) Backup and reinitialize"
    echo "  3) Delete and reinitialize (destructive)"
    echo "  4) Cancel"

    read -p "Enter choice [1-4]: " choice

    case $choice in
        1)
            echo -e "${GREEN}✓ Keeping existing database${NC}"
            exit 0
            ;;
        2)
            backup_file="$CACHE_DIR/context.db.backup.$(date +%Y%m%d-%H%M%S)"
            cp "$DB_FILE" "$backup_file"
            echo -e "${GREEN}✓ Backed up to: $backup_file${NC}"
            rm "$DB_FILE"
            echo -e "${GREEN}✓ Removed old database${NC}"
            ;;
        3)
            rm "$DB_FILE"
            echo -e "${GREEN}✓ Removed old database${NC}"
            ;;
        4)
            echo -e "${YELLOW}Cancelled${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
fi

# =============================================================================
# 4. CHECK SCHEMA FILE
# =============================================================================

if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}✗ Schema file not found: $SCHEMA_FILE${NC}"
    echo -e "${YELLOW}Expected location: .claude/cache/artifact-index/schema.sql${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Schema file found${NC}"

# =============================================================================
# 5. CREATE DATABASE
# =============================================================================

echo -e "\n${YELLOW}Creating database...${NC}"

if sqlite3 "$DB_FILE" < "$SCHEMA_FILE" 2>&1 | tee /tmp/sqlite-init.log; then
    echo -e "${GREEN}✓ Database created successfully${NC}"
else
    echo -e "${RED}✗ Database creation failed${NC}"
    echo -e "${YELLOW}Check log: /tmp/sqlite-init.log${NC}"
    exit 1
fi

# =============================================================================
# 6. VERIFY DATABASE
# =============================================================================

echo -e "\n${YELLOW}Verifying database...${NC}"

# Check tables exist
tables=$(sqlite3 "$DB_FILE" "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;" 2>/dev/null)

expected_tables=(
    "artifacts"
    "artifacts_fts"
    "file_changes"
    "learnings"
    "dependencies"
    "metadata"
)

for table in "${expected_tables[@]}"; do
    if echo "$tables" | grep -q "^$table$"; then
        echo -e "${GREEN}✓ Table '$table' exists${NC}"
    else
        echo -e "${RED}✗ Table '$table' missing${NC}"
        exit 1
    fi
done

# Check FTS5 is working
if sqlite3 "$DB_FILE" "SELECT * FROM artifacts_fts LIMIT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ FTS5 full-text search is working${NC}"
else
    echo -e "${RED}✗ FTS5 search failed${NC}"
    exit 1
fi

# Check schema version
version=$(sqlite3 "$DB_FILE" "SELECT value FROM metadata WHERE key='schema_version';" 2>/dev/null)
echo -e "${GREEN}✓ Schema version: $version${NC}"

# =============================================================================
# 7. GET DATABASE STATS
# =============================================================================

echo -e "\n${YELLOW}Database Statistics:${NC}"

stats=$(sqlite3 "$DB_FILE" "
SELECT
    (SELECT COUNT(*) FROM artifacts) as total_artifacts,
    (SELECT COUNT(*) FROM artifacts WHERE type='handoff') as handoffs,
    (SELECT COUNT(*) FROM artifacts WHERE type='plan') as plans,
    (SELECT COUNT(*) FROM artifacts WHERE type='learning') as learnings,
    (SELECT COUNT(*) FROM file_changes) as file_changes;
" 2>/dev/null)

echo "  Total artifacts: $(echo "$stats" | cut -d'|' -f1)"
echo "  Handoffs: $(echo "$stats" | cut -d'|' -f2)"
echo "  Plans: $(echo "$stats" | cut -d'|' -f3)"
echo "  Learnings: $(echo "$stats" | cut -d'|' -f4)"
echo "  File changes: $(echo "$stats" | cut -d'|' -f5)"

# =============================================================================
# 8. SET PERMISSIONS
# =============================================================================

chmod 644 "$DB_FILE"
echo -e "${GREEN}✓ Set database permissions (644)${NC}"

# =============================================================================
# 9. CREATE HELPER QUERIES FILE
# =============================================================================

QUERIES_FILE="$CACHE_DIR/queries.sql"

cat > "$QUERIES_FILE" << 'EOF'
-- =============================================================================
-- Common Queries for Artifact Index
-- Usage: sqlite3 context.db < queries.sql
-- =============================================================================

-- Search for artifacts by keyword
.mode box
.headers on
SELECT id, type, title, outcome, created_at
FROM artifacts a
JOIN artifacts_fts fts ON a.id = fts.rowid
WHERE artifacts_fts MATCH 'authentication'
ORDER BY rank
LIMIT 10;

-- Recent handoffs
SELECT id, title, outcome, completion_percentage, created_at
FROM recent_handoffs
LIMIT 10;

-- Failed work (for learning)
SELECT id, title, created_at, summary
FROM failed_work;

-- All learnings
SELECT learning_type, title, created_at
FROM recent_learnings
LIMIT 20;

-- Files changed recently
SELECT DISTINCT file_path, change_type, COUNT(*) as change_count
FROM file_changes
GROUP BY file_path, change_type
ORDER BY MAX(id) DESC
LIMIT 20;
EOF

echo -e "${GREEN}✓ Created helper queries file: $QUERIES_FILE${NC}"

# =============================================================================
# 10. DISPLAY SUCCESS MESSAGE
# =============================================================================

echo -e "\n${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Artifact Index Database Initialized Successfully${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}\n"

echo -e "Database location: ${YELLOW}$DB_FILE${NC}"
echo -e "Schema version: ${YELLOW}$version${NC}"
echo -e "FTS5 search: ${GREEN}Enabled${NC}\n"

echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Handoffs and plans are auto-indexed via PostToolUse hook"
echo "  2. Query artifacts: /skill query-artifacts \"keywords\""
echo "  3. View in dashboard: ./legendary-dashboard.html"
echo ""
echo -e "${YELLOW}Manual queries:${NC}"
echo "  sqlite3 $DB_FILE"
echo "  sqlite3 $DB_FILE < $QUERIES_FILE"
echo ""
echo -e "${YELLOW}Database maintenance:${NC}"
echo "  Backup: cp $DB_FILE $DB_FILE.backup"
echo "  Optimize: sqlite3 $DB_FILE 'VACUUM; ANALYZE;'"
echo "  Integrity: sqlite3 $DB_FILE 'PRAGMA integrity_check;'"
echo ""

echo -e "${GREEN}Database is ready for use!${NC}\n"
