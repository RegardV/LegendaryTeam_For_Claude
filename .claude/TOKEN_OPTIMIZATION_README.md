# Token Optimization System

## Overview

The Legendary Team 2026 Ultimate includes a comprehensive token optimization system that reduces context usage by **50-84%** while maintaining full functionality.

## Architecture

```
.claude/
├── agents/              # Original agents (backward compatibility)
├── agents-lite/         # Optimized minimal agents (~200 tokens each)
├── agents-full/         # Full agent definitions (on-demand loading)
├── skills/
│   ├── output-compression.md  # Compressed output formats
│   └── context-monitor.md     # Context usage monitoring
└── hooks/
    └── config.json      # Token optimization settings
```

## Key Features

### 1. Lite Agents (Default)
- Reduced from ~800 tokens to ~200 tokens per agent
- Contains essential information only
- References full docs when needed

### 2. Dynamic Agent Loading
- Only `@chief` and `@ConfidenceAgent` load by default
- Other agents load on-demand based on task keywords
- Reduces agent definition overhead by 70-98%

### 3. Context Management
- Proactive compaction at 70% (not 95%)
- History limited to 6 turns
- Automatic summarization after 10 turns

### 4. Output Compression
- Compact status formats
- Truncated tool responses (50 lines max)
- Compressed JSON serialization

## Configuration

Edit `.claude/hooks/config.json`:

```json
{
  "tokenOptimization": {
    "enabled": true,
    "agentMode": "lite",        // "lite" or "full"
    "dynamicLoading": {
      "enabled": true,
      "alwaysLoad": ["chief", "confidence-agent"]
    },
    "contextManagement": {
      "compactThreshold": 0.70,
      "maxHistoryTurns": 6
    }
  }
}
```

## Usage

### Switch Agent Modes
```bash
# Use lite agents (default, optimized)
# Set in config: "agentMode": "lite"

# Use full agents (for complex tasks)
# Set in config: "agentMode": "full"
```

### Monitor Context
```bash
/context           # Check usage
/context --verbose # See what's consuming space
```

### Manual Optimization
```bash
/compact           # Summarize conversation
/clear             # Start fresh
```

## Expected Savings

| Component | Before | After | Savings |
|-----------|--------|-------|---------|
| CLAUDE.md | 300+ | 100 | 67% |
| Agent (each) | 800 | 200 | 75% |
| All agents loaded | 12,000 | 400 | 97% |
| Tool responses | Unlimited | 50 lines | 60-80% |
| History | Unlimited | 6 turns | 50-70% |

**Total potential: 50-84% token reduction**

## Backward Compatibility

- Original agents preserved in `.claude/agents/`
- Full agents available in `.claude/agents-full/`
- Set `"agentMode": "full"` to use original behavior

## Related Files

- `TOKEN_OPTIMIZATION_RESEARCH.md` - Research and methodology
- `.claude/skills/output-compression.md` - Output format guidelines
- `.claude/skills/context-monitor.md` - Monitoring skill

## Version

- **Implemented**: 2026-02-06
- **Version**: 2026-ultimate-optimized
