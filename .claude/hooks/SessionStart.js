#!/usr/bin/env node
/**
 * SessionStart Hook - Legendary Team v2026
 *
 * Fires when: Session starts, after /clear, after compaction
 * Purpose: Auto-load continuity state (ledgers + handoffs)
 *
 * This hook implements the "Clear, Don't Compact" philosophy by automatically
 * restoring context from ledgers and handoffs.
 */

const fs = require('fs');
const path = require('path');

// =============================================================================
// Configuration
// =============================================================================

const ROOT = process.cwd();
const THOUGHTS_DIR = path.join(ROOT, 'thoughts');
const LEDGERS_DIR = path.join(THOUGHTS_DIR, 'ledgers');
const HANDOFFS_DIR = path.join(THOUGHTS_DIR, 'shared', 'handoffs');
const SESSION_STATE_FILE = path.join(ROOT, '.claude', 'session-state.json');

const CONFIG = {
  autoLoadLedger: true,
  autoLoadHandoff: true,
  showWelcomeMessage: true,
  maxLedgerAge: 24 * 60 * 60 * 1000, // 24 hours in ms
  debug: false
};

// =============================================================================
// Helper Functions
// =============================================================================

function log(message, level = 'info') {
  if (CONFIG.debug || level === 'error') {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] [SessionStart] ${level.toUpperCase()}: ${message}\n`;

    try {
      const logFile = path.join(ROOT, '.claude', 'hooks', 'debug.log');
      fs.appendFileSync(logFile, logMessage);
    } catch (err) {
      // Silently fail if can't write log
    }
  }
}

function fileExists(filePath) {
  try {
    return fs.existsSync(filePath) && fs.statSync(filePath).isFile();
  } catch {
    return false;
  }
}

function readFile(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch (err) {
    log(`Error reading file ${filePath}: ${err.message}`, 'error');
    return null;
  }
}

function readJSON(filePath) {
  const content = readFile(filePath);
  if (!content) return null;

  try {
    return JSON.parse(content);
  } catch (err) {
    log(`Error parsing JSON from ${filePath}: ${err.message}`, 'error');
    return null;
  }
}

function writeJSON(filePath, data) {
  try {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (err) {
    log(`Error writing JSON to ${filePath}: ${err.message}`, 'error');
    return false;
  }
}

function formatDate(timestamp) {
  const date = new Date(timestamp);
  const now = new Date();
  const diffMs = now - date;
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);

  if (diffMins < 1) return 'just now';
  if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? 's' : ''} ago`;
  if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
  return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
}

// =============================================================================
// Ledger Functions
// =============================================================================

function findCurrentLedger() {
  if (!fs.existsSync(LEDGERS_DIR)) {
    log('Ledgers directory not found');
    return null;
  }

  try {
    const files = fs.readdirSync(LEDGERS_DIR)
      .filter(f => f.startsWith('CONTINUITY_CLAUDE-') && f.endsWith('.md'))
      .map(f => ({
        name: f,
        path: path.join(LEDGERS_DIR, f),
        mtime: fs.statSync(path.join(LEDGERS_DIR, f)).mtime
      }))
      .filter(f => {
        // Only consider ledgers from last 24 hours
        const age = Date.now() - f.mtime.getTime();
        return age < CONFIG.maxLedgerAge;
      })
      .sort((a, b) => b.mtime - a.mtime); // Most recent first

    return files.length > 0 ? files[0] : null;
  } catch (err) {
    log(`Error finding current ledger: ${err.message}`, 'error');
    return null;
  }
}

function loadLedger(ledgerFile) {
  const content = readFile(ledgerFile.path);
  if (!content) return null;

  // Parse key information from ledger
  const goalMatch = content.match(/##\s+🎯\s+Goal\s+([\s\S]*?)(?=##|$)/i);
  const completedMatch = content.match(/##\s+✅\s+Completed Work\s+([\s\S]*?)(?=##|$)/i);
  const currentFocusMatch = content.match(/##\s+🎯\s+Current Focus\s+([\s\S]*?)(?=##|$)/i);
  const nextStepsMatch = content.match(/##\s+📋\s+Next Steps\s+([\s\S]*?)(?=##|$)/i);

  return {
    file: ledgerFile.name,
    lastModified: ledgerFile.mtime,
    goal: goalMatch ? goalMatch[1].trim().substring(0, 200) : 'Not specified',
    completed: completedMatch ? completedMatch[1].trim().split('\n').filter(l => l.trim()).length : 0,
    currentFocus: currentFocusMatch ? currentFocusMatch[1].trim().substring(0, 100) : 'Not specified',
    nextSteps: nextStepsMatch ? nextStepsMatch[1].trim().split('\n').filter(l => l.trim() && l.includes('**')).length : 0,
    content: content
  };
}

// =============================================================================
// Handoff Functions
// =============================================================================

function findLatestHandoff() {
  if (!fs.existsSync(HANDOFFS_DIR)) {
    log('Handoffs directory not found');
    return null;
  }

  try {
    const files = fs.readdirSync(HANDOFFS_DIR)
      .filter(f => f.startsWith('handoff-') && f.endsWith('.md'))
      .map(f => ({
        name: f,
        path: path.join(HANDOFFS_DIR, f),
        mtime: fs.statSync(path.join(HANDOFFS_DIR, f)).mtime
      }))
      .sort((a, b) => b.mtime - a.mtime); // Most recent first

    return files.length > 0 ? files[0] : null;
  } catch (err) {
    log(`Error finding latest handoff: ${err.message}`, 'error');
    return null;
  }
}

function loadHandoff(handoffFile) {
  const content = readFile(handoffFile.path);
  if (!content) return null;

  // Parse key information from handoff
  const titleMatch = content.match(/^#\s+Handoff\s+-\s+(.+)$/m);
  const outcomeMatch = content.match(/\*\*Outcome\*\*:\s+.*?(SUCCEEDED|PARTIAL|FAILED)/i);
  const completionMatch = content.match(/\*\*Completion\*\*:\s+\[?(\d+)%/i);
  const summaryMatch = content.match(/##\s+📋\s+Executive Summary\s+([\s\S]*?)(?=##|$)/i);
  const nextStepsMatch = content.match(/##\s+📋\s+Next Steps\s+([\s\S]*?)(?=##|$)/i);

  return {
    file: handoffFile.name,
    lastModified: handoffFile.mtime,
    title: titleMatch ? titleMatch[1].trim() : 'Unknown',
    outcome: outcomeMatch ? outcomeMatch[1] : 'UNKNOWN',
    completion: completionMatch ? parseInt(completionMatch[1]) : 0,
    summary: summaryMatch ? summaryMatch[1].trim().substring(0, 200) : 'Not available',
    nextSteps: nextStepsMatch ? nextStepsMatch[1].trim().split('\n').filter(l => l.trim() && l.match(/^\d+\./)).length : 0,
    content: content
  };
}

// =============================================================================
// Session State Functions
// =============================================================================

function getSessionState() {
  if (!fileExists(SESSION_STATE_FILE)) {
    return {
      version: '2026-legendary-continuity',
      first_run_complete: false,
      sessions: []
    };
  }
  return readJSON(SESSION_STATE_FILE) || {};
}

function updateSessionState(updates) {
  const state = getSessionState();
  const newState = { ...state, ...updates, last_updated: new Date().toISOString() };
  return writeJSON(SESSION_STATE_FILE, newState);
}

// =============================================================================
// Main Hook Logic
// =============================================================================

function main() {
  log('SessionStart hook triggered');

  const output = [];
  let ledgerInfo = null;
  let handoffInfo = null;

  // Update session state
  const sessionState = getSessionState();
  const sessionId = `session-${Date.now()}`;
  updateSessionState({
    current_session_id: sessionId,
    last_session_start: new Date().toISOString()
  });

  log(`New session started: ${sessionId}`);

  // ===== Load Ledger =====
  if (CONFIG.autoLoadLedger) {
    const currentLedger = findCurrentLedger();
    if (currentLedger) {
      ledgerInfo = loadLedger(currentLedger);
      if (ledgerInfo) {
        log(`Loaded ledger: ${ledgerInfo.file}`);
      }
    } else {
      log('No current ledger found');
    }
  }

  // ===== Load Handoff =====
  if (CONFIG.autoLoadHandoff) {
    // Only auto-load handoff if this is a new day or no ledger exists
    const lastSessionDate = sessionState.last_session_start ? new Date(sessionState.last_session_start).toDateString() : null;
    const today = new Date().toDateString();
    const isNewDay = lastSessionDate !== today;

    if (isNewDay || !ledgerInfo) {
      const latestHandoff = findLatestHandoff();
      if (latestHandoff) {
        // Only load if recent (within 7 days)
        const age = Date.now() - latestHandoff.mtime.getTime();
        const maxAge = 7 * 24 * 60 * 60 * 1000; // 7 days

        if (age < maxAge) {
          handoffInfo = loadHandoff(latestHandoff);
          if (handoffInfo) {
            log(`Loaded handoff: ${handoffInfo.file}`);
          }
        } else {
          log(`Handoff too old (${Math.floor(age / (24 * 60 * 60 * 1000))} days), skipping`);
        }
      } else {
        log('No handoff found');
      }
    }
  }

  // ===== Generate Output =====
  if (CONFIG.showWelcomeMessage && (ledgerInfo || handoffInfo)) {
    output.push('');
    output.push('═══════════════════════════════════════════════════════════════');
    output.push('🔄  CONTINUITY RESTORED - Legendary Team v2026');
    output.push('═══════════════════════════════════════════════════════════════');
    output.push('');

    if (ledgerInfo) {
      output.push('📋 CURRENT SESSION LEDGER:');
      output.push(`   File: ${ledgerInfo.file}`);
      output.push(`   Last Updated: ${formatDate(ledgerInfo.lastModified)}`);
      output.push(`   Goal: ${ledgerInfo.goal.split('\n')[0].substring(0, 60)}...`);
      output.push(`   Progress: ${ledgerInfo.completed} items completed, ${ledgerInfo.nextSteps} steps remaining`);
      if (ledgerInfo.currentFocus) {
        output.push(`   Current Focus: ${ledgerInfo.currentFocus.split('\n')[0].substring(0, 60)}`);
      }
      output.push('');
    }

    if (handoffInfo) {
      const outcomeEmoji = handoffInfo.outcome === 'SUCCEEDED' ? '✅' : handoffInfo.outcome === 'PARTIAL' ? '⏳' : '❌';
      output.push('📦 LATEST HANDOFF:');
      output.push(`   File: ${handoffInfo.file}`);
      output.push(`   Title: ${handoffInfo.title}`);
      output.push(`   Status: ${outcomeEmoji} ${handoffInfo.outcome} (${handoffInfo.completion}% complete)`);
      output.push(`   Created: ${formatDate(handoffInfo.lastModified)}`);
      if (handoffInfo.nextSteps > 0) {
        output.push(`   Next Steps: ${handoffInfo.nextSteps} tasks defined`);
      }
      output.push('');
    }

    output.push('───────────────────────────────────────────────────────────────');
    output.push('💡 TIPS:');
    output.push('   • Update ledger frequently: /skill continuity-ledger');
    output.push('   • Create handoff before ending: /skill create-handoff');
    output.push('   • Search past work: /skill query-artifacts "keywords"');
    output.push('═══════════════════════════════════════════════════════════════');
    output.push('');
  } else if (CONFIG.showWelcomeMessage) {
    output.push('');
    output.push('═══════════════════════════════════════════════════════════════');
    output.push('🚀  NEW SESSION - Legendary Team v2026');
    output.push('═══════════════════════════════════════════════════════════════');
    output.push('');
    output.push('No continuity state found. Starting fresh!');
    output.push('');
    output.push('💡 CREATE YOUR FIRST LEDGER:');
    output.push('   Use: /skill continuity-ledger');
    output.push('   Track your work and never lose context again.');
    output.push('');
    output.push('═══════════════════════════════════════════════════════════════');
    output.push('');
  }

  // Print output
  if (output.length > 0) {
    console.log(output.join('\n'));
  }

  log('SessionStart hook completed successfully');

  // Return hook result
  return {
    blocked: false,
    ledger: ledgerInfo ? ledgerInfo.file : null,
    handoff: handoffInfo ? handoffInfo.file : null
  };
}

// =============================================================================
// Execute Hook
// =============================================================================

try {
  const result = main();
  process.exit(0);
} catch (err) {
  log(`Fatal error in SessionStart hook: ${err.message}\n${err.stack}`, 'error');
  console.error('⚠️  SessionStart hook encountered an error (continuing anyway)');
  process.exit(0); // Exit gracefully to not break Claude
}
