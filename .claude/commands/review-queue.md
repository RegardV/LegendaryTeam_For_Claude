# Review Queue Management

Display and manage the human review queue for parallel autonomous operations.

## What this command does

Shows all tasks waiting for human review, including:
- Tasks with uncertain confidence scores (40-69%)
- Security-critical tasks
- Architecture decisions
- Infrastructure changes

## Usage

Run the review queue manager script and display the current queue:

```bash
node scripts/review-queue-manager.js list
```

Then provide a summary of:
1. Number of tasks in queue
2. Priority breakdown (high/medium/low)
3. Type breakdown (security/architecture/infrastructure)
4. Average wait time
5. Recommended action for each task

Format the output in a user-friendly way with:
- Clear task descriptions
- Confidence scores
- Uncertainty reasons
- Links to detailed plans
- Approval/reject commands

Example format:

```
╔═══════════════════════════════════════════════════════════╗
║ HUMAN REVIEW QUEUE - 3 Tasks Waiting                     ║
╚═══════════════════════════════════════════════════════════╝

🔴 [HIGH] OAuth 2.0 Integration
   Confidence: 45%
   Type: Security
   Waiting: 12 minutes
   Uncertainty:
    • First-time OAuth implementation
    • Security implications for user authentication
    • New architectural pattern
   Plan: thoughts/shared/plans/plan-oauth-security.md

   To approve: /approve-task review-001
   To reject:  /reject-task review-001

🟡 [MED] Microservices Architecture
   Confidence: 55%
   Type: Architecture
   Waiting: 8 minutes
   Uncertainty:
    • Major architectural change
    • Team needs microservices training
    • Cost implications ($350-750/month increase)
   Plan: thoughts/shared/plans/plan-microservices-architecture.md

   To approve: /approve-task review-002
   To reject:  /reject-task review-002

═══════════════════════════════════════════════════════════

Statistics:
 • Total queued: 3 tasks
 • Average wait: 10 minutes
 • High priority: 1
 • Medium priority: 2
 • Low priority: 0

Meanwhile, 5 autonomous teams are working on high-confidence tasks in parallel!
```

After displaying the queue, ask the user:
"Which task would you like to review first? You can:
- Read the detailed plan by asking me to open the plan file
- Approve a task with /approve-task [id]
- Reject a task with /reject-task [id]
- Get more details about a specific task"
