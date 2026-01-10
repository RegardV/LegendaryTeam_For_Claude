#!/usr/bin/env node
/**
 * Review Queue Manager - Legendary Team v2026
 *
 * Manages human review queue for parallel autonomous operation
 *
 * Commands:
 *   add       - Add task to review queue
 *   approve   - Approve queued task
 *   reject    - Reject queued task
 *   list      - List all queued tasks
 *   stats     - Show queue statistics
 *   clean     - Remove old completed items from history
 */

const fs = require('fs');
const path = require('path');

// =============================================================================
// Configuration
// =============================================================================

const ROOT = process.cwd();
const QUEUE_FILE = path.join(ROOT, 'thoughts', 'shared', 'review-queue.json');
const PLANS_DIR = path.join(ROOT, 'thoughts', 'shared', 'plans');

// =============================================================================
// Helper Functions
// =============================================================================

function readQueue() {
  try {
    if (!fs.existsSync(QUEUE_FILE)) {
      return {
        version: '2026-legendary-v1.0',
        lastUpdated: new Date().toISOString(),
        queue: [],
        statistics: {
          totalQueued: 0,
          totalApproved: 0,
          totalRejected: 0,
          averageWaitTimeMinutes: 0,
          longestWaitTimeMinutes: 0
        },
        history: []
      };
    }
    return JSON.parse(fs.readFileSync(QUEUE_FILE, 'utf8'));
  } catch (err) {
    console.error(`Error reading queue: ${err.message}`);
    process.exit(1);
  }
}

function writeQueue(data) {
  try {
    data.lastUpdated = new Date().toISOString();
    const dir = path.dirname(QUEUE_FILE);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(QUEUE_FILE, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (err) {
    console.error(`Error writing queue: ${err.message}`);
    return false;
  }
}

function generateId(prefix = 'review') {
  const timestamp = Date.now();
  const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
  return `${prefix}-${timestamp}-${random}`;
}

function calculateWaitTime(createdAt) {
  const created = new Date(createdAt);
  const now = new Date();
  return Math.round((now - created) / (1000 * 60)); // Minutes
}

function formatDuration(minutes) {
  if (minutes < 60) {
    return `${minutes} min`;
  }
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return `${hours}h ${mins}m`;
}

// =============================================================================
// Commands
// =============================================================================

function addToQueue(options) {
  const {
    task,
    type = 'general',
    priority = 'medium',
    confidenceScore = 50,
    uncertaintyReasons = [],
    planFile = null,
    blockedTasks = [],
    estimatedReviewTime = '15 min'
  } = options;

  if (!task) {
    console.error('Error: Task description is required');
    process.exit(1);
  }

  const queue = readQueue();

  const item = {
    id: generateId('review'),
    priority: priority.toLowerCase(),
    type: type.toLowerCase(),
    task,
    confidenceScore,
    createdAt: new Date().toISOString(),
    planFile,
    uncertaintyReasons,
    blockedTasks,
    estimatedReviewTime,
    status: 'pending'
  };

  queue.queue.push(item);
  queue.statistics.totalQueued++;

  // Sort queue by priority (high -> medium -> low)
  const priorityOrder = { high: 0, medium: 1, low: 2 };
  queue.queue.sort((a, b) => {
    return priorityOrder[a.priority] - priorityOrder[b.priority];
  });

  if (writeQueue(queue)) {
    console.log('✓ Task added to review queue');
    console.log(`  ID: ${item.id}`);
    console.log(`  Priority: ${item.priority.toUpperCase()}`);
    console.log(`  Type: ${item.type}`);
    console.log(`  Confidence: ${item.confidenceScore}%`);
    if (planFile) {
      console.log(`  Plan: ${planFile}`);
    }
    console.log('');
    console.log(`Current queue size: ${queue.queue.length} tasks`);
  }
}

function approveTask(taskId, notes = null) {
  const queue = readQueue();
  const itemIndex = queue.queue.findIndex(item => item.id === taskId);

  if (itemIndex === -1) {
    console.error(`Error: Task ${taskId} not found in queue`);
    process.exit(1);
  }

  const item = queue.queue[itemIndex];
  const waitTime = calculateWaitTime(item.createdAt);

  // Move to history
  queue.history.push({
    ...item,
    status: 'approved',
    approvedAt: new Date().toISOString(),
    waitTimeMinutes: waitTime,
    notes
  });

  // Remove from queue
  queue.queue.splice(itemIndex, 1);

  // Update statistics
  queue.statistics.totalApproved++;
  const totalWaitTime = queue.history
    .filter(h => h.status === 'approved')
    .reduce((sum, h) => sum + (h.waitTimeMinutes || 0), 0);
  queue.statistics.averageWaitTimeMinutes = Math.round(
    totalWaitTime / queue.statistics.totalApproved
  );
  queue.statistics.longestWaitTimeMinutes = Math.max(
    queue.statistics.longestWaitTimeMinutes,
    waitTime
  );

  if (writeQueue(queue)) {
    console.log(`✓ Task ${taskId} APPROVED`);
    console.log(`  Task: ${item.task}`);
    console.log(`  Wait time: ${formatDuration(waitTime)}`);
    if (notes) {
      console.log(`  Notes: ${notes}`);
    }
    if (item.planFile) {
      console.log(`  Plan: ${item.planFile}`);
    }
    console.log('');
    console.log('Ready for team execution!');
  }
}

function rejectTask(taskId, reason = null) {
  const queue = readQueue();
  const itemIndex = queue.queue.findIndex(item => item.id === taskId);

  if (itemIndex === -1) {
    console.error(`Error: Task ${taskId} not found in queue`);
    process.exit(1);
  }

  const item = queue.queue[itemIndex];
  const waitTime = calculateWaitTime(item.createdAt);

  // Move to history
  queue.history.push({
    ...item,
    status: 'rejected',
    rejectedAt: new Date().toISOString(),
    waitTimeMinutes: waitTime,
    rejectionReason: reason
  });

  // Remove from queue
  queue.queue.splice(itemIndex, 1);

  // Update statistics
  queue.statistics.totalRejected++;

  if (writeQueue(queue)) {
    console.log(`✗ Task ${taskId} REJECTED`);
    console.log(`  Task: ${item.task}`);
    console.log(`  Wait time: ${formatDuration(waitTime)}`);
    if (reason) {
      console.log(`  Reason: ${reason}`);
    }
    console.log('');
    console.log('Task will not be executed.');
  }
}

function listQueue() {
  const queue = readQueue();

  if (queue.queue.length === 0) {
    console.log('╔═══════════════════════════════════════════════════════════╗');
    console.log('║ HUMAN REVIEW QUEUE - EMPTY                                ║');
    console.log('╚═══════════════════════════════════════════════════════════╝');
    console.log('');
    console.log('✓ No tasks waiting for review');
    console.log('  All high-confidence work is proceeding autonomously!');
    return;
  }

  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║ HUMAN REVIEW QUEUE                                        ║');
  console.log('╠═══════════════════════════════════════════════════════════╣');
  console.log(`║ ${queue.queue.length} task(s) waiting for your review${' '.repeat(Math.max(0, 31 - queue.queue.length.toString().length))}║`);
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');

  queue.queue.forEach((item, index) => {
    const waitTime = calculateWaitTime(item.createdAt);
    const priorityIcon = {
      high: '🔴',
      medium: '🟡',
      low: '🟢'
    }[item.priority] || '⚪';

    console.log(`${priorityIcon} [${item.priority.toUpperCase()}] ${item.task}`);
    console.log(`  ID: ${item.id}`);
    console.log(`  Type: ${item.type}`);
    console.log(`  Confidence: ${item.confidenceScore}%`);
    console.log(`  Waiting: ${formatDuration(waitTime)}`);
    console.log(`  Estimated review: ${item.estimatedReviewTime}`);

    if (item.uncertaintyReasons && item.uncertaintyReasons.length > 0) {
      console.log('  Uncertainty reasons:');
      item.uncertaintyReasons.forEach(reason => {
        console.log(`    • ${reason}`);
      });
    }

    if (item.planFile) {
      console.log(`  Plan: ${item.planFile}`);
    }

    if (item.blockedTasks && item.blockedTasks.length > 0) {
      console.log(`  Blocks: ${item.blockedTasks.join(', ')}`);
    }

    console.log('');
    console.log(`  Actions:`);
    console.log(`    • Approve: node scripts/review-queue-manager.js approve ${item.id} ["notes"]`);
    console.log(`    • Reject:  node scripts/review-queue-manager.js reject ${item.id} ["reason"]`);

    if (index < queue.queue.length - 1) {
      console.log('');
      console.log('───────────────────────────────────────────────────────────');
      console.log('');
    }
  });
}

function showStats() {
  const queue = readQueue();
  const stats = queue.statistics;

  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║ REVIEW QUEUE STATISTICS                                   ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');
  console.log('Current Queue:');
  console.log(`  📋 Tasks pending: ${queue.queue.length}`);
  console.log('');
  console.log('All-Time Statistics:');
  console.log(`  ✅ Total approved: ${stats.totalApproved}`);
  console.log(`  ❌ Total rejected: ${stats.totalRejected}`);
  console.log(`  📊 Total queued: ${stats.totalQueued}`);
  console.log('');
  console.log('Wait Times:');
  console.log(`  ⏱️  Average: ${formatDuration(stats.averageWaitTimeMinutes)}`);
  console.log(`  ⏱️  Longest: ${formatDuration(stats.longestWaitTimeMinutes)}`);
  console.log('');

  if (stats.totalQueued > 0) {
    const approvalRate = Math.round((stats.totalApproved / stats.totalQueued) * 100);
    console.log('Approval Rate:');
    console.log(`  ✓ ${approvalRate}% approved`);
    console.log('');
  }

  // Priority breakdown
  const priorityCounts = queue.queue.reduce((counts, item) => {
    counts[item.priority] = (counts[item.priority] || 0) + 1;
    return counts;
  }, {});

  if (Object.keys(priorityCounts).length > 0) {
    console.log('Current Queue by Priority:');
    if (priorityCounts.high) console.log(`  🔴 High: ${priorityCounts.high}`);
    if (priorityCounts.medium) console.log(`  🟡 Medium: ${priorityCounts.medium}`);
    if (priorityCounts.low) console.log(`  🟢 Low: ${priorityCounts.low}`);
    console.log('');
  }

  // Type breakdown
  const typeCounts = queue.queue.reduce((counts, item) => {
    counts[item.type] = (counts[item.type] || 0) + 1;
    return counts;
  }, {});

  if (Object.keys(typeCounts).length > 0) {
    console.log('Current Queue by Type:');
    Object.entries(typeCounts).forEach(([type, count]) => {
      console.log(`  • ${type}: ${count}`);
    });
    console.log('');
  }
}

function cleanHistory(daysOld = 30) {
  const queue = readQueue();
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - daysOld);

  const originalLength = queue.history.length;
  queue.history = queue.history.filter(item => {
    const itemDate = new Date(item.approvedAt || item.rejectedAt || item.createdAt);
    return itemDate > cutoffDate;
  });

  const removed = originalLength - queue.history.length;

  if (writeQueue(queue)) {
    console.log(`✓ Cleaned ${removed} old items from history`);
    console.log(`  History now contains: ${queue.history.length} items`);
  }
}

// =============================================================================
// CLI Interface
// =============================================================================

function showHelp() {
  console.log('Review Queue Manager - Legendary Team v2026');
  console.log('');
  console.log('Usage: node scripts/review-queue-manager.js <command> [options]');
  console.log('');
  console.log('Commands:');
  console.log('  add <task>              Add task to review queue');
  console.log('    --type <type>         Task type (security/architecture/infrastructure/general)');
  console.log('    --priority <priority> Priority level (high/medium/low)');
  console.log('    --confidence <score>  Confidence score (0-100)');
  console.log('    --plan <file>         Path to plan file');
  console.log('    --reasons <reasons>   Uncertainty reasons (comma-separated)');
  console.log('');
  console.log('  approve <id> [notes]    Approve queued task');
  console.log('  reject <id> [reason]    Reject queued task');
  console.log('  list                    List all queued tasks');
  console.log('  stats                   Show queue statistics');
  console.log('  clean [days]            Remove history older than N days (default: 30)');
  console.log('  help                    Show this help message');
  console.log('');
  console.log('Examples:');
  console.log('  node scripts/review-queue-manager.js list');
  console.log('  node scripts/review-queue-manager.js approve review-1234567890-123');
  console.log('  node scripts/review-queue-manager.js stats');
  console.log('');
}

// =============================================================================
// Main
// =============================================================================

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === 'help' || args[0] === '--help' || args[0] === '-h') {
    showHelp();
    return;
  }

  const command = args[0];

  switch (command) {
    case 'add': {
      const task = args[1];
      const options = { task };

      for (let i = 2; i < args.length; i += 2) {
        const key = args[i].replace(/^--/, '');
        const value = args[i + 1];

        if (key === 'type') options.type = value;
        if (key === 'priority') options.priority = value;
        if (key === 'confidence') options.confidenceScore = parseInt(value);
        if (key === 'plan') options.planFile = value;
        if (key === 'reasons') options.uncertaintyReasons = value.split(',').map(r => r.trim());
      }

      addToQueue(options);
      break;
    }

    case 'approve': {
      const taskId = args[1];
      const notes = args.slice(2).join(' ') || null;
      approveTask(taskId, notes);
      break;
    }

    case 'reject': {
      const taskId = args[1];
      const reason = args.slice(2).join(' ') || null;
      rejectTask(taskId, reason);
      break;
    }

    case 'list':
      listQueue();
      break;

    case 'stats':
      showStats();
      break;

    case 'clean': {
      const days = parseInt(args[1]) || 30;
      cleanHistory(days);
      break;
    }

    default:
      console.error(`Unknown command: ${command}`);
      console.log('Run with "help" for usage information');
      process.exit(1);
  }
}

// Execute
main();
