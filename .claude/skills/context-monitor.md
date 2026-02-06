# Context Monitor Skill

Monitor and optimize context window usage during sessions.

## Commands

### Check Context Usage
```
/context-check
```
Returns: `Context: [X]% | Tokens: [used]/[max] | Status: [OK/WARNING/CRITICAL]`

### Get Optimization Suggestions
```
/context-optimize
```
Analyzes current context and suggests reductions.

## Thresholds

| Level | Usage | Action |
|-------|-------|--------|
| OK | <70% | Continue normally |
| WARNING | 70-85% | Consider `/compact` |
| CRITICAL | >85% | Immediate `/compact` or `/clear` |

## Optimization Actions

### At 70% (WARNING)
1. Switch to lite agents if using full
2. Summarize completed tasks
3. Clear tool output history
4. Consider proactive compaction

### At 85% (CRITICAL)
1. Immediate compaction
2. Create handoff for continuity
3. Preserve: current task, active plan, pending approvals
4. Summarize: completed work, decisions, learnings

## Context Reduction Checklist

- [ ] Using lite agents? (`.claude/agents-lite/`)
- [ ] CLAUDE.md under 150 tokens?
- [ ] History limited to 6 turns?
- [ ] Tool outputs truncated?
- [ ] JSON responses compressed?
- [ ] Unused agent definitions removed?

## Quick Reference

```bash
# Check context
/context

# Compact conversation
/compact

# Clear and restart
/clear

# View what's consuming context
/context --verbose
```

## Token Budget Guidelines

| Component | Target | Max |
|-----------|--------|-----|
| CLAUDE.md | 100 | 150 |
| Agent (lite) | 200 | 400 |
| Agent (full) | 800 | 1500 |
| Tool response | 50 lines | 100 lines |
| History | 6 turns | 10 turns |
