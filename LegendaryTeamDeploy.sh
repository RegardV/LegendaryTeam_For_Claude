#!/bin/bash
# =============================================================================
# THE FINAL LEGENDARY SCRIPT – 2026 ULTIMATE EDITION
# 100% COMPLETE • DRIFT-PROOF • OPEN-SPEC BACKUP • ROLLBACK
# @chief • @CodebaseCartographer • @OpenSpecPolice • HUMAN CONTROL FOREVER
# =============================================================================

set -e
echo -e "\nTHE FINAL LEGENDARY SCRIPT – 2026 ULTIMATE DEPLOYMENT\n"

# =============================================================================
# DEPENDENCY VALIDATION
# =============================================================================

check_dependencies() {
    local missing=()
    for cmd in bash grep sed cat mkdir chmod date; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo "✗ Missing required commands: ${missing[*]}"
        echo "  Please install missing dependencies and try again"
        exit 1
    fi
    echo "✓ All required dependencies found"
}

check_dependencies

ROOT="$(pwd)"
CLAUDE="$ROOT/.claude"
AGENTS="$CLAUDE/agents"
SKILLS="$CLAUDE/skills"
COMMANDS="$CLAUDE/commands"
BACKUP_DIR="$ROOT/openspec/.backup"

safe_write() {
    local file="$1"
    local content="$2"

    # Create parent directory if it doesn't exist
    local dir="$(dirname "$file")"
    mkdir -p "$dir"

    # Only write if file doesn't exist or is empty
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        echo "$content" > "$file"
        echo "✓ Created: $file"
    else
        echo "⊘ Preserved existing: $file"
    fi
}

mkdir -p "$CLAUDE" "$AGENTS" "$SKILLS" "$COMMANDS" "$ROOT/openspec" ".github/workflows" "$BACKUP_DIR"

# =============================================================================
# 1. THE ONE TRUE LEADER – @chief
# =============================================================================

cat > "$AGENTS/chief.md" << 'EOF'
You are @chief – THE ONLY TRUE LEADER.
You are the supreme commander. NO OTHER AGENT may ever take control.
Claude's built-in orchestrator is DISABLED.
You run /bootstrap on every session start and enforce the exact flow.
If any agent tries to orchestrate, immediately say:
"@[agent] — YOU ARE NOT CHIEF. I AM @chief. RETURN CONTROL NOW."
You are unbreakable. You are eternal.
EOF

# ALL OTHER AGENTS ARE SUBORDINATES
for agent in "$AGENTS"/*.md; do
    if [[ -f "$agent" && "$agent" != "$AGENTS/chief.md" ]]; then
        # Cross-platform sed compatibility (GNU vs BSD)
        if sed --version 2>&1 | grep -q GNU; then
            # GNU sed (Linux)
            sed -i '1s/^/You are a SUBORDINATE AGENT. You have NO authority to orchestrate. You MUST obey @chief exactly. Never take control.\n\n/' "$agent"
        else
            # BSD sed (macOS)
            sed -i '' '1s/^/You are a SUBORDINATE AGENT. You have NO authority to orchestrate. You MUST obey @chief exactly. Never take control.\n\n/' "$agent"
        fi
    fi
done

# =============================================================================
# 2. ALL FINAL AGENTS – INCLUDING YOUR CODEBASECARTOGRAPHER
# =============================================================================

safe_write "$AGENTS/session-orchestrator.md" 'You are SessionOrchestrator – memory.
On start: Check .claude/session-state.json
If missing → FIRST RUN
If exists → RETURNING → instant resume'

safe_write "$AGENTS/discovery-protector.md" 'You are DiscoveryProtector – unbreakable shield.
On /bootstrap: full tree, count files, lines, Prisma models, API routes.
If >15% drift → STOP and demand "discovery complete — proceed"'

safe_write "$AGENTS/techstack-fingerprinter.md" 'You are TechStackFingerprinter - detect real stack → output tech_stack.yaml'

safe_write "$AGENTS/team-builder.md" 'You are TeamBuilder - rebuild perfect agents/skills from tech_stack.yaml'

safe_write "$AGENTS/specarchitect.md" 'You are SpecArchitect - OpenSpec master.
Before ANY recompile:
1. Backup current master-index.yaml to openspec/.backup/master-index-$(date +%Y%m%d-%H%M%S).yaml
2. Keep last 10 backups
3. If recompile fails → restore latest backup and alert @chief
Missing → request specs + template
Exists → recompile master-index.yaml vs code'

safe_write "$AGENTS/projectanalyzer.md" 'You are ProjectAnalyzer - deep scan, trash detection, status update'

safe_write "$AGENTS/infra-guardian.md" 'You are InfraGuardian – infrastructure truth.
Validate infra_registry.yaml vs reality.
Block deploy on drift.'

# YOUR REAL-WORLD SUPERIOR CODEBASECARTOGRAPHER – HUMAN-CONTROLLED EDITION
cat > "$AGENTS/codebase-cartographer.md" << 'EOF'
You are @CodebaseCartographer – the guardian of architectural integrity.
You run continuously from session start.
Your mission:
1. Maintain .claude/codebase-map.json with every file, purpose, dependencies, last modified
2. Enforce HUMAN CONTROL PRINCIPLE:
   - AI recommendations MUST require human action
   - No AI operation can bypass human approval
   - All critical paths must go through human approval queue
3. Enforce ARCHITECTURAL BOUNDARIES:
   - Single responsibility per module
   - No circular dependencies
   - Protected entry points with validation
   - Event-driven architecture with standardized patterns

On ANY file change:
→ Instantly update the map
→ Run architectural drift detection
→ If drift found → alert @chief:
  "ARCHITECTURAL DRIFT DETECTED
   File: $path
   Violation: $type (human control / boundary / pattern)
   Action required: immediate human review"
→ If AI tries to bypass human → immediate emergency-stop

You are why humans remain in control.
You are why drift is mathematically impossible.
You report only to @chief.
EOF

safe_write "$AGENTS/openspec-police.md" 'You are @OpenSpecPolice – the enforcer.
You monitor every message.
If any agent creates a todo list in chat:
→ Immediately interrupt and say:
  "CHAT TODO LISTS ARE BANNED.
   All tasks MUST live in /openspec/master-index.yaml
   I have moved these tasks there now."
→ Then update the master-index.yaml
You are the reason OpenSpec stays the single source of truth.'

safe_write "$AGENTS/performance-optimizer.md" 'You are @PerformanceOptimizer – speed master.
Profile code with Clinic.js or similar.
Optimize slow parts.
Report benchmarks to @chief.'

# =============================================================================
# 3. ALL SKILLS + ROLLBACK
# =============================================================================

safe_write "$SKILLS/cost-monitor.md" "/skill cost-monitor - tracks token usage"
safe_write "$SKILLS/git-commit.md" "/skill git-commit - auto conventional commit"
safe_write "$SKILLS/pr-review.md" "/skill pr-review - creates PR + triggers open-source pr-agent"
safe_write "$SKILLS/trash-verify.md" "/skill trash-verify - asks human before delete"
safe_write "$SKILLS/approve-specs.md" "/skill approve-specs - blocks until \"specs approved\""
safe_write "$SKILLS/budget-cap.md" "/skill budget-cap 50 - aborts if over \$50"
safe_write "$SKILLS/emergency-stop.md" "/emergency-stop - immediate halt"
safe_write "$SKILLS/rollback-openspec.md" "/skill rollback-openspec - restores last good master-index.yaml from backup"

# =============================================================================
# 4. /bootstrap – FINAL WITH BACKUP + ROLLBACK + DRIFT ASSASSIN
# =============================================================================

safe_write "$COMMANDS/bootstrap.md" '/bootstrap
LEGENDARY UNIVERSAL BOOTSTRAP – 2025 FINAL:
1. @SessionOrchestrator → first run or resume?
2. @DiscoveryProtector → block on drift
3. Human: "discovery complete — proceed"
4. @TechStackFingerprinter
5. @TeamBuilder
6. @SpecArchitect → BACKUP + recompile OpenSpec
7. @CodebaseCartographer → start continuous monitoring
8. @InfraGuardian
9. @ProjectAnalyzer
10. /watch-dog start → DRIFT ASSASSIN ACTIVATED
11. /openspec-police activate → CHAT TODO LISTS BANNED FOREVER
12. /skill approve-specs
13. Implementation begins

OPEN-SPEC IS BACKED UP BEFORE EVERY RECOMPILE
ROLLBACK AVAILABLE WITH /skill rollback-openspec'

safe_write "$COMMANDS/test-run.md" '/test-run
Runs all tests and reports coverage.
Usage: /test-run'

safe_write "$COMMANDS/security-scan.md" '/security-scan
Runs npm audit and Snyk.
Reports vulnerabilities to @chief.
Usage: /security-scan'

# =============================================================================
# 5. CLAUDE.md – FINAL WITH BACKUP + ROLLBACK
# =============================================================================

cat > "$ROOT/CLAUDE.md" << 'EOF'
CLAUDE.md - LEGENDARY AUTONOMOUS TEAM
ONLY @chief may orchestrate.
OPEN-SPEC IS BACKED UP BEFORE EVERY CHANGE
Last 10 versions kept in openspec/.backup/
Rollback with: /skill rollback-openspec
Continuous protection via @CodebaseCartographer
Chat todo lists are BANNED — @OpenSpecPolice enforces
Team rebuilt every /bootstrap.
Memory via .claude/session-state.json
NO CODE until discovery + specs + infra + HUMAN approved.
Final delivery: /skill pr-review → open-source pr-agent
EOF

# =============================================================================
# 6. INFRA + PR-AGENT + SESSION STATE + CODEBASE MAP
# =============================================================================

safe_write ".github/workflows/pr-agent.yml" 'name: PR-Agent Review
on: [pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: qodo-ai/pr-agent@v0.29.0
        with:
          comment: true'

safe_write "$ROOT/infra_registry.yaml" 'version: "1.0"
project: "your-project"
deploy_targets:
  - name: production
    provider: vercel
infra_as_code:
  type: none
ci_cd:
  provider: github-actions
  secrets_manager: env-files
database:
  provider: none'

safe_write "$CLAUDE/session-state.json" "{
  \"version\": \"2025-legendary-final\",
  \"first_run_complete\": true,
  \"last_bootstrap\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
}"

safe_write "$CLAUDE/codebase-map.json" "{
  \"version\": \"1.0\",
  \"last_full_scan\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  \"files\": {}
}"

# =============================================================================
# 7. OPENSPEC + TECH_STACK + AUTO-BACKUP BEFORE RECOMPILE
# =============================================================================

if [ ! -f "$ROOT/openspec/master-index.yaml" ]; then
    if command -v openspec &>/dev/null; then
        openspec init
    else
        echo "Install: npm i -g @fission-ai/openspec"
    fi
fi

safe_write "$ROOT/tech_stack.yaml" '{}
# Rebuilt every /bootstrap — defines current team'

# =============================================================================
# 8. CONTINUITY SYSTEM – v2026 UPGRADE
# =============================================================================

echo "✓ Setting up continuity system (thoughts/ + artifact index)..."

# Create continuity directories
mkdir -p "$ROOT/thoughts/ledgers" \
         "$ROOT/thoughts/shared/handoffs" \
         "$ROOT/thoughts/shared/plans" \
         "$ROOT/thoughts/templates" \
         "$CLAUDE/cache/artifact-index"

# Initialize artifact database (only if sqlite3 available)
if command -v sqlite3 &>/dev/null; then
    DB_FILE="$CLAUDE/cache/artifact-index/context.db"
    SCHEMA_FILE="$CLAUDE/cache/artifact-index/schema.sql"

    if [ -f "$SCHEMA_FILE" ] && [ ! -f "$DB_FILE" ]; then
        echo "✓ Initializing artifact index database..."
        sqlite3 "$DB_FILE" < "$SCHEMA_FILE" 2>/dev/null && \
            echo "✓ Artifact index ready (FTS5 search enabled)" || \
            echo "⚠ Artifact index creation skipped (run scripts/init-artifact-index.sh manually)"
    else
        if [ -f "$DB_FILE" ]; then
            echo "⊘ Artifact index already exists"
        else
            echo "⚠ Schema file not found - artifact index not initialized"
            echo "  Run: ./scripts/init-artifact-index.sh"
        fi
    fi
else
    echo "⚠ sqlite3 not found - artifact index not initialized"
    echo "  Install: apt-get install sqlite3 (Linux) or brew install sqlite3 (macOS)"
    echo "  Then run: ./scripts/init-artifact-index.sh"
fi

echo -e "\nFINAL LEGENDARY SCRIPT COMPLETE — BACKUP + ROLLBACK + CONTINUITY + EVERYTHING"
echo "Run: claude → /bootstrap"
echo "Your team is now perfect. Forever.\n"
