# Team Status

Display the status of all active parallel autonomous teams.

## What this command does

Shows real-time status of:
- Active autonomous execution teams (currently working)
- Completed teams (finished today)
- Queued tasks waiting for review
- Parallel efficiency metrics

## Implementation

Read and display the team status from:

```bash
cat .claude/cache/team-status.json
```

Then format in a user-friendly dashboard format:

```
╔═══════════════════════════════════════════════════════════╗
║ PARALLEL AUTONOMOUS TEAMS STATUS                          ║
╠═══════════════════════════════════════════════════════════╣
║ 🟢 ACTIVE TEAMS (5)                                       ║
╚═══════════════════════════════════════════════════════════╝

Team 1: @DatabaseAgent
  Task: Create orders table
  Progress: ████████░░ 80%
  Started: 10 minutes ago
  ETA: 2 minutes
  Files: migrations/003_create_orders.sql

Team 2: @UIAgent
  Task: ProductCard component
  Progress: ██████████ 100% ✓
  Completed: 2 minutes ago
  Files: components/ProductCard.tsx, components/ProductCard.test.tsx

Team 3: @APIAgent
  Task: Order endpoints
  Progress: ██████░░░░ 60%
  Started: 15 minutes ago
  ETA: 10 minutes
  Files: routes/orders.ts

Team 4: @TestAgent
  Task: Integration tests for checkout
  Progress: ████░░░░░░ 40%
  Started: 8 minutes ago
  ETA: 12 minutes
  Files: tests/integration/checkout.test.ts

Team 5: @RefactorAgent
  Task: Extract error handler from UserController
  Progress: ███████░░░ 70%
  Started: 12 minutes ago
  ETA: 5 minutes
  Files: controllers/UserController.ts

═══════════════════════════════════════════════════════════

🟡 HUMAN REVIEW QUEUE (2)

[HIGH] OAuth integration        ⏱️  Waiting 12 min
[MED]  Microservices split      ⏱️  Waiting 8 min

═══════════════════════════════════════════════════════════

📊 TODAY'S METRICS

Completed: 12 tasks
Average wait time: 8 minutes
Parallel efficiency: 5.2x faster
Auto-proceed accuracy: 95% (19/20 succeeded)

═══════════════════════════════════════════════════════════

Commands:
  /review-queue   - Review queued tasks
  /team-status    - Refresh this view (this command)
  /approve-task   - Approve a queued task
  /reject-task    - Reject a queued task
```

If the team-status.json file doesn't exist, create it with initial structure:

```json
{
  "version": "2026-legendary-v2.0",
  "active_teams": [],
  "completed_today": 0,
  "average_wait_time_minutes": 0,
  "parallel_efficiency": 1.0,
  "auto_proceed_accuracy": {
    "total": 0,
    "succeeded": 0,
    "failed": 0,
    "rate": 0
  }
}
```

Then inform the user:
"No active teams yet. Teams will appear here when @chief spawns them for parallel execution. Try running a task to see teams in action!"
