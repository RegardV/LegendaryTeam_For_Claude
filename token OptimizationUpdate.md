# Token Optimisation update
New Architecture
.claude/
├── agents/              # Original (backward compatible)
├── agents-lite/         # NEW: Optimized (~200 tokens each)
├── agents-full/         # NEW: Full definitions (on-demand)
├── skills/
│   ├── output-compression.md  # NEW: Compact formats
│   └── context-monitor.md     # NEW: Usage monitoring
└── hooks/config.json    # UPDATED: Token optimization settings

Implementation Summary
Component	Before	After	Savings
CLAUDE.md	300+ tokens	~100 tokens	67%
Agent (lite)	800 tokens	200 tokens	75%
All agents loaded	12,000+	400 (2 always)	97%
History	Unlimited	6 turns max	50-70%
Key Features Implemented
Lite Agents (12 files in .claude/agents-lite/)

@chief, @Planner, @Verifier, @ReflectionAgent
@TestAgent, @DatabaseAgent, @UIAgent, @SecurityAgent
And 4 more specialists
Dynamic Agent Loading (in hooks/config.json)

Only @chief and @ConfidenceAgent load by default
Other agents load based on task keywords
Reduces overhead by 70-98%
Context Management

Proactive compaction at 70% (not 95%)
History limited to 6 conversation turns
Automatic summarization after 10 turns
Output Compression Skill

Compact status formats: ✅ [agent]:[task] | Files:[n] | Tests:[pass]
Truncated tool responses (50 lines max)
Compressed JSON serialization
Context Monitor Skill

/context-check - View usage percentage
Thresholds: OK (<70%), WARNING (70-85%), CRITICAL (>85%)
Configuration
The system is enabled by default in .claude/hooks/config.json:

{
  "tokenOptimization": {
    "enabled": true,
    "agentMode": "lite",
    "dynamicLoading": { "enabled": true },
    "contextManagement": { "compactThreshold": 0.70 }
  }
}

Expected Total Savings: 50-84%
