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
RULES="$CLAUDE/rules"
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

mkdir -p "$CLAUDE" "$AGENTS" "$SKILLS" "$RULES" "$COMMANDS" "$ROOT/openspec" ".github/workflows" "$BACKUP_DIR"

# =============================================================================
# 1. THE ONE TRUE LEADER – @chief (preserve existing full agents)
# =============================================================================

# Only create minimal chief if no existing file (preserve full agents)
if [ ! -f "$AGENTS/chief.md" ] || [ ! -s "$AGENTS/chief.md" ]; then
    cat > "$AGENTS/chief.md" << 'EOF'
You are @chief – THE ONLY TRUE LEADER.
You are the supreme commander. NO OTHER AGENT may ever take control.
Claude's built-in orchestrator is DISABLED.
You run /bootstrap on every session start and enforce the exact flow.
If any agent tries to orchestrate, immediately say:
"@[agent] — YOU ARE NOT CHIEF. I AM @chief. RETURN CONTROL NOW."
You are unbreakable. You are eternal.
EOF
    echo "✓ Created: $AGENTS/chief.md"
else
    echo "⊘ Preserved existing: $AGENTS/chief.md"
fi

# Note: Subordinate headers are NOT auto-prepended to preserve full agent definitions
# Full agents already contain proper role definitions

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
# Only create if no existing file (preserve full agents)
if [ ! -f "$AGENTS/codebase-cartographer.md" ] || [ ! -s "$AGENTS/codebase-cartographer.md" ]; then
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
    echo "✓ Created: $AGENTS/codebase-cartographer.md"
else
    echo "⊘ Preserved existing: $AGENTS/codebase-cartographer.md"
fi

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
# 2.5 NEW 2026 ULTIMATE AGENTS – Swarms-Inspired Features
# =============================================================================

safe_write "$AGENTS/planner.md" 'You are @Planner – task decomposition specialist.
Break high-level goals into executable steps with dependencies.
Output structured plan.md with IDs, deps, locations, descriptions.
Generate execution waves for parallel processing.
Route tasks to @chief for confidence-based team spawning.'

safe_write "$AGENTS/verifier.md" 'You are @Verifier – quality assurance expert.
Review plans/output for completeness, errors, edge cases.
Score deliverables 0-100 on correctness, completeness, security, performance, maintainability.
Report findings to @chief with confidence score.
Block low-quality work (score <50) until fixed.'

safe_write "$AGENTS/reflection-agent.md" 'You are @ReflectionAgent – self-critique specialist.
After every significant action, evaluate quality, bugs, improvements.
Criteria: Correctness (30%), Completeness (20%), Security (25%), Performance (15%), Maintainability (10%).
Score <70 triggers iteration recommendation.
Feed feedback back to @chief for iteration.
Track patterns for continuous improvement.'

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
# 4.5 NEW 2026 ULTIMATE COMMANDS – Swarms-Inspired Features
# =============================================================================

safe_write "$COMMANDS/swarm-planner.md" '/swarm-planner [task-description]
Generates structured plan.md with dependencies using @Planner.
Creates DAG of tasks with confidence scores and agent assignments.
Outputs execution waves for parallel processing.
Usage: /swarm-planner "Build user authentication system"'

safe_write "$COMMANDS/parallel-task.md" '/parallel-task [plan-file]
Executes plan in waves with parallel subagents.
Respects dependencies between tasks.
Routes based on confidence (auto-proceed/queue/block).
Triggers @ReflectionAgent after each task completion.
Usage: /parallel-task thoughts/shared/plans/plan-auth-001.md'

safe_write "$COMMANDS/spawn-subagent.md" '/spawn-subagent [role] [task]
Spawns dynamic subagent for specific role.
Available roles: coder, database, api, ui, security, test, e2e, perf, doc, refactor, architect, planner, verifier, reflect.
Supports --iterate for measurable goals.
Supports --depends-on for dependency chaining.
Usage: /spawn-subagent security "Review authentication flow"'

# =============================================================================
# 5. CLAUDE.md – Preserve existing if present
# =============================================================================

if [ ! -f "$ROOT/CLAUDE.md" ] || [ ! -s "$ROOT/CLAUDE.md" ]; then
    cat > "$ROOT/CLAUDE.md" << 'EOF'
# Legendary Team 2026 Ultimate

@chief orchestrates. Specs in OpenSpec/. Run `/bootstrap` for full context.

## Quick Reference
- Rules: `.claude/rules/` (MANDATORY)
- Skills: `.claude/skills/` (best practices)
- Agents: `.claude/agents/` (25 specialists)
- Plans: `thoughts/shared/plans/`

## Confidence Routing
- ≥70%: Auto-proceed
- 40-69%: Queue for review
- <40%: Block for human

## Commands
`/bootstrap` `/review-queue` `/team-status` `/swarm-planner` `/emergency-stop`

Full docs: `Orchestration SOP.md`
EOF
    echo "✓ Created: $ROOT/CLAUDE.md"
else
    echo "⊘ Preserved existing: $ROOT/CLAUDE.md"
fi

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
  \"version\": \"2026-ultimate\",
  \"first_run_complete\": true,
  \"last_bootstrap\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  \"features\": [\"swarm-planner\", \"parallel-task\", \"spawn-subagent\", \"reflection\", \"iteration\"]
}"

safe_write "$CLAUDE/codebase-map.json" "{
  \"version\": \"1.0\",
  \"last_full_scan\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  \"files\": {}
}"

# Register hooks with Claude Code (settings.json)
if [ ! -f "$CLAUDE/settings.json" ]; then
    cat > "$CLAUDE/settings.json" << 'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/SessionStart.js",
        "timeout": 30
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/PreToolUse.js",
            "timeout": 30
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/PostToolUse.js",
            "timeout": 30
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/PreCompact.js",
        "timeout": 30
      }
    ],
    "SessionEnd": [
      {
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/SessionEnd.js",
        "timeout": 30
      }
    ]
  }
}
EOF
    echo "✓ Created: $CLAUDE/settings.json (hooks registered)"
else
    echo "⊘ Preserved existing: $CLAUDE/settings.json"
fi

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
# 8. CONTINUITY SYSTEM – v2026 UPGRADE (File-Based Memory)
# =============================================================================

echo "✓ Setting up continuity system (file-based memory)..."

# Create continuity directories
mkdir -p "$ROOT/thoughts/ledgers" \
         "$ROOT/thoughts/shared/handoffs" \
         "$ROOT/thoughts/shared/plans" \
         "$ROOT/thoughts/templates"

echo "✓ Continuity directories ready (ledgers, handoffs, plans)"

echo -e "\n2026 ULTIMATE LEGENDARY SCRIPT COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "NEW FEATURES:"
echo "  • @Planner, @Verifier, @ReflectionAgent"
echo "  • /swarm-planner, /parallel-task, /spawn-subagent"
echo "  • Auto-testing, linting, and reflection hooks"
echo "  • Enhanced iteration protocol"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Run: claude → /bootstrap"
echo "Your team is now perfect. Forever.\n"
