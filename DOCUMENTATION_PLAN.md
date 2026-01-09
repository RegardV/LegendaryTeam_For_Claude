# LEGENDARY TEAM v2026 — DOCUMENTATION MASTER PLAN

**Purpose**: Provide complete, in-depth documentation for all users from beginners to advanced
**Audience**: Developers, team leads, DevOps engineers, AI enthusiasts
**Format**: Markdown with code examples, diagrams, screenshots, and video tutorial scripts

---

## 📚 DOCUMENTATION SUITE — 12 COMPLETE GUIDES

### 1. INSTALLATION.md
**Length**: ~800 lines
**Audience**: New users, system administrators

**Contents**:
```markdown
# Installation Guide

## Table of Contents
1. System Requirements
2. Pre-installation Checklist
3. Installation Methods
   - Quick Install (5 minutes)
   - Custom Install (15 minutes)
   - Global Install (system-wide)
4. Platform-Specific Instructions
   - Linux (Ubuntu, Fedora, Arch)
   - macOS (Intel & Apple Silicon)
   - Windows (WSL2, PowerShell)
5. Post-Installation Verification
6. API Key Configuration
7. First Run
8. Troubleshooting Installation Issues

## Examples Included
- Complete bash command sequences
- PowerShell equivalents
- Docker installation option
- CI/CD integration examples
```

---

### 2. ARCHITECTURE.md
**Length**: ~1200 lines
**Audience**: Advanced users, contributors

**Contents**:
```markdown
# System Architecture

## Table of Contents
1. Overview & Design Philosophy
2. Component Architecture
   - Agent Layer
   - Continuity Layer
   - Hook System
   - Artifact Index
   - Dashboard
3. Data Flow Diagrams
4. Session Lifecycle
5. State Management
6. File System Structure
7. Database Schema
8. Hook Execution Order
9. Agent Communication Protocols
10. Security Model
11. Performance Considerations
12. Extensibility Points

## Diagrams Included
- System architecture diagram (ASCII art)
- Session lifecycle flowchart
- Hook execution sequence
- Agent hierarchy tree
- Data flow diagram
```

---

### 3. AGENT_GUIDE.md
**Length**: ~1500 lines
**Audience**: All users

**Contents**:
```markdown
# Complete Agent Guide

## Table of Contents
1. Understanding Agents
2. Agent Hierarchy
3. Core Agents
   3.1 @chief — Supreme Commander
       - Responsibilities
       - When to invoke
       - Example commands
       - Interaction patterns
   3.2 @SessionOrchestrator — Memory Manager
   3.3 @DiscoveryProtector — Drift Guardian
   3.4 @TechStackFingerprinter — Stack Detector
   3.5 @TeamBuilder — Agent Factory
   3.6 @SpecArchitect — OpenSpec Master
   3.7 @CodebaseCartographer — Architecture Guardian
   3.8 @InfraGuardian — Infrastructure Validator
   3.9 @ProjectAnalyzer — Deep Scanner
   3.10 @OpenSpecPolice — TODO Enforcer

4. New v2026 Agents
   4.1 @PlanAgent — Research & Design
   4.2 @ValidateAgent — Verification
   4.3 @TDDAgent — Test-Driven Development
   4.4 @ContinuityAgent — Ledger Manager

5. Agent Communication
6. Custom Agent Creation
7. Agent Best Practices
8. Troubleshooting Agents

## For Each Agent
- Full description
- Capabilities
- When to use
- How to invoke
- 5+ example scenarios
- Common mistakes
- Interaction patterns
```

---

### 4. SKILLS_REFERENCE.md
**Length**: ~1000 lines
**Audience**: All users

**Contents**:
```markdown
# Complete Skills Reference

## Table of Contents
1. Understanding Skills vs Agents
2. Core Skills (v2025)
   - /skill cost-monitor
   - /skill git-commit
   - /skill pr-review
   - /skill trash-verify
   - /skill approve-specs
   - /skill budget-cap
   - /skill emergency-stop
   - /skill rollback-openspec

3. New Continuity Skills (v2026)
   - /skill continuity-ledger
   - /skill create-handoff
   - /skill query-artifacts
   - /skill tdd-workflow
   - /skill validate-typescript

4. Skill Composition (chaining skills)
5. Creating Custom Skills
6. Skill Best Practices

## For Each Skill
- Purpose
- Syntax
- Parameters (with types)
- 3+ usage examples
- Expected output
- Error handling
- Related skills
```

---

### 5. HOOKS_GUIDE.md
**Length**: ~800 lines
**Audience**: Advanced users

**Contents**:
```markdown
# Hooks System Complete Guide

## Table of Contents
1. Understanding Hooks
2. Hook Lifecycle
3. Hook Execution Order
4. Built-in Hooks
   4.1 SessionStart.js
       - When it fires
       - What it does
       - Configuration options
       - Examples
   4.2 PreToolUse.js
       - TypeScript validation
       - Budget checks
       - Custom validations
   4.3 PostToolUse.js
       - State tracking
       - Artifact indexing
   4.4 PreCompact.js
       - Handoff enforcement
       - State preservation
   4.5 SessionEnd.js
       - Learning extraction
       - Cleanup
   4.6 UserPromptSubmit.js (optional)

5. Custom Hook Creation
6. Hook Configuration
7. Debugging Hooks
8. Performance Impact
9. Hook Best Practices

## Code Examples
- Complete hook implementations
- Custom hook templates
- Testing hooks
- Debugging techniques
```

---

### 6. CONTINUITY_GUIDE.md
**Length**: ~900 lines
**Audience**: All users (critical for session management)

**Contents**:
```markdown
# Session Continuity Complete Guide

## Table of Contents
1. Why Continuity Matters
   - The compaction problem
   - Signal degradation
   - Context window limits

2. Continuity Components
   2.1 Ledgers (within-session state)
       - What is a ledger?
       - Ledger structure
       - When to update
       - Examples
   2.2 Handoffs (cross-session transfer)
       - What is a handoff?
       - Handoff structure
       - When to create
       - Examples
   2.3 Artifact Index (searchable history)
       - Database structure
       - Querying artifacts
       - Examples

3. Workflow Patterns
   3.1 Starting a New Session
   3.2 Resuming After Break
   3.3 Context Clear & Resume
   3.4 Multi-day Projects
   3.5 Team Handoffs

4. Best Practices
   - When to clear context
   - How to structure ledgers
   - Handoff quality checklist
   - Common pitfalls

5. Advanced Patterns
   - Long-running projects
   - Multiple parallel features
   - Knowledge transfer

## Complete Examples
- Full ledger example (50+ lines)
- Full handoff example (100+ lines)
- Query examples (10+ scenarios)
- Workflow walkthroughs
```

---

### 7. DASHBOARD_GUIDE.md
**Length**: ~600 lines
**Audience**: All users

**Contents**:
```markdown
# Dashboard Complete User Guide

## Table of Contents
1. Dashboard Overview
2. Installation & Setup
   - Starting the dashboard
   - Accessing remotely
   - Mobile access

3. Dashboard Sections
   3.1 System Status
       - Session state
       - Agent activity
       - Current task
   3.2 Codebase Map
       - File tracking
       - Dependency graph
       - Change history
   3.3 OpenSpec Status
       - Proposal count
       - Completion percentage
       - Drift detection
   3.4 Artifact Index
       - Search interface
       - Filter options
       - Results view
   3.5 Session Timeline
       - Event history
       - Duration tracking
       - Tool usage
   3.6 Cost Tracking
       - Token usage
       - API costs
       - Budget alerts
   3.7 Agent Activity
       - Active agents
       - Task distribution
       - Performance metrics

4. Advanced Features
   - Custom queries
   - Export data
   - Integrations

5. Mobile Usage
6. Troubleshooting Dashboard

## Screenshots (ASCII art representations)
- Main dashboard view
- Artifact search results
- Timeline visualization
- Cost tracking charts
```

---

### 8. COMMANDS_REFERENCE.md
**Length**: ~500 lines
**Audience**: All users

**Contents**:
```markdown
# Slash Commands Complete Reference

## Table of Contents
1. Understanding Commands
2. Core Commands
   - /bootstrap
   - /status
   - /emergency-stop

3. Continuity Commands
   - /continuity-ledger
   - /create-handoff
   - /query-artifacts
   - /resume-session

4. OpenSpec Commands
   - /openspec-police activate
   - /skill rollback-openspec

5. Development Commands
   - /swap-model
   - /skill tdd-workflow
   - /skill validate-typescript

6. Administrative Commands
   - /skill budget-cap
   - /skill cost-monitor

## For Each Command
- Description
- Syntax
- Parameters
- Examples (3+)
- Expected behavior
- Related commands
```

---

### 9. TROUBLESHOOTING.md
**Length**: ~700 lines
**Audience**: All users

**Contents**:
```markdown
# Troubleshooting Guide

## Table of Contents
1. Quick Fixes (Top 10 Issues)
2. Installation Issues
   - Dependency problems
   - Permission errors
   - Path issues
3. Session Issues
   - Team not responding
   - Drift detected
   - Chat TODOs appearing
   - Wrong model
   - Session not resuming
4. Hook Issues
   - Hooks not firing
   - Hook errors
   - TypeScript validation failing
5. Database Issues
   - Artifact index corruption
   - Query failures
   - Performance problems
6. Dashboard Issues
   - Won't open
   - Not updating
   - CORS errors
7. Agent Issues
   - @chief not responding
   - Agent conflicts
   - Orchestration problems
8. OpenSpec Issues
   - Corruption
   - Drift false positives
   - Backup/rollback
9. Platform-Specific Issues
   - macOS issues
   - Windows/WSL issues
   - Linux issues
10. Getting Help
    - Log collection
    - Bug reporting
    - Community support

## For Each Issue
- Symptoms
- Diagnosis steps
- Solution (step-by-step)
- Prevention tips
```

---

### 10. API_REFERENCE.md
**Length**: ~400 lines
**Audience**: Advanced users, integrators

**Contents**:
```markdown
# API Reference

## Table of Contents
1. Artifact Database API
   - Connection
   - Schema
   - Queries
   - Inserts
   - Updates

2. File System API
   - Directory structure
   - File formats
   - Reading state
   - Writing state

3. Hook API
   - Hook interface
   - Event types
   - Context object
   - Return values

4. MCP Integration
   - Configuration
   - Custom servers
   - Tool registration

5. External Integrations
   - Braintrust tracing
   - Custom dashboards
   - CI/CD integration

## Complete Examples
- Python script to query artifacts
- Bash script to read session state
- Custom hook implementation
- MCP server example
```

---

### 11. MIGRATION_FROM_V2025.md
**Length**: ~400 lines
**Audience**: Existing Legendary Team users

**Contents**:
```markdown
# Migration Guide: v2025 → v2026

## Table of Contents
1. What's New in v2026
2. Breaking Changes (if any)
3. Pre-Migration Checklist
4. Migration Steps
   4.1 Backup Current Setup
   4.2 Run Migration Script
   4.3 Verify Migration
   4.4 Test Core Features
5. Post-Migration Tasks
6. Rollback Procedure
7. FAQ
8. Getting Help

## Complete Examples
- Full migration walkthrough
- Before/after comparison
- Rollback example
```

---

### 12. VIDEO_TUTORIALS.md
**Length**: ~600 lines
**Audience**: All users (tutorial scripts)

**Contents**:
```markdown
# Video Tutorial Scripts

## Table of Contents
1. Tutorial 1: Installation (5 minutes)
2. Tutorial 2: First Bootstrap (10 minutes)
3. Tutorial 3: Understanding Agents (15 minutes)
4. Tutorial 4: Session Continuity (12 minutes)
5. Tutorial 5: Using the Dashboard (8 minutes)
6. Tutorial 6: Advanced Workflows (20 minutes)

## For Each Tutorial
- Duration
- Learning objectives
- Prerequisites
- Complete script (narration)
- Commands to execute
- Expected output
- Key takeaways
```

---

## 📊 DOCUMENTATION STATISTICS

### Total Documentation
- **Total Lines**: ~10,000+
- **Total Words**: ~80,000+
- **Code Examples**: 200+
- **Diagrams**: 15+
- **Screenshots**: 20+ (ASCII art)

### Coverage
- ✅ Beginner-friendly installation
- ✅ Complete feature reference
- ✅ Advanced customization
- ✅ Troubleshooting for all issues
- ✅ API for integrators
- ✅ Migration guide
- ✅ Video tutorial scripts

### Quality Standards
- [ ] Every feature documented
- [ ] 3+ examples per feature
- [ ] Step-by-step instructions
- [ ] Error messages explained
- [ ] Best practices included
- [ ] Common pitfalls covered
- [ ] Links to related docs

---

## 🎨 DOCUMENTATION STYLE GUIDE

### Formatting
```markdown
# H1 for main title
## H2 for major sections
### H3 for subsections

**Bold** for emphasis
`code` for commands/code
```bash
code blocks for examples
```

> Blockquotes for warnings/notes
```

### Structure
1. **Overview** - What is this?
2. **Why** - Why does it matter?
3. **How** - Step-by-step instructions
4. **Examples** - Real-world usage
5. **Troubleshooting** - Common issues
6. **Related** - Links to other docs

### Code Examples
- Always complete (not fragments)
- Always tested
- Include expected output
- Show error cases
- Explain each step

---

## 📝 SPECIAL DOCUMENTATION: DASHBOARD GUIDE

### Dashboard Guide Structure
```markdown
# Dashboard Complete Guide

## Overview
The Legendary Team Dashboard provides real-time visibility into your AI engineering team's operations. It's a single HTML file that runs in any modern browser, with no installation required.

## Features at a Glance
- 📊 Real-time system status
- 🗺️ Live codebase map
- 📋 OpenSpec tracking
- 🔍 Artifact search
- ⏱️ Session timeline
- 💰 Cost monitoring
- 🤖 Agent activity

## Quick Start

### Starting the Dashboard
```bash
# Method 1: Automatic (opens in default browser)
./legendary-dashboard.sh

# Method 2: Manual
open legendary-dashboard.html

# Method 3: HTTP Server (for remote access)
python3 -m http.server 8080
# Then visit: http://localhost:8080/legendary-dashboard.html
```

### Mobile Access
```bash
# Find your local IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# Start server
python3 -m http.server 8080

# On mobile, visit: http://YOUR-IP:8080/legendary-dashboard.html
```

## Dashboard Layout

### Top Section: System Status
┌─────────────────────────────────────────┐
│  LEGENDARY TEAM 2026 — LIVE STATUS     │
│                                         │
│  ● ACTIVE                               │
│  Last bootstrap: 2026-01-09 12:00:00   │
│  Version: 2026-legendary-ultimate      │
│  Uptime: 2h 15m                        │
└─────────────────────────────────────────┘

**What it shows:**
- Green ● = Active session
- Yellow ● = Idle (no activity 5+ min)
- Red ● = Offline or error
- Last bootstrap timestamp
- System version
- Session uptime

### Middle Section: Codebase & OpenSpec
┌─────────────────────────────────────────┐
│  📁 CODEBASE MAP                        │
│  Files tracked: 247                    │
│  Last scan: 30 seconds ago             │
│  Drift: 0% ✓                           │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  📋 OPENSPEC STATUS                     │
│  Total proposals: 12                   │
│  Completed: 8 (67%)                    │
│  In progress: 3                        │
│  Blocked: 1                            │
└─────────────────────────────────────────┘

### Bottom Section: Artifacts & Timeline
┌─────────────────────────────────────────┐
│  🔍 ARTIFACT SEARCH                     │
│  ┌───────────────────────────────────┐ │
│  │ Search handoffs, plans, learnings│ │
│  └───────────────────────────────────┘ │
│                                         │
│  Recent artifacts:                     │
│  • handoff-20260109-auth-feature.md   │
│  • plan-dark-mode-implementation.md   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  ⏱️ SESSION TIMELINE                    │
│  12:00 ▶ Bootstrap started              │
│  12:05 ▶ Discovery complete             │
│  12:10 ▶ Specs approved                 │
│  12:15 ▶ Implementation started         │
│  12:45 ▶ Tests passing ✓                │
└─────────────────────────────────────────┘

## Using Each Feature

### 1. System Status Monitor
**Purpose**: Quick health check of your team

**Indicators:**
- **Active** (green): Team is working
- **Idle** (yellow): No activity, but ready
- **Offline** (red): Check if Claude is running

**Actions:**
- Click version to see changelog
- Click uptime to see detailed timeline

### 2. Codebase Map
**Purpose**: Track file changes and detect drift

**Key Metrics:**
- **Files tracked**: Total files in project
- **Last scan**: When last updated
- **Drift**: Percentage mismatch vs OpenSpec
  - 0-5%: Normal ✓
  - 5-15%: Warning ⚠️
  - 15%+: Critical 🚨

**Actions:**
- Click "Files tracked" to see full list
- Click "Drift" to see details

### 3. OpenSpec Status
**Purpose**: Track proposal completion

**Metrics:**
- **Total proposals**: All specs created
- **Completed**: Fully implemented ✓
- **In progress**: Currently working ⏳
- **Blocked**: Waiting for approval 🚫

**Actions:**
- Click any number to filter view
- See proposal details

### 4. Artifact Search
**Purpose**: Find past work, plans, learnings

**How to use:**
1. Type search term (e.g., "authentication")
2. Results appear instantly (FTS5 search)
3. Click result to view full content
4. Filter by type: handoffs, plans, learnings

**Search Examples:**
- "login bug" - Find auth-related work
- "API design" - Find API decisions
- "performance" - Find optimization work
- "failed" - Find what didn't work

### 5. Session Timeline
**Purpose**: See what happened when

**Timeline shows:**
- Bootstrap and initialization
- Discovery and fingerprinting
- Spec approval checkpoints
- Implementation milestones
- Test results
- Deployments

**Actions:**
- Click event to see details
- See tool usage per event
- View token costs per event

### 6. Cost Tracking (Enhanced)
┌─────────────────────────────────────────┐
│  💰 COST TRACKING                       │
│  Today: $2.34 / $50 budget             │
│  ████████░░░░░░░░░░ 47%                │
│                                         │
│  This session: $0.47                   │
│  Tokens: 125,432 input / 8,234 output  │
└─────────────────────────────────────────┘

**Budget alerts:**
- Green bar: Under 70%
- Yellow bar: 70-90%
- Red bar: 90%+ or over budget

**Actions:**
- Click to see breakdown by agent
- Set custom budget limit
- Export cost report

### 7. Agent Activity Monitor (New)
┌─────────────────────────────────────────┐
│  🤖 AGENT ACTIVITY                      │
│  @chief           ████████ Active       │
│  @PlanAgent       ████░░░░ Idle         │
│  @ValidateAgent   ████████ Active       │
│  @ImplementAgent  ████████ Active       │
└─────────────────────────────────────────┘

**Shows:**
- Which agents are active
- Current task per agent
- Tool usage per agent
- Agent performance metrics

## Advanced Features

### Custom Queries
```javascript
// Query artifact database directly
fetch('/.claude/cache/artifact-index/context.db')
  .then(/* SQLite query */)
```

### Export Data
```bash
# Export session timeline
curl http://localhost:8080/api/timeline > timeline.json

# Export cost report
curl http://localhost:8080/api/costs > costs.csv
```

### Keyboard Shortcuts
- `Ctrl+/` - Focus search
- `Ctrl+R` - Force refresh
- `Ctrl+T` - Toggle timeline
- `Ctrl+C` - Show cost details
- `Esc` - Close modals

## Mobile Usage

### Responsive Design
- ✅ Works on phones (iPhone, Android)
- ✅ Works on tablets (iPad, etc.)
- ✅ Touch-optimized controls
- ✅ Portrait and landscape modes

### Setup for Mobile
1. Start HTTP server: `python3 -m http.server 8080`
2. Find your computer's IP: `ifconfig` (Mac/Linux) or `ipconfig` (Windows)
3. On mobile browser: `http://YOUR-IP:8080/legendary-dashboard.html`
4. Bookmark for quick access
5. Add to home screen (looks like native app)

### Mobile Tips
- Use landscape mode for full view
- Swipe left/right to navigate sections
- Pull down to refresh
- Pinch to zoom timeline

## Troubleshooting Dashboard

### Dashboard won't open
**Symptom**: File opens but shows errors
**Cause**: CORS restrictions when using file:// protocol
**Solution**:
```bash
# Use HTTP server instead
python3 -m http.server 8080
# or
npx serve .
```

### Dashboard not updating
**Symptom**: Status shows old data
**Solution**:
- Hard refresh: Ctrl+Shift+R (or Cmd+Shift+R on Mac)
- Check if Claude is running
- Check if hooks are active: `/status`

### Search not working
**Symptom**: No results or errors
**Cause**: Artifact index not initialized
**Solution**:
```bash
# Reinitialize database
./scripts/init-artifact-index.sh
```

### High CPU usage
**Symptom**: Browser slow, fan spinning
**Cause**: Refresh interval too fast
**Solution**:
- Change refresh from 5s to 30s
- Edit dashboard HTML: `setInterval(update, 30000)`

## Dashboard API (Advanced)

### Endpoints
```
GET  /.claude/session-state.json        # System status
GET  /.claude/codebase-map.json         # File tracking
GET  /openspec/master-index.yaml        # OpenSpec data
POST /api/query-artifacts               # Search artifacts
GET  /api/timeline                      # Session events
GET  /api/costs                         # Token usage
```

### Custom Integrations
```javascript
// Example: Slack notifications on drift
async function checkDrift() {
  const map = await fetch('/.claude/codebase-map.json').then(r => r.json());
  if (map.drift_percentage > 15) {
    await fetch('SLACK_WEBHOOK', {
      method: 'POST',
      body: JSON.stringify({text: `🚨 Drift at ${map.drift_percentage}%`})
    });
  }
}
```

## Best Practices

1. **Keep dashboard open** during development
2. **Check drift regularly** (should stay <5%)
3. **Use search** to find past decisions
4. **Monitor costs** to stay in budget
5. **Review timeline** to understand what happened
6. **Export data** for retrospectives

## FAQ

**Q: Can I customize the dashboard?**
A: Yes! Edit `legendary-dashboard.html` - it's just HTML/CSS/JS

**Q: Can multiple people view the same dashboard?**
A: Yes! Start HTTP server and share your local IP

**Q: Does it work offline?**
A: Partially - status works, but search requires database access

**Q: Can I integrate with other tools?**
A: Yes! Use the API endpoints or query SQLite directly

**Q: Is there a dark/light theme toggle?**
A: Yes! Click theme icon in top-right corner
```

This would be the complete dashboard guide - approximately 600+ lines with full examples, troubleshooting, and advanced usage patterns.

---

**Ready to proceed?** This documentation plan shows what users will receive in Phase 8.

**Shall we begin Phase 1 now?**
