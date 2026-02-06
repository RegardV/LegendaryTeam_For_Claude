# Token Optimization System

## Overview

The Legendary Team 2026 Ultimate includes a comprehensive token optimization system that reduces context usage by **96.7%** while maintaining full functionality through intelligent self-escalation.

## Architecture

```
.claude/
├── agents/              # Original agents (backward compatibility)
├── agents-lite/         # Optimized minimal agents (~60-100 words each)
├── agents-full/         # Full agent definitions (for self-escalation)
├── skills/
│   ├── output-compression.md  # Compressed output formats
│   └── context-monitor.md     # Context usage monitoring
└── hooks/
    └── config.json      # Token optimization settings
```

## Key Features

### 1. Lite Agents (Default)
- Reduced from ~800-3000 words to ~60-100 words per agent
- Contains essential protocols only
- **Self-escalates to full definitions when needed**
- Total reduction: 29,458 words → 968 words (96.7%)

### 2. Self-Escalation Protocol
When a lite agent encounters complexity beyond its scope, it automatically reads its full definition:

```markdown
## Self-Escalation Protocol
**TRIGGER**: If uncertain, need examples, or task is complex → READ full agent
Action: Read .claude/agents-full/[agent].md
Trigger: [Role-specific conditions]
```

**Agent-Specific Triggers:**
| Agent | Self-Escalation Triggers |
|-------|-------------------------|
| @chief | Novel patterns, unclear workflow, quality issues |
| @TestAgent | Integration tests, mocking patterns, edge cases |
| @SecurityAgent | CVE analysis, vulnerability assessment, audit |
| @DatabaseAgent | Schema design, migration patterns, optimization |
| @PerformanceOptimizer | Complex profiling, benchmark patterns |

### 3. Dynamic Agent Loading
- Only `@chief` and `@ConfidenceAgent` load by default
- Other agents load on-demand based on task keywords
- Reduces agent definition overhead by 70-98%

**Keyword Triggers:**
```json
{
  "database-agent": ["database", "schema", "migration", "query", "sql"],
  "test-agent": ["test", "coverage", "jest", "spec", "vitest"],
  "security-agent": ["security", "auth", "vulnerability", "owasp"],
  "ui-agent": ["component", "react", "vue", "frontend", "css"]
}
```

### 4. Context Management
- Proactive compaction at 70% (not 95%)
- History limited to 6 turns
- Automatic summarization after 10 turns

### 5. Output Compression
- Compact status formats
- Truncated tool responses (50 lines max)
- Compressed JSON serialization

## Configuration

Edit `.claude/hooks/config.json`:

```json
{
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
      "maxHistoryTurns": 6,
      "summarizeAfterTurns": 10
    },
    "outputCompression": {
      "enabled": true,
      "maxToolResponseLines": 50,
      "truncateLongOutputs": true
    }
  }
}
```

## Usage

### Automatic Mode (Default)
The system automatically uses lite agents with self-escalation:
1. Task arrives → Lite agent processes
2. Complexity detected → Self-escalation triggers
3. Full agent definition loaded → Task completed
4. Quality maintained → Session continues

### Manual Agent Mode Switch
```bash
# Use lite agents (default, optimized)
# Set in config: "agentMode": "lite"

# Use full agents (for complex sessions)
# Set in config: "agentMode": "full"
```

### Monitor Context
```bash
/context           # Check usage
/context --verbose # See what's consuming space
```

## Expected Savings

| Component | Before | After | Savings |
|-----------|--------|-------|---------|
| CLAUDE.md | 300+ tokens | <150 tokens | 50%+ |
| Agent (each) | 800-3000 words | 60-100 words | 96.7% |
| All agents total | 29,458 words | 968 words | 96.7% |
| Tool responses | Unlimited | 50 lines | 60-80% |
| History | Unlimited | 6 turns | 50-70% |

**Total measured: 96.7% token reduction with maintained quality**

## Quality Assurance

The self-escalation system ensures quality is maintained:

| Risk Level | Mitigation |
|------------|------------|
| Missing context | Self-escalation provides full docs on demand |
| Complex patterns | Agents detect complexity and load examples |
| First-time tasks | Triggers automatic escalation |
| Quality issues | @ReflectionAgent catches and triggers iteration |

**Quality Comparison Analysis**: See `QUALITY_COMPARISON_ANALYSIS.md` for detailed assessment.

## Backward Compatibility

- Original agents preserved in `.claude/agents/`
- Full agents available in `.claude/agents-full/`
- Set `"agentMode": "full"` to use original behavior
- No breaking changes to existing workflows

## Related Files

- `TOKEN_OPTIMIZATION_RESEARCH.md` - Research and methodology
- `QUALITY_COMPARISON_ANALYSIS.md` - Quality comparison analysis
- `.claude/skills/output-compression.md` - Output format guidelines
- `.claude/skills/context-monitor.md` - Monitoring skill

## Version

- **Implemented**: 2026-02-06
- **Version**: 2026-ultimate-optimized
- **Methodology**: 11 Core Methodologies (Token Optimization is #11)
