#!/usr/bin/env node
/**
 * PostToolUse Hook - Legendary Team v2026
 *
 * Fires after: Edit, Write, NotebookEdit, and other file operations
 * Purpose: Track changes, update codebase map, index artifacts
 *
 * This hook maintains state and enables searchability across sessions.
 */

const fs = require('fs');
const path = require('path');

// =============================================================================
// Configuration
// =============================================================================

const ROOT = process.cwd();
const CODEBASE_MAP_FILE = path.join(ROOT, '.claude', 'codebase-map.json');
const HANDOFFS_DIR = path.join(ROOT, 'thoughts', 'shared', 'handoffs');
const PLANS_DIR = path.join(ROOT, 'thoughts', 'shared', 'plans');

const DEFAULT_CONFIG = {
  enabled: true,
  updateCodebaseMap: true,
  indexArtifacts: true,
  debug: false
};

// =============================================================================
// Helper Functions
// =============================================================================

function log(message, level = 'info') {
  const config = loadConfig();
  if (config.debug || level === 'error') {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] [PostToolUse] ${level.toUpperCase()}: ${message}\n`;

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
      return { ...DEFAULT_CONFIG, ...JSON.parse(content).postToolUse };
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

function getToolInfo() {
  // Parse command line args (in real Claude Code, this comes from context)
  const args = process.argv.slice(2);
  return {
    tool: args[0] || 'Unknown',
    file_path: args[1] || null,
    operation: args[2] || 'modified', // 'created', 'modified', 'deleted'
    agent: args[3] || '@chief'
  };
}

// =============================================================================
// Codebase Map Functions
// =============================================================================

function updateCodebaseMap(filePath, operation, agent) {
  log(`Updating codebase map for: ${filePath} (${operation})`);

  const map = readJSON(CODEBASE_MAP_FILE) || {
    version: '2.0',
    last_full_scan: new Date().toISOString(),
    files: {}
  };

  if (operation === 'deleted') {
    // Remove from map
    delete map.files[filePath];
    log(`Removed ${filePath} from codebase map`);
  } else {
    // Add or update in map
    const existing = map.files[filePath] || {};

    map.files[filePath] = {
      ...existing,
      last_modified: new Date().toISOString(),
      modified_by: agent,
      operation: operation, // 'created' or 'modified'
      tracked_at: existing.tracked_at || new Date().toISOString()
    };

    log(`${operation === 'created' ? 'Added' : 'Updated'} ${filePath} in codebase map`);
  }

  map.last_updated = new Date().toISOString();
  map.total_files = Object.keys(map.files).length;

  return writeJSON(CODEBASE_MAP_FILE, map);
}

// =============================================================================
// Artifact Indexing Functions
// =============================================================================

function isArtifactFile(filePath) {
  // Check if file is a handoff or plan
  return (
    filePath.includes('thoughts/shared/handoffs/') && filePath.endsWith('.md') ||
    filePath.includes('thoughts/shared/plans/') && filePath.endsWith('.md')
  );
}

function parseArtifactMetadata(filePath, content) {
  const type = filePath.includes('/handoffs/') ? 'handoff' : 'plan';

  const metadata = {
    type,
    file_path: filePath,
    title: 'Unknown',
    created_at: new Date().toISOString(),
    summary: ''
  };

  // Parse title
  const titleMatch = content.match(/^#\s+(?:Handoff|Implementation Plan)\s+-\s+(.+)$/m);
  if (titleMatch) {
    metadata.title = titleMatch[1].trim();
  }

  // Parse outcome (for handoffs)
  if (type === 'handoff') {
    const outcomeMatch = content.match(/\*\*Outcome\*\*:\s+.*?(SUCCEEDED|PARTIAL|FAILED)/i);
    if (outcomeMatch) {
      metadata.outcome = outcomeMatch[1];
    }

    const completionMatch = content.match(/\*\*Completion\*\*:\s+\[?(\d+)%/i);
    if (completionMatch) {
      metadata.completion_percentage = parseInt(completionMatch[1]);
    }
  }

  // Parse summary
  const summaryMatch = content.match(/##\s+📋\s+Executive Summary\s+([\s\S]*?)(?=##|$)/i);
  if (summaryMatch) {
    metadata.summary = summaryMatch[1].trim().substring(0, 500);
  }

  // Extract keywords for search
  const keywords = [];
  const keywordMatch = content.match(/##\s+🔍\s+Search Keywords\s+([\s\S]*?)(?=##|$)/i);
  if (keywordMatch) {
    keywords.push(...keywordMatch[1].trim().split(/[,\s]+/).filter(k => k.length > 2));
  }
  metadata.keywords = keywords.join(', ');

  return metadata;
}

function indexArtifact(filePath) {
  log(`Indexing artifact: ${filePath}`);

  try {
    // Read artifact content
    const content = fs.readFileSync(filePath, 'utf8');

    // Parse metadata
    const metadata = parseArtifactMetadata(filePath, content);

    // Log artifact for tracking (file-based memory)
    log(`Indexed: ${metadata.type} - ${metadata.title}`);

    return true;
  } catch (err) {
    log(`Error indexing artifact: ${err.message}`, 'error');
    return false;
  }
}

// =============================================================================
// Main Hook Logic
// =============================================================================

function main() {
  log('PostToolUse hook triggered');

  const config = loadConfig();

  if (!config.enabled) {
    log('PostToolUse hook disabled via config');
    return { success: true };
  }

  const toolInfo = getToolInfo();
  log(`Tool: ${toolInfo.tool}, File: ${toolInfo.file_path}, Operation: ${toolInfo.operation}`);

  if (!toolInfo.file_path) {
    log('No file path provided, skipping hook');
    return { success: true };
  }

  const results = {
    codebaseMapUpdated: false,
    artifactIndexed: false
  };

  // ===== Update Codebase Map =====
  if (config.updateCodebaseMap) {
    try {
      results.codebaseMapUpdated = updateCodebaseMap(
        toolInfo.file_path,
        toolInfo.operation,
        toolInfo.agent
      );
    } catch (err) {
      log(`Error updating codebase map: ${err.message}`, 'error');
    }
  }

  // ===== Index Artifacts =====
  if (config.indexArtifacts && isArtifactFile(toolInfo.file_path)) {
    if (toolInfo.operation !== 'deleted' && fs.existsSync(toolInfo.file_path)) {
      try {
        results.artifactIndexed = indexArtifact(toolInfo.file_path);

        if (results.artifactIndexed) {
          console.log('');
          console.log(`✓ Artifact indexed: ${path.basename(toolInfo.file_path)}`);
          console.log(`  Search with: /skill query-artifacts "keywords"`);
          console.log('');
        }
      } catch (err) {
        log(`Error indexing artifact: ${err.message}`, 'error');
      }
    }
  }

  // ===== Output Summary =====
  if (config.updateCodebaseMap && results.codebaseMapUpdated) {
    const operation = toolInfo.operation === 'created' ? 'tracked' : 'updated';
    console.log(`✓ Codebase map ${operation}: ${path.basename(toolInfo.file_path)}`);
  }

  log('PostToolUse hook completed successfully');

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
  log(`Fatal error in PostToolUse hook: ${err.message}\n${err.stack}`, 'error');
  console.error('⚠️  PostToolUse hook encountered an error (continuing anyway)');
  process.exit(0); // Exit gracefully
}
