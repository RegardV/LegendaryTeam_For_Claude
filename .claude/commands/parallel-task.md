# /parallel-task - Parallel Plan Execution

## Purpose
Executes a structured plan in parallel waves, spawning appropriate agents for each task based on dependencies and confidence routing.

## Usage

```bash
/parallel-task [plan-file]
/parallel-task thoughts/shared/plans/plan-auth-001.md
/parallel-task plan-auth-001  # Shorthand (searches plans folder)
/parallel-task --resume       # Resume last incomplete execution
```

## Options

| Option | Description |
|--------|-------------|
| --dry-run | Preview execution without running |
| --wave N | Start from specific wave |
| --resume | Resume interrupted execution |
| --sequential | Force sequential execution (no parallelism) |
| --verbose | Show detailed progress |

## Execution Flow

### 1. Plan Loading

```
Loading plan: thoughts/shared/plans/plan-auth-001.md

Plan Summary:
├─ Goal: Build user authentication system
├─ Tasks: 8
├─ Waves: 4
├─ Auto-proceed: 7
├─ Queued: 1 (OAuth - needs review)
└─ Blocked: 0

Ready to execute. Proceed? [Y/n]
```

### 2. Wave Execution

```
═══════════════════════════════════════════════════════════
WAVE 1 EXECUTION - Foundation
═══════════════════════════════════════════════════════════

Spawning 1 team:
🚀 Team 1: @DatabaseAgent → T1 (User schema)

Progress:
├─ T1: ████████░░ 80% Creating migrations...

Wave 1 Complete ✓
Duration: 5 minutes
Results: 1/1 successful

═══════════════════════════════════════════════════════════
WAVE 2 EXECUTION - Core Services
═══════════════════════════════════════════════════════════

Spawning 2 teams in parallel:
🚀 Team 2: @SecurityAgent → T2 (Auth service)
🚀 Team 3: @SecurityAgent → T4 (Password hashing)

Progress:
├─ T2: ██████████ 100% ✓ Complete
├─ T4: ████████░░ 80% Testing...

Wave 2 Complete ✓
Duration: 12 minutes
Results: 2/2 successful
```

### 3. Confidence-Based Routing

During execution, tasks are routed based on confidence:

```
Wave 3 Execution:

AUTO-PROCEED (confidence ≥70%):
├─ T3 (85%): @APIAgent → Spawning immediately
├─ T6 (80%): @UIAgent → Spawning immediately

QUEUED (confidence 40-69%):
├─ T5 (55%): OAuth Integration
│  └─ Added to review queue
│  └─ Continuing with other tasks (non-blocking)
│  └─ Run /approve-task T5 when ready

High-confidence work continues while T5 awaits review.
```

### 4. Quality Gates

After each wave:

```
Wave 3 Quality Gates:
├─ Tests: ✓ 156 passing, 0 failing
├─ Coverage: ✓ 84% (threshold: 80%)
├─ Lint: ✓ No errors
├─ Security: ✓ No vulnerabilities
└─ Build: ✓ Successful

All gates passed. Proceeding to Wave 4.
```

### 5. Reflection & Learning

After each task:

```
@ReflectionAgent evaluating T3 (API Endpoints):

Score: 85/100 (ACCEPTABLE)
├─ Correctness: 90%
├─ Completeness: 85%
├─ Security: 80%
└─ Performance: 85%

Issues found:
└─ [LOW] Consider adding request validation middleware

Iterate: NO (score above threshold)
```

## Progress Tracking

Real-time status via `/team-status`:

```
╔═════════════════════════════════════════════════════════════╗
║ PARALLEL EXECUTION STATUS                                    ║
╠═════════════════════════════════════════════════════════════╣
║ Plan: User Authentication System                             ║
║ Progress: Wave 3/4 (62% complete)                            ║
╠═════════════════════════════════════════════════════════════╣
║                                                              ║
║ ACTIVE TEAMS (3):                                            ║
║ ┌────────────────────────────────────────────────────────┐  ║
║ │ Team 4: @APIAgent                                       │  ║
║ │   Task: T3 - Create API endpoints                       │  ║
║ │   Progress: ██████████ 100% ✓                           │  ║
║ │   Duration: 15 min                                      │  ║
║ ├────────────────────────────────────────────────────────┤  ║
║ │ Team 5: @UIAgent                                        │  ║
║ │   Task: T6 - Auth UI components                         │  ║
║ │   Progress: ████████░░ 75%                              │  ║
║ │   ETA: 5 min                                            │  ║
║ └────────────────────────────────────────────────────────┘  ║
║                                                              ║
║ QUEUED (1):                                                  ║
║ └─ T5: OAuth Integration (awaiting review)                   ║
║                                                              ║
║ COMPLETED TODAY: 5 tasks                                     ║
║ PARALLEL EFFICIENCY: 3.2x faster                             ║
╚═════════════════════════════════════════════════════════════╝
```

## Error Handling

### Task Failure

```
Wave 3 Error:
❌ T3 (API Endpoints) FAILED

Error: Test failures in auth.test.ts
├─ 3 tests failing
└─ Coverage dropped to 72%

Action Options:
1. /retry T3 - Retry with same configuration
2. /iterate T3 - Trigger @ReflectionAgent iteration
3. /skip T3 - Skip and continue (blocks dependents)
4. /abort - Stop execution

Dependent tasks (T7, T8) paused until resolved.
```

### Auto-Recovery

```
Attempting auto-recovery for T3:

1. Running @ReflectionAgent analysis...
   └─ Issue identified: Missing mock for external service

2. Applying fix...
   └─ Added mock in test setup

3. Re-running tests...
   └─ 156 passing, 0 failing ✓

4. T3 recovered successfully. Resuming Wave 3.
```

## Completion Summary

```
═══════════════════════════════════════════════════════════
EXECUTION COMPLETE
═══════════════════════════════════════════════════════════

Plan: User Authentication System
Status: ✓ SUCCESS (with 1 pending review)

Results:
├─ Total Tasks: 8
├─ Completed: 7
├─ Pending Review: 1 (T5 - OAuth)
├─ Failed: 0
└─ Skipped: 0

Quality Summary:
├─ Test Coverage: 86% ✓
├─ Security Scan: Passed ✓
├─ Performance: Within targets ✓
└─ Build: Successful ✓

Duration: 45 minutes (vs 2+ hours sequential)
Parallel Efficiency: 2.7x faster

Files Modified: 24
Lines Added: 1,250
Lines Removed: 50

Next Steps:
1. Review T5 (OAuth): /review-queue
2. Run E2E tests: /e2e
3. Create PR: /skill pr-review
```

## State Persistence

Execution state is saved for resume capability:

```json
// .claude/cache/execution-state.json
{
  "plan_id": "auth-001",
  "status": "in_progress",
  "current_wave": 3,
  "completed_tasks": ["T1", "T2", "T3", "T4"],
  "active_tasks": ["T6"],
  "queued_tasks": ["T5"],
  "pending_tasks": ["T7", "T8"],
  "checkpoint": "2026-01-22T10:45:00Z"
}
```

Resume with: `/parallel-task --resume`

## Related Commands

- `/swarm-planner` - Generate execution plan
- `/team-status` - Monitor active teams
- `/review-queue` - View/approve queued tasks
- `/approve-task` - Approve queued task
- `/emergency-stop` - Stop all execution

---

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
