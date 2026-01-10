# Thoughts Directory

This directory contains the continuity system for Legendary Team v2026.

## Structure

```
thoughts/
├── ledgers/              # Within-session continuity (temporary, per session)
├── shared/
│   ├── handoffs/        # Cross-session transfer (permanent, searchable)
│   └── plans/           # Implementation plans (permanent)
└── README.md            # This file
```

## Purpose

The continuity system solves the context degradation problem in long-running AI sessions.

### The Problem
When Claude's context window fills up, traditional "compaction" (summarization) leads to signal degradation:
- Summary of a summary of a summary...
- Loss of important details
- Introduction of hallucinations
- Cumulative error amplification

### The Solution: "Clear, Don't Compact"
Instead of compacting, we:
1. Save state to a ledger (within session)
2. Clear context for fresh start
3. Reload ledger automatically
4. Create handoffs for cross-session transfer

## Components

### 1. Ledgers (`ledgers/`)
**Purpose**: Maintain state within a single session

**Lifespan**: Session-scoped (cleared after session ends)

**Format**: `CONTINUITY_CLAUDE-YYYYMMDD-HHMMSS.md`

**Contains**:
- Current goal and constraints
- Completed work (with file:line references)
- Key decisions made
- Current focus and next steps
- Blockers and dependencies

**When to use**:
- Session is active and ongoing
- Context is getting full (>80%)
- Before executing `/clear`
- During long implementations

**Example**:
```markdown
# Continuity Ledger - Add Authentication System

## Goal
Implement JWT-based authentication with refresh tokens

## Constraints
- Must use existing User model
- No breaking changes to API
- Must be backwards compatible

## Completed
✅ Created auth middleware (src/middleware/auth.ts:1-45)
✅ Added JWT generation (src/utils/jwt.ts:10-25)
✅ Updated User model with tokens (src/models/User.ts:34)

## Current Focus
Working on refresh token endpoint (src/routes/auth.ts:67)

## Next Steps
1. Add token refresh endpoint
2. Add logout functionality
3. Write tests for auth flow

## Blockers
None currently
```

### 2. Handoffs (`shared/handoffs/`)
**Purpose**: Transfer work between sessions or to other developers

**Lifespan**: Permanent (committed to git, indexed in database)

**Format**: `handoff-YYYYMMDD-feature-name.md`

**Contains**:
- Session summary and outcome (SUCCEEDED/PARTIAL/FAILED)
- All file changes with file:line references
- Key learnings and decisions
- What worked and what didn't
- Known issues and next steps
- Context for future work

**When to use**:
- Before ending a session
- When switching to different work
- Before context compaction (automated)
- For team knowledge transfer

**Example**:
```markdown
# Handoff - Authentication System Implementation

**Date**: 2026-01-09
**Session**: 2h 15m
**Outcome**: PARTIAL (80% complete)

## Summary
Implemented JWT-based authentication system with token generation,
validation middleware, and login endpoint. Refresh token logic
remains incomplete.

## Changes Made

### src/middleware/auth.ts (NEW)
- Lines 1-45: JWT validation middleware
- Validates token from Authorization header
- Attaches user to request object
- Returns 401 on invalid/expired tokens

### src/utils/jwt.ts (NEW)
- Lines 10-25: Token generation
- Uses jsonwebtoken library
- 15min access tokens, 7d refresh tokens
- Signs with JWT_SECRET from env

### src/models/User.ts (MODIFIED)
- Line 34: Added refreshToken field (string, optional)
- Compatible with existing schema

## What Worked
✅ Middleware integration was seamless
✅ Token validation is solid
✅ No breaking changes to existing API

## What Didn't Work
❌ Refresh token endpoint kept failing tests
❌ Token storage strategy needs rethinking

## Key Decisions
1. Chose JWT over sessions for scalability
2. Used existing User model to avoid migration
3. Made refresh tokens optional for backwards compat

## Known Issues
- Refresh token endpoint incomplete (src/routes/auth.ts:67)
- Need to handle token blacklisting on logout
- No tests for refresh flow yet

## Next Steps
1. Complete refresh token endpoint
2. Add logout with token invalidation
3. Write comprehensive auth tests
4. Add rate limiting to auth endpoints

## Context for Future Work
The refresh token logic is complex because we're trying to
maintain backwards compatibility. Consider creating a separate
AuthToken model if this becomes unwieldy.
```

### 3. Plans (`shared/plans/`)
**Purpose**: Store implementation plans before execution

**Lifespan**: Permanent (version controlled)

**Format**: `plan-feature-name.md`

**Contains**:
- Problem statement
- Proposed solution
- Architecture decisions
- Implementation steps
- Risk assessment
- Rollback plan

**When to use**:
- Before starting complex features
- After research/design phase
- For architectural decisions
- For team alignment

**Example**:
```markdown
# Implementation Plan - Dark Mode

## Problem
Users want dark mode support with theme persistence

## Proposed Solution
Add theme context, CSS variables, and localStorage persistence

## Architecture Decisions
1. Use CSS custom properties for theming (not separate stylesheets)
2. React Context for theme state
3. localStorage for persistence
4. System preference detection as fallback

## Implementation Steps
1. Create ThemeContext with light/dark/auto modes
2. Define CSS variables in global stylesheet
3. Add theme toggle component
4. Implement localStorage persistence
5. Add system preference detection
6. Update all components to use CSS variables
7. Add tests for theme switching

## Risk Assessment
- LOW: CSS variables supported in all target browsers
- MEDIUM: Need to test all components in dark mode
- LOW: localStorage is widely supported

## Rollback Plan
If dark mode breaks:
1. Remove ThemeContext provider
2. Restore original CSS
3. Remove toggle component
4. Clear localStorage theme key
```

## Workflow Patterns

### Pattern 1: Long Session with Multiple Clears
```
Session Start
↓
Work on feature
↓
Context getting full (80%)
↓
Update ledger: /skill continuity-ledger
↓
Execute: /clear
↓
(SessionStart hook auto-loads ledger)
↓
Continue work
↓
Repeat as needed
↓
Session End → Create handoff
```

### Pattern 2: Multi-Day Project
```
Day 1 Session:
- Work on feature
- Create handoff before ending session

Day 2 Session:
- SessionStart hook loads latest handoff
- Continue where left off
- Update handoff when done

Day 3 Session:
- Resume from handoff
- Complete feature
- Final handoff marked SUCCEEDED
```

### Pattern 3: Team Collaboration
```
Developer A:
- Works on feature
- Gets stuck on issue
- Creates detailed handoff

Developer B:
- Reads handoff
- Solves the issue
- Updates handoff with solution

Developer A:
- Reads updated handoff
- Learns from solution
- Continues work
```

## Best Practices

### Ledgers
✅ Update frequently (every 30min of work)
✅ Be specific with file:line references
✅ Track decisions, not just tasks
✅ Note what you tried that didn't work
✅ Keep "Current Focus" section updated

❌ Don't wait until context is full
❌ Don't use vague descriptions
❌ Don't skip the "why" behind decisions

### Handoffs
✅ Create before ending session
✅ Be thorough - future you will thank you
✅ Include context for decisions
✅ Note what didn't work (save others time)
✅ Provide clear next steps

❌ Don't rush handoff creation
❌ Don't assume context is obvious
❌ Don't skip known issues
❌ Don't forget to update outcome status

### Plans
✅ Create before implementation
✅ Get validation (from @ValidateAgent)
✅ Include rollback strategy
✅ Document architectural decisions
✅ Update if plan changes

❌ Don't code before planning
❌ Don't skip risk assessment
❌ Don't forget to validate plan

## Integration with Hooks

The continuity system is automated via hooks:

**SessionStart.js**:
- Auto-loads current ledger if exists
- Auto-loads latest handoff if session is new
- No manual intervention required

**PostToolUse.js**:
- Auto-indexes handoffs into artifact database
- Tracks file modifications
- Updates codebase map

**PreCompact.js**:
- BLOCKS manual compaction
- Forces handoff creation
- Ensures no work is lost

**SessionEnd.js**:
- Prompts for handoff if not created
- Extracts learnings
- Cleans up temporary ledgers

## Git Strategy

**Committed to git**:
- ✅ thoughts/shared/handoffs/*.md
- ✅ thoughts/shared/plans/*.md
- ✅ This README

**Ignored (temporary)**:
- ❌ thoughts/ledgers/*.md (session-scoped)

See `.gitignore` for details.

## Artifact Index

All handoffs and plans are automatically indexed in:
```
.claude/cache/artifact-index/context.db
```

This SQLite database enables:
- Full-text search (FTS5)
- Query by date, outcome, or keywords
- Dashboard integration
- Cross-session learning

Query artifacts with:
```
/skill query-artifacts "authentication"
```

## Tips for Success

1. **Update ledgers proactively** - Don't wait for context to fill
2. **Be generous with detail in handoffs** - Future you has no context
3. **Create plans before coding** - Saves time, prevents rework
4. **Use file:line references** - Makes future work much easier
5. **Track what didn't work** - Prevents repeating mistakes
6. **Keep handoffs in git** - They're valuable documentation

## Examples

See templates:
- `templates/ledger-template.md`
- `templates/handoff-template.md`
- `templates/plan-template.md`

---

**Remember**: The continuity system is your safety net. Use it liberally.
When in doubt, create a ledger. When ending a session, create a handoff.
Your future self will thank you.
