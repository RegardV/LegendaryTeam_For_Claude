# Reject Queued Task

Reject a task from the human review queue and prevent its execution.

## Usage

When you see a task ID from `/review-queue`, use this command to reject it:

```
/reject-task [task-id] [optional reason]
```

## What this command does

1. Runs the rejection command via the review queue manager
2. Removes task from the review queue
3. Notifies @chief that task is rejected
4. Logs the rejection decision for future confidence learning
5. Updates statistics (rejection rate, reasons)

## Implementation

Execute the following:

```bash
node scripts/review-queue-manager.js reject {{TASK_ID}} "{{REASON}}"
```

Where:
- `{{TASK_ID}}` is the review queue task ID (e.g., "review-002")
- `{{REASON}}` is optional rejection reason

After rejection:
1. Display confirmation message
2. Ask if alternative approach desired
3. Update @chief's confidence model
4. Log for future learning

Example output:

```
❌ Task Rejected: Microservices Architecture

Details:
 • Task ID: review-002
 • Confidence: 55%
 • Wait time: 20 minutes
 • Rejection reason: "Timeline too long, prefer modular monolith approach first"

Impact:
📉 Future similar tasks will have reduced confidence
📝 Decision logged for learning
🔄 Blocked dependent tasks: payment-service, notification-service

@chief has been notified and will adjust confidence model accordingly.

Would you like to:
1. Propose an alternative approach?
2. Request a revised plan with different parameters?
3. Defer this task to a later phase?
```

Then notify @chief:

"@chief: Task review-002 has been rejected by human with reason: [reason]. Please:
1. Update confidence model for similar tasks
2. Log rejection for future learning
3. If dependent tasks exist, queue them for alternative approaches"
