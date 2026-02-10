# Legendary Team 2026 Ultimate

**The Most Advanced Autonomous AI Engineering Team for Claude Code**

> Transform your `.claude` folder into a self-healing, memory-aware, production-grade autonomous engineering organization.

---

## What Is This?

The Legendary Team is a complete orchestration system for Claude Code that provides:

- **25 Specialized Agents** - From @chief (orchestrator) to @DatabaseAgent, @SecurityAgent, etc.
- **Confidence-Based Routing** - Auto-proceed (≥70%), queue for review (40-69%), or block (<40%)
- **File-Based Memory** - Ledgers, handoffs, and plans that survive context clears
- **Token Optimization** - 96.7% reduction with lite agents + self-escalation
- **Lifecycle Hooks** - SessionStart, PreToolUse, PostToolUse, PreCompact, SessionEnd

---

## Quick Start

**See [INSTALLATION.md](INSTALLATION.md) for complete installation instructions.**

```bash
# One-liner install into existing project
cd ~/your-project && \
git clone https://github.com/RegardV/LegendaryTeam_For_Claude .legendary-tmp && \
cp -r .legendary-tmp/.claude . && \
cp .legendary-tmp/CLAUDE.md .legendary-tmp/"Orchestration SOP.md" . && \
rm -rf .legendary-tmp && \
bash LegendaryTeamDeploy.sh
```

Then in Claude Code:
```
/bootstrap
```

---

## How It Works

### The Deploy Script (`LegendaryTeamDeploy.sh`)

The deploy script initializes your project with:

| Created | Purpose |
|---------|---------|
| `.claude/settings.json` | Registers hooks with Claude Code |
| `.claude/session-state.json` | Session tracking |
| `.claude/codebase-map.json` | File change tracking |
| `thoughts/` directories | Memory system (ledgers, handoffs, plans) |
| `CLAUDE.md` | Entry point (if not exists) |

**Important:** The script preserves existing files. It only creates stubs if files don't exist.

### The Hooks System

Hooks are registered in `.claude/settings.json` and fire automatically:

| Hook | When | Purpose |
|------|------|---------|
| `SessionStart.js` | Session begins | Load ledgers and handoffs |
| `PreToolUse.js` | Before Edit/Write | Validation, budget checks |
| `PostToolUse.js` | After Edit/Write | Track changes, update map |
| `PreCompact.js` | Before compaction | Block compaction, require handoff |
| `SessionEnd.js` | Session ends | Cleanup, extract learnings |

### The Agents

25 specialized agents in three tiers:

**Always Loaded:**
- `@chief` - Master orchestrator
- `@ConfidenceAgent` - Routes tasks by confidence score

**Loaded On-Demand:**
- `@DatabaseAgent`, `@UIAgent`, `@TestAgent`, `@SecurityAgent`, etc.

**Token Optimization:**
- `.claude/agents-lite/` - Minimal prompts (~60-100 words)
- `.claude/agents-full/` - Complete definitions (for self-escalation)

### The Memory System

File-based memory that survives context clears:

```
thoughts/
├── ledgers/              # Current session state
│   └── CONTINUITY_CLAUDE-*.md
├── shared/
│   ├── handoffs/         # Cross-session knowledge
│   │   └── handoff-*.md
│   └── plans/            # Execution plans
│       └── plan-*.md
└── templates/            # Standard formats
```

---

## File Structure

```
your-project/
├── .claude/
│   ├── agents/           # 25 agent definitions
│   ├── agents-lite/      # Token-optimized versions
│   ├── agents-full/      # Full definitions for escalation
│   ├── hooks/            # Lifecycle hooks (JS files)
│   ├── rules/            # Behavioral rules
│   ├── skills/           # Best practice patterns
│   ├── commands/         # Slash commands
│   ├── settings.json     # Hook registration
│   ├── session-state.json
│   └── codebase-map.json
├── thoughts/             # Memory system
├── OpenSpec/             # Specifications (if using)
├── CLAUDE.md             # Entry point
└── Orchestration SOP.md  # Full documentation
```

---

## Key Commands

| Command | Description |
|---------|-------------|
| `/bootstrap` | Initialize team, run on session start |
| `/review-queue` | Show tasks waiting for human review |
| `/team-status` | Show active agents and progress |
| `/approve-task [id]` | Approve a queued task |
| `/swarm-planner [task]` | Generate dependency-aware plan |
| `/emergency-stop` | Halt all operations |

---

## Confidence-Based Routing

Tasks are scored 0-100 and routed automatically:

| Score | Tier | Action |
|-------|------|--------|
| ≥70% | Auto-proceed | Executes immediately, no approval needed |
| 40-69% | Queue | Added to review queue, continues other work |
| <40% | Block | Requires human approval before proceeding |

**Scoring factors:**
- +40: Similar task succeeded before
- +30: Clear spec/requirements exist
- +20: Known patterns available
- -20: Security implications
- -30: Conflicting requirements
- -40: Destructive operations

---

## The 25 Agents

### Orchestration
- **@chief** - Master orchestrator, spawns teams, manages queue
- **@ConfidenceAgent** - Scores tasks, routes to tiers
- **@SessionOrchestrator** - Memory and continuity management

### Planning & Quality
- **@Planner** - Task decomposition with dependencies
- **@Verifier** - Quality assurance, plan validation
- **@ReflectionAgent** - Self-critique, continuous improvement

### Task Execution
- **@DatabaseAgent** - Schemas, migrations, CRUD
- **@UIAgent** - Components, styling, responsive design
- **@TestAgent** - Unit/integration tests (≥80% coverage)
- **@E2ERunner** - Playwright E2E tests
- **@SecurityAgent** - Auth, encryption, audits
- **@PerformanceOptimizer** - Profiling, benchmarking
- **@RefactorAgent** - Code cleanup, dead code removal
- **@DocAgent** - Documentation, README, API docs
- **@BugResolver** - Bug diagnosis, root cause analysis
- **@ArchitectureAgent** - System design decisions
- **@InfrastructureAgent** - Deployments, scaling

### Guardians
- **@CodebaseCartographer** - Tracks all file changes
- **@TechStackFingerprinter** - Detects technology stack
- **@DiscoveryProtector** - Drift detection, blocks on mismatch
- **@OpenSpecPolice** - Enforces specs as source of truth
- **@SpecArchitect** - Manages spec backups and rollbacks
- **@InfraGuardian** - Validates infrastructure config
- **@TeamBuilder** - Rebuilds agents from stack detection
- **@ProjectAnalyzer** - Deep scan, technical debt detection

---

## Documentation

| Document | Description |
|----------|-------------|
| **[INSTALLATION.md](INSTALLATION.md)** | Installation instructions |
| **[Orchestration SOP.md](Orchestration%20SOP.md)** | Complete operational guide |
| **[CLAUDE.md](CLAUDE.md)** | Entry point (read by Claude Code) |
| [.claude/hooks/README.md](.claude/hooks/README.md) | Hooks documentation |
| [thoughts/README.md](thoughts/README.md) | Memory system guide |

---

## Troubleshooting

### Hooks not firing
1. Check `.claude/settings.json` exists and is valid JSON
2. Verify hook files exist: `ls .claude/hooks/*.js`
3. Make hooks executable: `chmod +x .claude/hooks/*.js`

### Agents not found
1. Run the deploy script: `bash LegendaryTeamDeploy.sh`
2. Check agents exist: `ls .claude/agents/`

### Memory not persisting
1. Check `thoughts/` directories exist
2. Verify ledger files are being created
3. Run `/bootstrap` to initialize

---

## Philosophy

1. **Clear, Don't Compact** - Never compact context. Clear and restore from ledgers.
2. **Specs First** - Document before coding. OpenSpec is truth.
3. **Confidence Routing** - Let data decide what needs human review.
4. **Token Efficiency** - Lite agents with self-escalation when needed.
5. **Human Control** - AI assists, humans decide on critical paths.

---

## Version

**Version:** 2026-ultimate
**Status:** Production-ready
**Last Updated:** 2026-02-10

---

## License

See [LICENSE](LICENSE) file for details.

---

Built for [Claude Code](https://claude.ai/code) | [GitHub](https://github.com/RegardV/LegendaryTeam_For_Claude)
