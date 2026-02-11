# Legendary Team v2026 - Hooks System

**Purpose**: Automate continuity, quality gates, and state management throughout the Claude Code lifecycle.

---

## 🎯 Overview

Hooks intercept Claude Code lifecycle events to:
- ✅ Automatically load/save continuity state
- ✅ Enforce quality gates before actions
- ✅ Track changes and update indexes
- ✅ Prevent context loss
- ✅ Extract learnings

---

## 📋 Available Hooks

| Hook | When It Fires | Purpose |
|------|--------------|---------|
| **SessionStart.js** | Session begins (resume/clear/compact) | Load ledger + handoff |
| **PreToolUse.js** | Before any tool execution | Validate, check budget |
| **PostToolUse.js** | After tool execution | Track changes, index artifacts |
| **PreCompact.js** | Before context compaction | Force handoff creation |
| **SessionEnd.js** | Session closes | Extract learnings, cleanup |
| **UserPromptSubmit.js** | Every user message | Skill activation, warnings |

---

## 🔄 Hook Lifecycle

```
┌─────────────────────────────────────────────────────┐
│ SESSION START                                       │
│ → SessionStart.js fires                            │
│   • Loads current ledger (if exists)               │
│   • Loads latest handoff (if new session)          │
│   • Displays continuity status                     │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│ USER PROMPT                                         │
│ → UserPromptSubmit.js fires                        │
│   • Checks for skill activation keywords           │
│   • Warns if context getting full (>80%)           │
│   • Suggests ledger update                         │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│ TOOL EXECUTION                                      │
│ → PreToolUse.js fires                              │
│   • TypeScript validation (if .ts file)            │
│   • Budget check (if enabled)                      │
│   • OpenSpec validation                            │
│ → Tool executes (Edit/Write/etc)                   │
│ → PostToolUse.js fires                             │
│   • Updates codebase-map.json                      │
│   • Indexes new handoffs/plans                     │
│   • Tracks file modifications                      │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│ CONTEXT GETTING FULL                                │
│ → PreCompact.js fires                              │
│   • BLOCKS manual compaction                       │
│   • Forces handoff creation                        │
│   • Prompts: "Create handoff before compacting"    │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│ SESSION END                                         │
│ → SessionEnd.js fires                              │
│   • Extracts learnings (What worked/failed)        │
│   • Updates session state                          │
│   • Prompts for handoff if not created             │
│   • Cleans up temporary ledgers                    │
└─────────────────────────────────────────────────────┘
```

---

## 🛠️ Hook Implementation Details

### SessionStart.js

**Triggers**:
- New session starts
- After `/clear` command
- After context compaction

**Actions**:
1. Check for current ledger in `thoughts/ledgers/`
2. Load ledger content if exists
3. Check for latest handoff in `thoughts/shared/handoffs/`
4. Load handoff if new session
5. Display status message to user

**Output**:
```
═══════════════════════════════════════════════════════
🔄 CONTINUITY RESTORED
═══════════════════════════════════════════════════════
Ledger: CONTINUITY_CLAUDE-20260109-120000.md
Status: 80% complete, 3 tasks remaining
Last Update: 2 hours ago

Latest Handoff: handoff-20260108-auth-feature.md
Outcome: PARTIAL (75% complete)
Next Steps: Complete refresh token endpoint
═══════════════════════════════════════════════════════
```

---

### PreToolUse.js

**Triggers**:
- Before Edit tool
- Before Write tool
- Before NotebookEdit tool
- Before any destructive operation

**Validations**:

1. **TypeScript Preflight** (for .ts files):
   ```bash
   tsc --noEmit
   ```
   - Blocks edit if type errors exist
   - Forces user to fix types first
   - Prevents introducing type errors

2. **Budget Check** (if enabled):
   ```javascript
   if (sessionCost > budgetLimit) {
     return { blocked: true, reason: "Budget exceeded" }
   }
   ```

3. **OpenSpec Validation**:
   - Check if file change aligns with OpenSpec
   - Warn if drift detected

**Output** (on block):
```
🚫 EDIT BLOCKED - Type Errors Detected
src/auth/middleware.ts:45:12 - error TS2345: Argument of type
'string' is not assignable to parameter of type 'number'.

Fix type errors before proceeding:
  tsc --noEmit
```

---

### PostToolUse.js

**Triggers**:
- After Edit tool
- After Write tool
- After NotebookEdit tool

**Actions**:

1. **Update Codebase Map**:
   ```javascript
   {
     "files": {
       "src/auth/middleware.ts": {
         "last_modified": "2026-01-09T12:00:00Z",
         "modified_by": "@chief",
         "changes": "Added JWT validation"
       }
     }
   }
   ```

2. **Index New Handoffs**:
   - Detect new files in `thoughts/shared/handoffs/`
   - Parse markdown content
   - Log for tracking

3. **Track File Changes**:
   - Record which files were modified
   - Store in session state
   - Used for handoff generation

**Output**:
```
✓ Codebase map updated
✓ src/auth/middleware.ts tracked
```

---

### PreCompact.js

**Triggers**:
- Before manual context compaction
- When context reaches 90% full

**Actions**:

1. **Block Compaction**:
   ```javascript
   return {
     blocked: true,
     reason: "Handoff required before compaction"
   }
   ```

2. **Prompt User**:
   ```
   🚫 COMPACTION BLOCKED

   You must create a handoff before compacting context.
   This prevents losing important work.

   Create handoff now:
     /skill create-handoff

   Or update ledger and clear instead:
     /skill continuity-ledger
     /clear
   ```

3. **Check if Handoff Exists**:
   - Look for recent handoff (last 1 hour)
   - If exists, allow compaction
   - If not, block

**Philosophy**:
We **never** compact. We **always** "clear, don't compact."

---

### SessionEnd.js

**Triggers**:
- Session closes
- User exits Claude Code
- After significant work period

**Actions**:

1. **Extract Learnings**:
   - Parse conversation history
   - Identify: What worked, what failed, key decisions
   - Store in database

2. **Prompt for Handoff** (if not created):
   ```
   ⚠️  SESSION ENDING - NO HANDOFF CREATED

   Create handoff to preserve your work:
     /skill create-handoff

   Skip handoff? (not recommended)
     Type: skip handoff
   ```

3. **Update Session State**:
   ```json
   {
     "last_session_end": "2026-01-09T14:30:00Z",
     "session_duration_minutes": 150,
     "tokens_used": 125000,
     "handoff_created": true
   }
   ```

4. **Cleanup**:
   - Remove old ledgers (>7 days)

---

### UserPromptSubmit.js (Optional)

**Triggers**:
- Every user message

**Actions**:

1. **Skill Activation**:
   - Detect keywords: "implement", "add feature", "fix bug"
   - Auto-suggest TDD workflow
   - Trigger appropriate agents

2. **Context Warning**:
   ```
   ⚠️  CONTEXT 85% FULL

   Recommended actions:
   1. Update ledger: /skill continuity-ledger
   2. Clear context: /clear
   3. Ledger will auto-reload after clear
   ```

3. **Budget Warning**:
   ```
   ⚠️  BUDGET WARNING: $45 / $50 (90%)

   Remaining: $5
   Estimated tokens left: ~10,000
   ```

---

## 📦 Helper Functions

Each hook has access to these utility functions:

### File System Helpers
```javascript
readFile(path)              // Read file contents
writeFile(path, content)    // Write file
fileExists(path)            // Check if file exists
listFiles(dir, pattern)     // List files matching pattern
```

### File Helpers
```javascript
getLatestHandoff()          // Get most recent handoff file
getSessionLearnings()       // Parse learnings from handoffs
```

### State Helpers
```javascript
getSessionState()           // Read session-state.json
updateSessionState(data)    // Update session state
getCodebaseMap()            // Read codebase-map.json
updateCodebaseMap(file)     // Update file tracking
```

### Git Helpers
```javascript
getCurrentBranch()          // Get git branch
getLastCommit()             // Get HEAD commit
getModifiedFiles()          // Get git status
```

### Validation Helpers
```javascript
runTypeScriptCheck(file)    // Run tsc --noEmit
checkBudget()               // Check token budget
validateOpenSpec(file)      // Check against OpenSpec
```

---

## 🎨 Hook Return Values

Hooks can return objects to control behavior:

### Allow Execution (Default)
```javascript
return { blocked: false }
// or just return nothing
```

### Block Execution
```javascript
return {
  blocked: true,
  reason: "Type errors detected",
  message: "Fix errors before proceeding"
}
```

### Modify Context
```javascript
return {
  blocked: false,
  appendToContext: "Loaded ledger with 5 tasks remaining"
}
```

---

## 🔧 Configuration

Hooks can be configured via `.claude/hooks/config.json`:

```json
{
  "sessionStart": {
    "enabled": true,
    "autoLoadLedger": true,
    "autoLoadHandoff": true
  },
  "preToolUse": {
    "enabled": true,
    "typeScriptValidation": true,
    "budgetCheck": true,
    "budgetLimit": 50.0
  },
  "postToolUse": {
    "enabled": true,
    "updateCodebaseMap": true,
    "indexArtifacts": true
  },
  "preCompact": {
    "enabled": true,
    "blockCompaction": true,
    "requireHandoff": true
  },
  "sessionEnd": {
    "enabled": true,
    "promptForHandoff": true,
    "extractLearnings": true,
    "cleanupOldLedgers": true
  },
  "tokenOptimization": {
    "enabled": true,
    "agentMode": "lite",
    "agentPaths": {
      "lite": ".claude/agents-lite/",
      "full": ".claude/agents-full/"
    },
    "dynamicLoading": {
      "enabled": true,
      "alwaysLoad": ["chief", "confidence-agent"],
      "loadOnDemand": true
    },
    "contextManagement": {
      "compactThreshold": 0.70,
      "maxHistoryTurns": 6
    },
    "outputCompression": {
      "enabled": true,
      "maxToolResponseLines": 50
    }
  }
}
```

### Token Optimization Settings (NEW)

The `tokenOptimization` section controls context efficiency:

| Setting | Default | Description |
|---------|---------|-------------|
| `agentMode` | `"lite"` | Use lite agents (`"lite"`) or full agents (`"full"`) |
| `dynamicLoading.enabled` | `true` | Load agents on-demand based on keywords |
| `dynamicLoading.alwaysLoad` | `["chief", "confidence-agent"]` | Agents to always load |
| `contextManagement.compactThreshold` | `0.70` | Trigger compaction at 70% context usage |
| `contextManagement.maxHistoryTurns` | `6` | Maximum conversation turns to retain |
| `outputCompression.maxToolResponseLines` | `50` | Truncate tool responses |

**Self-Escalation**: When `agentMode` is `"lite"`, agents automatically read their full definitions from `.claude/agents-full/` when encountering complex tasks.

---

## 🧪 Testing Hooks

### Manual Testing
```bash
# Test SessionStart
claude
# Should auto-load ledger if exists

# Test PreToolUse
# Try editing a .ts file with type errors
# Should block the edit

# Test PostToolUse
# Edit a file and check codebase-map.json
cat .claude/codebase-map.json

# Test PreCompact
# Try to compact context without handoff
# Should be blocked
```

### Debug Mode
Enable debug logging:
```json
{
  "debug": true,
  "logFile": ".claude/hooks/debug.log"
}
```

---

## 📝 Best Practices

### Hook Development
1. ✅ Keep hooks fast (<100ms)
2. ✅ Handle errors gracefully
3. ✅ Provide clear user messages
4. ✅ Log to debug file for troubleshooting
5. ✅ Test edge cases thoroughly

### Hook Execution
1. ✅ Hooks run synchronously (one at a time)
2. ✅ If hook throws error, operation continues (graceful degradation)
3. ✅ Hooks can access full conversation history
4. ✅ Hooks can modify context (sparingly)

### Performance
1. ✅ Cache expensive operations
2. ✅ Use async operations where possible
3. ✅ Minimize file I/O
4. ✅ Batch database operations

---

## 🚨 Troubleshooting

### Hook Not Firing
1. Check `.claude/hooks/` directory exists
2. Check hook file is named correctly (SessionStart.js, not sessionStart.js)
3. Check syntax: `node --check .claude/hooks/SessionStart.js`
4. Enable debug logging

### Hook Errors
1. Check `.claude/hooks/debug.log`
2. Run hook manually: `node .claude/hooks/SessionStart.js`
3. Check permissions: `chmod 644 .claude/hooks/*.js`

### Performance Issues
1. Check hook execution time in debug log
2. Profile slow operations
3. Consider caching
4. Reduce file I/O

---

## 📚 Resources

- Claude Code Hooks Documentation: https://code.claude.com/docs/hooks
- Hook Examples: `.claude/hooks/examples/`
- Troubleshooting Guide: `TROUBLESHOOTING.md`

---

**Hooks Version**: v2026-continuity
**Last Updated**: 2026-01-09
