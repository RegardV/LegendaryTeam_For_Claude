#!/usr/bin/env node
/**
 * PreToolUse Hook - Legendary Team v2026
 *
 * Fires before: Edit, Write, NotebookEdit, and other destructive tools
 * Purpose: Validate before execution (TypeScript, budget, OpenSpec)
 *
 * This hook prevents quality issues by validating BEFORE changes are made.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// =============================================================================
// Configuration
// =============================================================================

const ROOT = process.cwd();
const CONFIG_FILE = path.join(ROOT, '.claude', 'hooks', 'config.json');

const DEFAULT_CONFIG = {
  enabled: true,
  typeScriptValidation: true,
  budgetCheck: false,
  budgetLimit: 50.0,
  openSpecValidation: false, // Future feature
  debug: false
};

// =============================================================================
// Helper Functions
// =============================================================================

function log(message, level = 'info') {
  const config = loadConfig();
  if (config.debug || level === 'error') {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] [PreToolUse] ${level.toUpperCase()}: ${message}\n`;

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
    if (fs.existsSync(CONFIG_FILE)) {
      const content = fs.readFileSync(CONFIG_FILE, 'utf8');
      return { ...DEFAULT_CONFIG, ...JSON.parse(content).preToolUse };
    }
  } catch (err) {
    log(`Error loading config: ${err.message}`, 'error');
  }
  return DEFAULT_CONFIG;
}

function getToolInfo() {
  // In real Claude Code, this would come from hook context
  // For now, parse from command line args
  const args = process.argv.slice(2);

  return {
    tool: args[0] || 'Unknown',
    file_path: args[1] || null,
    params: args.slice(2)
  };
}

// =============================================================================
// TypeScript Validation
// =============================================================================

function isTypeScriptFile(filePath) {
  return filePath && (filePath.endsWith('.ts') || filePath.endsWith('.tsx'));
}

function runTypeScriptCheck(filePath) {
  log(`Running TypeScript validation on: ${filePath}`);

  try {
    // Check if TypeScript is available
    try {
      execSync('tsc --version', { stdio: 'ignore' });
    } catch {
      log('TypeScript (tsc) not found, skipping validation', 'warn');
      return { passed: true, skipped: true };
    }

    // Run TypeScript compiler in noEmit mode
    const result = execSync('tsc --noEmit --pretty false', {
      cwd: ROOT,
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe']
    });

    log('TypeScript validation passed');
    return { passed: true, output: result };

  } catch (err) {
    // TypeScript found errors
    const output = err.stdout || err.stderr || err.message;

    // Check if the error is related to the file being edited
    const fileErrors = output.split('\n').filter(line => line.includes(filePath));

    if (fileErrors.length > 0) {
      log(`TypeScript errors found in ${filePath}`, 'warn');
      return {
        passed: false,
        errors: fileErrors,
        fullOutput: output
      };
    } else {
      // Errors exist but not in this file - allow edit
      log('TypeScript errors exist but not in target file', 'info');
      return {
        passed: true,
        warnings: output.split('\n').slice(0, 5) // First 5 lines
      };
    }
  }
}

// =============================================================================
// Budget Check
// =============================================================================

function checkBudget() {
  log('Checking token budget');

  try {
    const sessionStateFile = path.join(ROOT, '.claude', 'session-state.json');

    if (!fs.existsSync(sessionStateFile)) {
      log('Session state not found, skipping budget check');
      return { passed: true, skipped: true };
    }

    const sessionState = JSON.parse(fs.readFileSync(sessionStateFile, 'utf8'));
    const currentCost = sessionState.session_cost_dollars || 0;
    const config = loadConfig();

    if (currentCost >= config.budgetLimit) {
      log(`Budget exceeded: $${currentCost} >= $${config.budgetLimit}`, 'warn');
      return {
        passed: false,
        currentCost,
        limit: config.budgetLimit,
        remaining: 0
      };
    }

    const remaining = config.budgetLimit - currentCost;
    log(`Budget check passed: $${currentCost} / $${config.budgetLimit} (${remaining.toFixed(2)} remaining)`);

    return {
      passed: true,
      currentCost,
      limit: config.budgetLimit,
      remaining
    };

  } catch (err) {
    log(`Error checking budget: ${err.message}`, 'error');
    return { passed: true, error: err.message };
  }
}

// =============================================================================
// Main Hook Logic
// =============================================================================

function main() {
  log('PreToolUse hook triggered');

  const config = loadConfig();

  if (!config.enabled) {
    log('PreToolUse hook disabled via config');
    return { blocked: false };
  }

  const toolInfo = getToolInfo();
  log(`Tool: ${toolInfo.tool}, File: ${toolInfo.file_path}`);

  const validations = [];

  // ===== TypeScript Validation =====
  if (config.typeScriptValidation && toolInfo.file_path && isTypeScriptFile(toolInfo.file_path)) {
    log('Running TypeScript validation...');
    const tsResult = runTypeScriptCheck(toolInfo.file_path);

    if (!tsResult.passed) {
      console.log('');
      console.log('🚫 ═══════════════════════════════════════════════════════════');
      console.log('   EDIT BLOCKED - TypeScript Errors Detected');
      console.log('═══════════════════════════════════════════════════════════');
      console.log('');
      console.log(`File: ${toolInfo.file_path}`);
      console.log('');
      console.log('Errors:');
      tsResult.errors.forEach(err => console.log(`  ${err}`));
      console.log('');
      console.log('Fix type errors before proceeding:');
      console.log('  tsc --noEmit');
      console.log('');
      console.log('Or disable TypeScript validation:');
      console.log('  Edit .claude/hooks/config.json');
      console.log('  Set preToolUse.typeScriptValidation = false');
      console.log('');
      console.log('═══════════════════════════════════════════════════════════');
      console.log('');

      return {
        blocked: true,
        reason: 'TypeScript validation failed',
        errors: tsResult.errors
      };
    } else if (tsResult.warnings) {
      console.log('');
      console.log('⚠️  TypeScript warnings exist in other files (not blocking):');
      tsResult.warnings.forEach(warn => console.log(`  ${warn}`));
      console.log('');
    }

    validations.push({ name: 'TypeScript', passed: true });
  }

  // ===== Budget Check =====
  if (config.budgetCheck) {
    log('Running budget check...');
    const budgetResult = checkBudget();

    if (!budgetResult.passed && !budgetResult.skipped) {
      console.log('');
      console.log('🚫 ═══════════════════════════════════════════════════════════');
      console.log('   OPERATION BLOCKED - Budget Exceeded');
      console.log('═══════════════════════════════════════════════════════════');
      console.log('');
      console.log(`Current Cost: $${budgetResult.currentCost.toFixed(2)}`);
      console.log(`Budget Limit: $${budgetResult.limit.toFixed(2)}`);
      console.log('');
      console.log('Options:');
      console.log('  1. Increase budget limit in .claude/hooks/config.json');
      console.log('  2. Disable budget check (preToolUse.budgetCheck = false)');
      console.log('  3. End session and start fresh');
      console.log('');
      console.log('═══════════════════════════════════════════════════════════');
      console.log('');

      return {
        blocked: true,
        reason: 'Budget limit exceeded',
        currentCost: budgetResult.currentCost,
        limit: budgetResult.limit
      };
    } else if (budgetResult.remaining < 5 && !budgetResult.skipped) {
      console.log('');
      console.log(`⚠️  BUDGET WARNING: $${budgetResult.remaining.toFixed(2)} remaining (${Math.round((budgetResult.remaining / budgetResult.limit) * 100)}% of budget)`);
      console.log('');
    }

    validations.push({ name: 'Budget', passed: true });
  }

  // ===== All Validations Passed =====
  if (validations.length > 0) {
    log(`All validations passed: ${validations.map(v => v.name).join(', ')}`);
  }

  return {
    blocked: false,
    validations
  };
}

// =============================================================================
// Execute Hook
// =============================================================================

try {
  const result = main();

  if (result.blocked) {
    log('Operation blocked by PreToolUse hook', 'warn');
    process.exit(1); // Non-zero exit blocks the operation
  } else {
    log('PreToolUse validation passed');
    process.exit(0);
  }
} catch (err) {
  log(`Fatal error in PreToolUse hook: ${err.message}\n${err.stack}`, 'error');
  console.error('⚠️  PreToolUse hook encountered an error (allowing operation)');
  process.exit(0); // Allow operation to proceed on error
}
