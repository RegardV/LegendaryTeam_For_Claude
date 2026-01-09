#!/usr/bin/env node
/**
 * PreCompact Hook - Legendary Team v2026
 *
 * Fires before: Context compaction
 * Purpose: BLOCK compaction, enforce "Clear, Don't Compact" philosophy
 *
 * This hook enforces the continuity philosophy by preventing lossy compaction.
 * Users must create handoffs and use /clear instead.
 */

const fs = require('fs');
const path = require('path');

// =============================================================================
// Configuration
// =============================================================================

const ROOT = process.cwd();
const HANDOFFS_DIR = path.join(ROOT, 'thoughts', 'shared', 'handoffs');
const LEDGERS_DIR = path.join(ROOT, 'thoughts', 'ledgers');

const DEFAULT_CONFIG = {
  enabled: true,
  blockCompaction: true,
  requireHandoff: true,
  handoffMaxAge: 60 * 60 * 1000, // 1 hour in milliseconds
  allowOverride: false,
  debug: false
};

// =============================================================================
// Helper Functions
// =============================================================================

function log(message, level = 'info') {
  const config = loadConfig();
  if (config.debug || level === 'error') {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] [PreCompact] ${level.toUpperCase()}: ${message}\n`;

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
      return { ...DEFAULT_CONFIG, ...JSON.parse(content).preCompact };
    }
  } catch (err) {
    log(`Error loading config: ${err.message}`, 'error');
  }
  return DEFAULT_CONFIG;
}

// =============================================================================
// Handoff Detection
// =============================================================================

function findRecentHandoff(maxAgeMs) {
  log(`Looking for handoffs created within last ${maxAgeMs / 1000} seconds`);

  if (!fs.existsSync(HANDOFFS_DIR)) {
    log('Handoffs directory not found');
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

    if (files.length > 0) {
      log(`Found recent handoff: ${files[0].name} (${Math.round(files[0].age / 1000)}s old)`);
      return files[0];
    }

    log('No recent handoff found');
    return null;
  } catch (err) {
    log(`Error finding recent handoff: ${err.message}`, 'error');
    return null;
  }
}

function findCurrentLedger() {
  log('Looking for current ledger');

  if (!fs.existsSync(LEDGERS_DIR)) {
    log('Ledgers directory not found');
    return null;
  }

  try {
    const files = fs.readdirSync(LEDGERS_DIR)
      .filter(f => f.startsWith('CONTINUITY_CLAUDE-') && f.endsWith('.md'))
      .map(f => {
        const filePath = path.join(LEDGERS_DIR, f);
        const stats = fs.statSync(filePath);
        return {
          name: f,
          path: filePath,
          mtime: stats.mtime
        };
      })
      .sort((a, b) => b.mtime - a.mtime); // Newest first

    if (files.length > 0) {
      log(`Found current ledger: ${files[0].name}`);
      return files[0];
    }

    log('No current ledger found');
    return null;
  } catch (err) {
    log(`Error finding current ledger: ${err.message}`, 'error');
    return null;
  }
}

// =============================================================================
// Main Hook Logic
// =============================================================================

function main() {
  log('PreCompact hook triggered');

  const config = loadConfig();

  if (!config.enabled) {
    log('PreCompact hook disabled via config');
    return { blocked: false };
  }

  if (!config.blockCompaction) {
    log('Compaction blocking disabled via config');
    return { blocked: false };
  }

  // Check for recent handoff
  const recentHandoff = config.requireHandoff ?
    findRecentHandoff(config.handoffMaxAge) : null;

  // Check for current ledger
  const currentLedger = findCurrentLedger();

  // ===== Allow compaction if recent handoff exists =====
  if (recentHandoff) {
    log('Recent handoff found - allowing compaction');

    console.log('');
    console.log('✓ Recent handoff detected');
    console.log(`  ${recentHandoff.name}`);
    console.log('  Compaction allowed');
    console.log('');
    console.log('⚠️  RECOMMENDATION: Use /clear instead of compaction');
    console.log('   /clear provides fresh context without signal degradation');
    console.log('');

    return {
      blocked: false,
      reason: 'Recent handoff exists',
      handoff: recentHandoff.name
    };
  }

  // ===== Block compaction - no recent handoff =====
  log('No recent handoff found - blocking compaction');

  console.log('');
  console.log('🚫 ═══════════════════════════════════════════════════════════════');
  console.log('   COMPACTION BLOCKED - Legendary Team v2026');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');
  console.log('❌ Compaction loses information through summarization.');
  console.log('   This leads to "summary of a summary" degradation.');
  console.log('');
  console.log('✅ INSTEAD: Use the continuity system (no information loss)');
  console.log('');
  console.log('───────────────────────────────────────────────────────────────');
  console.log('RECOMMENDED WORKFLOW:');
  console.log('───────────────────────────────────────────────────────────────');
  console.log('');

  if (currentLedger) {
    console.log('1. Update your current ledger:');
    console.log('   /skill continuity-ledger');
    console.log('');
    console.log('2. Clear context (ledger will auto-reload):');
    console.log('   /clear');
    console.log('');
  } else {
    console.log('1. Create a handoff document:');
    console.log('   /skill create-handoff');
    console.log('');
    console.log('   This preserves ALL your work with full context.');
    console.log('   Handoffs are searchable and never degrade.');
    console.log('');
    console.log('2. After creating handoff, clear context:');
    console.log('   /clear');
    console.log('');
    console.log('   The handoff will auto-reload on next session.');
    console.log('');
  }

  console.log('───────────────────────────────────────────────────────────────');
  console.log('WHY THIS MATTERS:');
  console.log('───────────────────────────────────────────────────────────────');
  console.log('');
  console.log('Compaction:');
  console.log('  ❌ Lossy summarization');
  console.log('  ❌ Information degrades with each compaction');
  console.log('  ❌ Important details get lost');
  console.log('  ❌ Can introduce hallucinations');
  console.log('');
  console.log('Continuity System:');
  console.log('  ✅ Lossless state preservation');
  console.log('  ✅ Full context always available');
  console.log('  ✅ Searchable across sessions');
  console.log('  ✅ No degradation, ever');
  console.log('');

  if (config.allowOverride) {
    console.log('───────────────────────────────────────────────────────────────');
    console.log('OVERRIDE (Not Recommended):');
    console.log('───────────────────────────────────────────────────────────────');
    console.log('');
    console.log('To disable this protection:');
    console.log('  Edit: .claude/hooks/config.json');
    console.log('  Set: preCompact.blockCompaction = false');
    console.log('');
  }

  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');

  return {
    blocked: true,
    reason: 'No recent handoff - use continuity system instead',
    currentLedger: currentLedger ? currentLedger.name : null
  };
}

// =============================================================================
// Execute Hook
// =============================================================================

try {
  const result = main();

  if (result.blocked) {
    log('Compaction blocked by PreCompact hook', 'warn');
    process.exit(1); // Non-zero exit blocks the operation
  } else {
    log('Compaction allowed by PreCompact hook');
    process.exit(0);
  }
} catch (err) {
  log(`Fatal error in PreCompact hook: ${err.message}\n${err.stack}`, 'error');
  console.error('⚠️  PreCompact hook encountered an error (allowing compaction)');
  process.exit(0); // Allow compaction to proceed on error
}
