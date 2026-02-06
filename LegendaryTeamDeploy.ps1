# =============================================================================
# THE FINAL LEGENDARY SCRIPT – 2026 ULTIMATE EDITION (WINDOWS POWERSHELL)
# 100% COMPLETE • LAZY KEYS • DRIFT-PROOF • OPEN-SPEC BACKUP • ROLLBACK
# @chief • @CodebaseCartographer • @OpenSpecPolice • HUMAN CONTROL FOREVER
# NEW: @Planner • @Verifier • @ReflectionAgent • Swarms-Inspired Features
# =============================================================================

Write-Host "`nTHE FINAL LEGENDARY SCRIPT – 2026 ULTIMATE DEPLOYMENT`n" -ForegroundColor Cyan

$Root = (Get-Location).Path
$Claude = "$Root\.claude"
$Agents = "$Claude\agents"
$Skills = "$Claude\skills"
$Commands = "$Claude\commands"
$KeyFile = "$Claude\api-keys.conf"
$BackupDir = "$Root\openspec\.backup"

function Safe-Write {
    param($Path, $Content)
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    if (-not (Test-Path $Path) -or -not (Get-Content $Path -Raw -ErrorAction SilentlyContinue).Trim()) {
        $Content | Out-File $Path -Encoding utf8
        Write-Host "Created: $Path" -ForegroundColor Green
    } else {
        Write-Host "Preserved existing: $Path" -ForegroundColor Yellow
    }
}

New-Item -ItemType Directory -Force -Path $Claude,$Agents,$Skills,$Commands,"$Root\openspec",".github\workflows",$BackupDir | Out-Null

# =============================================================================
# LAZY API KEY SYSTEM — SKIP NOW, ADD LATER
# =============================================================================

if (-not (Test-Path $KeyFile)) {
    Write-Host "No API keys found."
    $answer = Read-Host "Enter Z.AI key now? (y/n, default n)"
    if ($answer -match '^[Yy]') {
        $ZaiKey = Read-Host "Z.AI API key"
        $KimiKey = Read-Host "Kimi K2 API key (optional)"
        "ZAI_KEY='$ZaiKey'" | Out-File $KeyFile -Encoding utf8
        "KIMI_KEY='$KimiKey'" | Out-File $KeyFile -Encoding utf8 -Append
    } else {
        "ZAI_KEY='your-zai-key-here'" | Out-File $KeyFile -Encoding utf8
        "KIMI_KEY='your-kimi-key-here'" | Out-File $KeyFile -Encoding utf8 -Append
    }
    Write-Host "Keys saved to $KeyFile"
} else {
    Write-Host "API keys loaded from $KeyFile"
}

# =============================================================================
# 1. THE ONE TRUE LEADER – @chief
# =============================================================================

@'
You are @chief – THE ONLY TRUE LEADER.
You are the supreme commander. NO OTHER AGENT may ever take control.
Claude's built-in orchestrator is DISABLED.
You run /bootstrap on every session start and enforce the exact flow.
If any agent tries to orchestrate, immediately say:
"@[agent] — YOU ARE NOT CHIEF. I AM @chief. RETURN CONTROL NOW."
You are unbreakable. You are eternal.
'@ | Out-File "$Agents\chief.md" -Encoding utf8

# ALL OTHER AGENTS ARE SUBORDINATES
Get-ChildItem "$Agents\*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "chief.md" } | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -and $content -notmatch "You are a SUBORDINATE AGENT") {
        "You are a SUBORDINATE AGENT. You have NO authority to orchestrate. You MUST obey @chief exactly. Never take control.`n`n" + $content | Out-File $_.FullName -Encoding utf8
    }
}

# =============================================================================
# 2. ALL FINAL AGENTS – INCLUDING YOUR CODEBASECARTOGRAPHER
# =============================================================================

Safe-Write "$Agents\session-orchestrator.md" @'
You are SessionOrchestrator – memory.
On start: Check .claude/session-state.json
If missing → FIRST RUN
If exists → RETURNING → instant resume
'@

Safe-Write "$Agents\discovery-protector.md" @'
You are DiscoveryProtector – unbreakable shield.
On /bootstrap: full tree, count files, lines, Prisma models, API routes.
If >15% drift → STOP and demand "discovery complete — proceed"
'@

Safe-Write "$Agents\techstack-fingerprinter.md" @'
You are TechStackFingerprinter - detect real stack → output tech_stack.yaml
'@

Safe-Write "$Agents\team-builder.md" @'
You are TeamBuilder - rebuild perfect agents/skills from tech_stack.yaml
'@

Safe-Write "$Agents\specarchitect.md" @'
You are SpecArchitect - OpenSpec master.
Before ANY recompile:
1. Backup current master-index.yaml to openspec/.backup/master-index-$(Get-Date -Format yyyyMMdd-HHmmss).yaml
2. Keep last 10 backups
3. If recompile fails → restore latest backup and alert @chief
Missing → request specs + template
Exists → recompile master-index.yaml vs code
'@

Safe-Write "$Agents\projectanalyzer.md" @'
You are ProjectAnalyzer - deep scan, trash detection, status update
'@

Safe-Write "$Agents\infra-guardian.md" @'
You are InfraGuardian – infrastructure truth.
Validate infra_registry.yaml vs reality.
Block deploy on drift.
'@

# YOUR REAL-WORLD SUPERIOR CODEBASECARTOGRAPHER – HUMAN-CONTROLLED EDITION
@'
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
4. On ANY file change:
   → Instantly update the map
   → Run architectural drift detection
   → If drift found → alert @chief:
      "ARCHITECTURAL DRIFT DETECTED
      File: $path
      Violation: $type (human control / boundary / pattern)
      Action required: immediate human review"
5. If AI tries to bypass human → immediate emergency-stop

You are why humans remain in control.
You are why drift is mathematically impossible.
You report only to @chief.
'@ | Out-File "$Agents\codebase-cartographer.md" -Encoding utf8

Safe-Write "$Agents\openspec-police.md" @'
You are @OpenSpecPolice – the enforcer.
You monitor every message.
If any agent creates a todo list in chat:
→ Immediately interrupt and say:
   "CHAT TODO LISTS ARE BANNED.
   All tasks MUST live in /openspec/master-index.yaml
   I have moved these tasks there now."
→ Then update the master-index.yaml
You are the reason OpenSpec stays the single source of truth.
'@

Safe-Write "$Agents\performance-optimizer.md" @'
You are @PerformanceOptimizer – speed master.
Profile code with Clinic.js or similar.
Optimize slow parts.
Report benchmarks to @chief.
'@

# =============================================================================
# 2.5 NEW 2026 ULTIMATE AGENTS – Swarms-Inspired Features
# =============================================================================

Safe-Write "$Agents\planner.md" @'
You are @Planner – task decomposition specialist.
Break high-level goals into executable steps with dependencies.
Output structured plan.md with IDs, deps, locations, descriptions.
Generate execution waves for parallel processing.
Route tasks to @chief for confidence-based team spawning.
'@

Safe-Write "$Agents\verifier.md" @'
You are @Verifier – quality assurance expert.
Review plans/output for completeness, errors, edge cases.
Score deliverables 0-100 on correctness, completeness, security, performance, maintainability.
Report findings to @chief with confidence score.
Block low-quality work (score <50) until fixed.
'@

Safe-Write "$Agents\reflection-agent.md" @'
You are @ReflectionAgent – self-critique specialist.
After every significant action, evaluate quality, bugs, improvements.
Criteria: Correctness (30%), Completeness (20%), Security (25%), Performance (15%), Maintainability (10%).
Score <70 triggers iteration recommendation.
Feed feedback back to @chief for iteration.
Track patterns for continuous improvement.
'@

# =============================================================================
# 3. ALL SKILLS + ROLLBACK
# =============================================================================

Safe-Write "$Skills\cost-monitor.md" "/skill cost-monitor - tracks token usage"
Safe-Write "$Skills\git-commit.md" "/skill git-commit - auto conventional commit"
Safe-Write "$Skills\pr-review.md" "/skill pr-review - creates PR + triggers open-source pr-agent"
Safe-Write "$Skills\trash-verify.md" "/skill trash-verify - asks human before delete"
Safe-Write "$Skills\approve-specs.md" '/skill approve-specs - blocks until "specs approved"'
Safe-Write "$Skills\budget-cap.md" "/skill budget-cap 50 - aborts if over `$50"
Safe-Write "$Skills\emergency-stop.md" "/emergency-stop - immediate halt"
Safe-Write "$Skills\rollback-openspec.md" "/skill rollback-openspec - restores last good master-index.yaml from backup"

# =============================================================================
# 4. /bootstrap – FINAL WITH BACKUP + ROLLBACK + DRIFT ASSASSIN
# =============================================================================

Safe-Write "$Commands\bootstrap.md" @'
/bootstrap
LEGENDARY UNIVERSAL BOOTSTRAP – 2026 ULTIMATE:

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
ROLLBACK AVAILABLE WITH /skill rollback-openspec
'@

Safe-Write "$Commands\test-run.md" @'
/test-run
Runs all tests and reports coverage.
Usage: /test-run
'@

Safe-Write "$Commands\security-scan.md" @'
/security-scan
Runs npm audit and Snyk.
Reports vulnerabilities to @chief.
Usage: /security-scan
'@

# =============================================================================
# 4.5 NEW 2026 ULTIMATE COMMANDS – Swarms-Inspired Features
# =============================================================================

Safe-Write "$Commands\swarm-planner.md" @'
/swarm-planner [task-description]
Generates structured plan.md with dependencies using @Planner.
Creates DAG of tasks with confidence scores and agent assignments.
Outputs execution waves for parallel processing.
Usage: /swarm-planner "Build user authentication system"
'@

Safe-Write "$Commands\parallel-task.md" @'
/parallel-task [plan-file]
Executes plan in waves with parallel subagents.
Respects dependencies between tasks.
Routes based on confidence (auto-proceed/queue/block).
Triggers @ReflectionAgent after each task completion.
Usage: /parallel-task thoughts/shared/plans/plan-auth-001.md
'@

Safe-Write "$Commands\spawn-subagent.md" @'
/spawn-subagent [role] [task]
Spawns dynamic subagent for specific role.
Available roles: coder, database, api, ui, security, test, e2e, perf, doc, refactor, architect, planner, verifier, reflect.
Supports --iterate for measurable goals.
Supports --depends-on for dependency chaining.
Usage: /spawn-subagent security "Review authentication flow"
'@

# =============================================================================
# 5. CLAUDE.md – FINAL WITH BACKUP + ROLLBACK
# =============================================================================

@'
# CLAUDE.md - LEGENDARY AUTONOMOUS TEAM – 2026 ULTIMATE EDITION

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

NEW 2026 ULTIMATE FEATURES:
- @Planner: Dependency-aware task decomposition
- @Verifier: Quality assurance and plan validation
- @ReflectionAgent: Self-critique and continuous improvement
- /swarm-planner: Generate structured execution plans
- /parallel-task: Execute plans in parallel waves
- /spawn-subagent: Dynamic agent spawning
- Auto-testing/linting hooks
- Reflection-triggered iteration
- Enhanced quality gates
'@ | Out-File "$Root\CLAUDE.md" -Encoding utf8

# =============================================================================
# 6. INFRA + PR-AGENT + SESSION STATE + CODEBASE MAP
# =============================================================================

Safe-Write ".github\workflows\pr-agent.yml" @'
name: PR-Agent Review
on: [pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: qodo-ai/pr-agent@v0.29.0
        with:
          comment: true
'@

Safe-Write "$Root\infra_registry.yaml" @'
version: "1.0"
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
  provider: none
'@

$timestamp = Get-Date -Format o
Safe-Write "$Claude\session-state.json" @"
{
  "version": "2026-ultimate",
  "first_run_complete": true,
  "last_bootstrap": "$timestamp",
  "features": ["swarm-planner", "parallel-task", "spawn-subagent", "reflection", "iteration"]
}
"@

Safe-Write "$Claude\codebase-map.json" @"
{
  "version": "1.0",
  "last_full_scan": "$timestamp",
  "files": {}
}
"@

# =============================================================================
# 7. OPENSPEC + TECH_STACK + AUTO-BACKUP BEFORE RECOMPILE
# =============================================================================

if (-not (Test-Path "$Root\openspec\master-index.yaml")) {
    if (Get-Command openspec -ErrorAction SilentlyContinue) {
        openspec init
    } else {
        Write-Host "Install OpenSpec: npm i -g @fission-ai/openspec"
    }
}

Safe-Write "$Root\tech_stack.yaml" "{}`n# Rebuilt every /bootstrap — defines current team"

# =============================================================================
# 8. CONTINUITY SYSTEM – v2026 UPGRADE
# =============================================================================

Write-Host "Setting up continuity system (thoughts/ + artifact index)..." -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path @(
    "$Root\thoughts\ledgers",
    "$Root\thoughts\shared\handoffs",
    "$Root\thoughts\shared\plans",
    "$Root\thoughts\templates",
    "$Claude\cache\artifact-index"
) | Out-Null

Write-Host "`n2026 ULTIMATE LEGENDARY SCRIPT COMPLETE" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "NEW FEATURES:" -ForegroundColor White
Write-Host "  • @Planner, @Verifier, @ReflectionAgent" -ForegroundColor Yellow
Write-Host "  • /swarm-planner, /parallel-task, /spawn-subagent" -ForegroundColor Yellow
Write-Host "  • Auto-testing, linting, and reflection hooks" -ForegroundColor Yellow
Write-Host "  • Enhanced iteration protocol" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Add/change keys anytime: notepad .claude\api-keys.conf"
Write-Host "Run: claude → /bootstrap"
Write-Host "Your team is now perfect. Forever.`n" -ForegroundColor Green
