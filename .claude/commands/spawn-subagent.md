# /spawn-subagent - Dynamic Agent Spawning

## Purpose
Spawns a specialized subagent dynamically for a specific task, enabling flexible team composition based on runtime requirements.

## Usage

```bash
/spawn-subagent [role] [task]
/spawn-subagent coder "Implement user profile API"
/spawn-subagent security "Review authentication flow"
/spawn-subagent database "Optimize slow queries"
```

## Available Roles

| Role | Agent | Specialization |
|------|-------|----------------|
| `coder` | @CodeAgent | General implementation |
| `database` | @DatabaseAgent | Schema, migrations, queries |
| `api` | @APIAgent | REST/GraphQL endpoints |
| `ui` | @UIAgent | Frontend components |
| `security` | @SecurityAgent | Security review, auth |
| `test` | @TestAgent | Unit/integration tests |
| `e2e` | @E2ERunner | End-to-end tests |
| `perf` | @PerformanceOptimizer | Performance optimization |
| `doc` | @DocAgent | Documentation |
| `refactor` | @RefactorAgent | Code refactoring |
| `architect` | @ArchitectureAgent | Architecture decisions |
| `planner` | @Planner | Task decomposition |
| `verifier` | @Verifier | Quality assurance |
| `reflect` | @ReflectionAgent | Self-critique |

## Options

| Option | Description |
|--------|-------------|
| --confidence N | Override confidence (0-100) |
| --iterate | Enable iteration mode |
| --max-iterations N | Max iterations (default: 3) |
| --priority high/med/low | Task priority |
| --depends-on ID | Declare dependency |
| --blocking | Wait for completion |
| --background | Run in background |

## Workflow

### 1. Agent Spawning

```
/spawn-subagent security "Review new payment endpoint"

Spawning @SecurityAgent...

Configuration:
├─ Task: Review new payment endpoint
├─ Confidence: Auto-detected (analyzing...)
├─ Priority: High (security-related)
├─ Mode: Standard (no iteration)
└─ Timeout: 30 minutes

Agent spawned successfully.
Team ID: team-sec-001
```

### 2. Confidence Analysis

Before execution, confidence is assessed:

```
@ConfidenceAgent analyzing task...

Analysis:
├─ Task type: Security review
├─ Codebase familiarity: High (similar patterns exist)
├─ Complexity: Medium
├─ Risk level: High (payment-related)
└─ Precedent: 3 similar reviews completed

Confidence Score: 65%
Routing: QUEUE FOR REVIEW (security-critical)

Human approval required. Added to review queue.
Run /approve-task team-sec-001 to proceed.
```

### 3. Execution

Once approved (or auto-proceed if ≥70%):

```
═══════════════════════════════════════════════════════════
SUBAGENT EXECUTION
═══════════════════════════════════════════════════════════

Team: team-sec-001
Agent: @SecurityAgent
Task: Review new payment endpoint

Progress:
├─ Reading code... ✓
├─ Analyzing security patterns... ✓
├─ Checking OWASP vulnerabilities...
│   ├─ SQL Injection: ✓ Safe
│   ├─ XSS: ✓ Safe
│   ├─ CSRF: ✓ Protected
│   ├─ Auth bypass: ✓ Safe
│   └─ Input validation: ⚠ Review needed
├─ Generating report...

Progress: ████████░░ 80%
```

### 4. Completion

```
═══════════════════════════════════════════════════════════
SUBAGENT COMPLETE
═══════════════════════════════════════════════════════════

Team: team-sec-001
Agent: @SecurityAgent
Status: ✓ COMPLETE

Results:
├─ Duration: 12 minutes
├─ Files reviewed: 8
├─ Issues found: 2
│   ├─ [MEDIUM] Input validation incomplete on amount field
│   └─ [LOW] Missing rate limiting
└─ Recommendations: 3

Report: thoughts/shared/reports/security-review-001.md

@ReflectionAgent Score: 88/100 (ACCEPTABLE)

Next steps:
1. Address medium-severity issue
2. Consider rate limiting for future sprint
```

## Multi-Agent Spawning

Spawn multiple agents simultaneously:

```bash
/spawn-subagent coder "Implement feature A" --background &
/spawn-subagent test "Write tests for feature A" --depends-on feature-a &
/spawn-subagent doc "Document feature A" --depends-on feature-a &
```

Or use compound command:

```bash
/spawn-subagent batch \
  --coder "Implement feature A" \
  --test "Write tests" --depends-on coder \
  --doc "Write docs" --depends-on coder
```

## Iteration Mode

Enable autonomous retry for measurable goals:

```bash
/spawn-subagent perf "Reduce API latency to <200ms" --iterate --max-iterations 5
```

Execution:

```
Iteration Mode Active
├─ Target: API latency < 200ms
├─ Max iterations: 5
└─ Current: 450ms

Iteration 1:
├─ Action: Added database index
├─ Result: 450ms → 280ms
└─ Status: Target not met, continuing

Iteration 2:
├─ Action: Implemented query caching
├─ Result: 280ms → 150ms
└─ Status: ✓ TARGET MET

Iterations used: 2/5
Final result: 150ms (target: <200ms)
```

## Error Handling

### Agent Failure

```
Subagent team-db-001 FAILED

Error: Migration conflict detected
├─ Conflicting migration: 20260122_add_user_email
└─ Reason: Column already exists

Recovery options:
1. /retry team-db-001 --fix-conflicts
2. /rollback team-db-001
3. /escalate team-db-001 (to @chief)

Dependent agents paused.
```

### Timeout

```
Subagent team-ui-001 TIMEOUT

Duration: 30 minutes (limit reached)
Progress: 65% complete

Options:
1. /extend team-ui-001 --timeout 15m
2. /save-progress team-ui-001 (checkpoint)
3. /abort team-ui-001
```

## Monitoring

Track spawned agents:

```bash
/team-status
```

```
╔═════════════════════════════════════════════════════════════╗
║ ACTIVE SUBAGENTS                                             ║
╠═════════════════════════════════════════════════════════════╣
║                                                              ║
║ team-sec-001 (@SecurityAgent)                                ║
║ ├─ Task: Review payment endpoint                             ║
║ ├─ Status: IN_PROGRESS                                       ║
║ ├─ Progress: ████████░░ 80%                                  ║
║ └─ ETA: 3 minutes                                            ║
║                                                              ║
║ team-db-001 (@DatabaseAgent)                                 ║
║ ├─ Task: Optimize user queries                               ║
║ ├─ Status: COMPLETE ✓                                        ║
║ └─ Duration: 8 minutes                                       ║
║                                                              ║
║ team-test-001 (@TestAgent)                                   ║
║ ├─ Task: Write integration tests                             ║
║ ├─ Status: QUEUED (waiting for team-sec-001)                 ║
║ └─ Depends on: team-sec-001                                  ║
║                                                              ║
╚═════════════════════════════════════════════════════════════╝
```

## Best Practices

1. **Use specific tasks** - Clear, measurable objectives
2. **Set appropriate timeouts** - Prevent runaway agents
3. **Declare dependencies** - Ensure correct execution order
4. **Use iteration for optimization** - Let agents iterate to targets
5. **Review security agents** - Always queue security work

## Related Commands

- `/swarm-planner` - Generate multi-task plan
- `/parallel-task` - Execute plan with multiple agents
- `/team-status` - Monitor all active agents
- `/review-queue` - View queued tasks
- `/emergency-stop` - Stop all agents

---

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
