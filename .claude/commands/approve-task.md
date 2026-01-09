# Approve Queued Task

Approve a task from the human review queue and trigger its execution.

## Usage

When you see a task ID from `/review-queue`, use this command to approve it:

```
/approve-task [task-id] [optional notes]
```

## What this command does

1. Runs the approval command via the review queue manager
2. Removes task from the review queue
3. Notifies @chief to spawn the appropriate team
4. Logs the approval decision for future confidence learning
5. Updates statistics (approval rate, wait time)

## Implementation

Execute the following:

```bash
node scripts/review-queue-manager.js approve {{TASK_ID}} "{{NOTES}}"
```

Where:
- `{{TASK_ID}}` is the review queue task ID (e.g., "review-001")
- `{{NOTES}}` are optional approval notes/modifications

After approval:
1. Display confirmation message
2. Show which team will handle the task
3. Provide estimated completion time
4. Notify that @chief will coordinate execution

Example output:

```
✅ Task Approved: OAuth 2.0 Integration

Details:
 • Task ID: review-001
 • Confidence: 45% → Upgraded to APPROVED
 • Wait time: 15 minutes
 • Approval notes: "Use Stripe Checkout, not raw API"

Next Steps:
🚀 Spawning Team 6: @SecurityAgent + @APIAgent
⏱️  Estimated completion: 25 minutes
📝 Decision logged for future confidence learning

@chief will now coordinate the execution and report back when complete.
```

Then notify @chief:

"@chief: Task review-001 has been approved by human. Please spawn the appropriate team and execute according to the plan at thoughts/shared/plans/[plan-file].md with the following approval notes: [notes]"
