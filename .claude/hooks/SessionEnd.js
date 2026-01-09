#!/usr/bin/env node
/**
 * SessionEnd Hook - Legendary Team v2026
 *
 * Fires when: Session closes or ends
 * Purpose: Extract learnings, prompt for handoff, cleanup
 *
 * This hook ensures no work is lost when sessions end.
 */

const fs = require('fs');
const path = require('path');

// =============================================================================
// Configuration
// =============================================================================

const ROOT = process.cwd();
const HANDOFFS_DIR = path.join(ROOT, 'thoughts', 'shared', 'handoffs');
const LEDGERS_DIR = path.join(ROOT, 'thoughts', 'ledgers');
const SESSION_STATE_FILE = path.join(ROOT, '.claude', 'session-state.json');

const DEFAULT_CONFIG = {
  enabled: true,
  promptForHandoff: true,
  extractLearnings: false, // Future feature
  cleanupOldLedgers: true,
  ledgerMaxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
  debug: false
};

// =============================================================================
// Helper Functions
// =============================================================================

function log(message, level = 'info') {
  const config = loadConfig();
  if (config.debug || level === 'error') {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] [SessionEnd] ${level.toUpperCase()}: ${message}\n`;

    try {
      const logFile = path.join(ROOT, '.claude', 'hooks', 'debug.log');
      fs.appendFileSync(logFile, logMessage);
    } catch {
      // Silently fail
    }
  }
}

function loadConfig() {
  try {
    const configFile = path.join(ROOT, '.claude', 'hooks', 'config.json');
    if (fs.existsSync(configFile)) {
      const content = fs.readFileSync(configFile, 'utf8');
      return { ...DEFAULT_CONFIG, ...JSON.parse(content).sessionEnd };
    }
  } catch (err) {
    log(`Error loading config: ${err.message}`, 'error');
  }
  return DEFAULT_CONFIG;
}

function readJSON(filePath) {
  try {
    if (!fs.existsSync(filePath)) return null;
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (err) {
    log(`Error reading JSON from ${filePath}: ${err.message}`, 'error');
    return null;
  }
}

function writeJSON(filePath, data) {
  try {
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (err) {
    log(`Error writing JSON to ${filePath}: ${err.message}`, 'error');
    return false;
  }
}

// =============================================================================
// Handoff Detection
// =============================================================================

function findRecentHandoff(maxAgeMs) {
  log('Checking for recent handoff');

  if (!fs.existsSync(HANDOFFS_DIR)) {
    return null;
  }

  try {
    const now = Date.now();
    const files = fs.readdirSync(HANDOFFS_DIR)
      .filter(f => f.startsWith('handoff-') && f.endsWith('.md'))
      .map(f => {
        const filePath = path.join(HANDOFFS_DIR, f);
        const stats = fs.statSync(filePath);
        return {
          name: f,
          path: filePath,
          mtime: stats.mtime,
          age: now - stats.mtime.getTime()
        };
      })
      .filter(f => f.age < maxAgeMs)
      .sort((a, b) => a.age - b.age); // Newest first

    return files.length > 0 ? files[0] : null;
  } catch (err) {
    log(`Error finding recent handoff: ${err.message}`, 'error');
    return null;
  }
}

// =============================================================================
// Cleanup Functions
// =============================================================================

function cleanupOldLedgers(maxAgeMs) {
  log(`Cleaning up ledgers older than ${maxAgeMs / (24 * 60 * 60 * 1000)} days`);

  if (!fs.existsSync(LEDGERS_DIR)) {
    return { deleted: 0 };
  }

  try {
    const now = Date.now();
    const files = fs.readdirSync(LEDGERS_DIR)
      .filter(f => f.startsWith('CONTINUITY_CLAUDE-') && f.endsWith('.md'))
      .map(f => {
        const filePath = path.join(LEDGERS_DIR, f);
        const stats = fs.statSync(filePath);
        return {
          name: f,
          path: filePath,
          age: now - stats.mtime.getTime()
        };
      })
      .filter(f => f.age > maxAgeMs);

    let deleted = 0;
    for (const file of files) {
      try {
        fs.unlinkSync(file.path);
        log(`Deleted old ledger: ${file.name}`);
        deleted++;
      } catch (err) {
        log(`Error deleting ${file.name}: ${err.message}`, 'error');
      }
    }

    return { deleted };
  } catch (err) {
    log(`Error cleaning up old ledgers: ${err.message}`, 'error');
    return { deleted: 0, error: err.message };
  }
}

// =============================================================================
// Session State Functions
// =============================================================================

function updateSessionState() {
  log('Updating session state');

  const state = readJSON(SESSION_STATE_FILE) || {
    version: '2026-legendary-continuity',
    sessions: []
  };

  const currentSession = {
    session_id: state.current_session_id || `session-${Date.now()}`,
    start_time: state.last_session_start || new Date().toISOString(),
    end_time: new Date().toISOString(),
    duration_minutes: 0
  };

  // Calculate duration
  if (state.last_session_start) {
    const start = new Date(state.last_session_start);
    const end = new Date();
    currentSession.duration_minutes = Math.round((end - start) / 60000);
  }

  // Add to sessions history
  state.sessions = state.sessions || [];
  state.sessions.push(currentSession);

  // Keep only last 50 sessions
  if (state.sessions.length > 50) {
    state.sessions = state.sessions.slice(-50);
  }

  state.last_session_end = new Date().toISOString();
  delete state.current_session_id;

  return writeJSON(SESSION_STATE_FILE, state);
}

// =============================================================================
// Main Hook Logic
// =============================================================================

function main() {
  log('SessionEnd hook triggered');

  const config = loadConfig();

  if (!config.enabled) {
    log('SessionEnd hook disabled via config');
    return { success: true };
  }

  const results = {
    handoffPrompted: false,
    ledgersCleaned: 0,
    sessionStateUpdated: false
  };

  // ===== Check for Recent Handoff =====
  if (config.promptForHandoff) {
    const recentHandoff = findRecentHandoff(2 * 60 * 60 * 1000); // 2 hours

    if (!recentHandoff) {
      log('No recent handoff found - prompting user');

      console.log('');
      console.log('═══════════════════════════════════════════════════════════════');
      console.log('⚠️  SESSION ENDING - NO HANDOFF CREATED');
      console.log('═══════════════════════════════════════════════════════════════');
      console.log('');
      console.log('💡 Create a handoff to preserve your work across sessions:');
      console.log('');
      console.log('   /skill create-handoff');
      console.log('');
      console.log('Handoffs provide:');
      console.log('  ✅ Complete record of what you accomplished');
      console.log('  ✅ Context for resuming work later');
      console.log('  ✅ Searchable documentation');
      console.log('  ✅ Team knowledge sharing');
      console.log('');
      console.log('📝 A good handoff includes:');
      console.log('  • What was completed');
      console.log('  • What worked / what didn\'t');
      console.log('  • Key decisions made');
      console.log('  • Next steps');
      console.log('  • Known issues');
      console.log('');
      console.log('⏱️  Creating a handoff takes 2-3 minutes but saves hours later.');
      console.log('');
      console.log('═══════════════════════════════════════════════════════════════');
      console.log('');

      results.handoffPrompted = true;
    } else {
      log(`Recent handoff found: ${recentHandoff.name}`);
      console.log('');
      console.log(`✓ Handoff on record: ${recentHandoff.name}`);
      console.log('  Your work is preserved!');
      console.log('');
    }
  }

  // ===== Cleanup Old Ledgers =====
  if (config.cleanupOldLedgers) {
    const cleanupResult = cleanupOldLedgers(config.ledgerMaxAge);
    results.ledgersCleaned = cleanupResult.deleted;

    if (cleanupResult.deleted > 0) {
      log(`Cleaned up ${cleanupResult.deleted} old ledger(s)`);
      console.log(`✓ Cleaned up ${cleanupResult.deleted} old ledger(s)`);
    }
  }

  // ===== Update Session State =====
  try {
    results.sessionStateUpdated = updateSessionState();
    log('Session state updated');
  } catch (err) {
    log(`Error updating session state: ${err.message}`, 'error');
  }

  // ===== Final Message =====
  console.log('');
  console.log('──────────────────────────────────────────────────────────────');
  console.log('👋 Thanks for using Legendary Team v2026!');
  console.log('');
  console.log('Your continuity system is ready for next time.');
  console.log('──────────────────────────────────────────────────────────────');
  console.log('');

  log('SessionEnd hook completed successfully');

  return {
    success: true,
    results
  };
}

// =============================================================================
// Execute Hook
// =============================================================================

try {
  const result = main();
  process.exit(0);
} catch (err) {
  log(`Fatal error in SessionEnd hook: ${err.message}\n${err.stack}`, 'error');
  console.error('⚠️  SessionEnd hook encountered an error (continuing anyway)');
  process.exit(0); // Exit gracefully
}
