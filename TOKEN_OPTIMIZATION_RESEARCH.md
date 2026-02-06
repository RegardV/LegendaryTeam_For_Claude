# Token Optimization Research for Legendary Team

**Research Date**: 2026-02-06
**Purpose**: Identify token optimization strategies from forums and communities to enhance Legendary Team efficiency

---

## Executive Summary

Research across multiple sources reveals that **multi-agent systems consume 15x more tokens than single chats**, making optimization critical. The good news: applying the strategies below can achieve **50-90% token reduction** while maintaining or improving quality.

Key insight: **Context editing + memory tools reduced token consumption by 84%** in Anthropic's own testing.

---

## Research Sources

### Official Documentation
- [Claude Code Cost Management](https://code.claude.com/docs/en/costs)
- [Anthropic Context Windows Documentation](https://platform.claude.com/docs/en/build-with-claude/context-windows)
- [How Claude Code Got Better by Protecting More Context](https://hyperdev.matsuoka.com/p/how-claude-code-got-better-by-protecting)

### Community & Engineering Blogs
- [Stop Wasting Tokens: Optimize Claude Code Context by 60%](https://medium.com/@jpranav97/stop-wasting-tokens-how-to-optimize-claude-code-context-by-60-bfad6fd477e5)
- [Claude Code Token Management: 8 Strategies to Save 50-70%](https://dev.to/richardporter/claude-code-token-management-8-strategies-to-save-50-70-on-pro-plan-3hob)
- [Token Optimization Strategies for AI Agents](https://medium.com/elementor-engineers/optimizing-token-usage-in-agent-based-assistants-ffd1822ece9c)
- [Context Engineering in Multi-Agent Systems](https://www.agno.com/blog/context-engineering-in-multi-agent-systems)
- [How Anthropic Built Their Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system)

### Research Papers
- [LLMLingua: Prompt Compression](https://llmlingua.com/)
- [ContextEvolve: Multi-Agent Context Compression](https://arxiv.org/html/2602.02597)
- [Stop Wasting Your Tokens: Efficient Runtime Multi-Agent Systems](https://arxiv.org/html/2510.26585v1)

---

## Key Findings

### 1. Multi-Agent Token Consumption Problem

> "Multi-agent architectures consume tokens rapidly. Agents typically use about **4x more tokens** than chat interactions, and multi-agent systems use about **15x more tokens** than chats."

**Relevance to Legendary Team**: With 17 specialized agents and parallel execution, token consumption can escalate rapidly without proper management.

### 2. Context Explosion in Agent Hierarchies

> "If a root agent passes its full history to a sub-agent, and that sub-agent does the same, you trigger a **context explosion**. The token count skyrockets, and sub-agents get confused by irrelevant conversational history."

**Relevance**: @chief coordinates multiple agents - without isolation, context bloats exponentially.

### 3. Anthropic's Context Editing Results

> "In a 100-turn web search evaluation, context editing enabled agents to complete workflows that would otherwise fail due to context exhaustion—while reducing token consumption by **84%**."

> "Combining the memory tool with context editing improved performance by **39% over baseline**, with context editing alone delivering a **29% improvement**."

---

## Actionable Recommendations for Legendary Team

### Priority 1: CLAUDE.md Optimization (Immediate Impact)

**Problem**: CLAUDE.md loads on every prompt. Currently, the Legendary Team has extensive documentation that may be loading unnecessarily.

**Solution**: Keep CLAUDE.md under **150 tokens** with essential directives only.

```markdown
# Current CLAUDE.md - Too Verbose
CLAUDE.md - LEGENDARY AUTONOMOUS TEAM – 2026 ULTIMATE EDITION
ONLY @chief may orchestrate.
OPEN-SPEC IS BACKED UP BEFORE EVERY CHANGE
Last 10 versions kept in openspec/.backup/
... (continues for 300+ tokens)

# Optimized CLAUDE.md - Essential Only
@chief orchestrates. Specs in OpenSpec/. Backup auto-enabled.
Run /bootstrap for full context. See .claude/rules/ for behavior.
```

**Expected Savings**: 60-80% reduction in per-prompt overhead

---

### Priority 2: Agent Context Isolation

**Problem**: Subagents receiving full conversation history.

**Solution**: Implement context isolation pattern from [Google's ADK](https://developers.googleblog.com/architecting-efficient-context-aware-multi-agent-framework-for-production/):

```
# Before (Context Explosion)
@chief → full context → @DatabaseAgent → full context → @TestAgent
Result: 3x context duplication

# After (Context Isolation)
@chief → task summary only → @DatabaseAgent → returns result reference
@chief → task summary only → @TestAgent → fetches reference as needed
Result: 67% fewer tokens processed
```

**Implementation for Legendary Team**:
1. Each agent receives only: task description, relevant file references, success criteria
2. Results stored in `thoughts/shared/` as lightweight references
3. @chief maintains master context; subagents work in isolation

---

### Priority 3: Dynamic Tool Loading

**Problem**: All 17 agent tool definitions load with every prompt.

> "If your agent is connected to 50 tools, sending all 50 tool definitions in every prompt is a massive waste. Modern implementations use **Discovery-Based Loading** where the agent requests the specific tool schema only when it's needed. Token usage for 'System Instructions' drops by up to **98%**."

**Solution**: Implement lazy agent loading:

```javascript
// In hooks/config.json - Add dynamic loading
{
  "agentLoading": {
    "mode": "dynamic",
    "alwaysLoad": ["chief", "confidence-agent"],
    "loadOnDemand": ["database-agent", "ui-agent", "test-agent", ...],
    "loadTriggers": {
      "database-agent": ["database", "schema", "migration", "query"],
      "ui-agent": ["component", "react", "ui", "frontend"],
      "test-agent": ["test", "coverage", "jest", "spec"]
    }
  }
}
```

**Expected Savings**: 70-98% reduction in agent definition overhead

---

### Priority 4: History Limiting

**Problem**: Unbounded conversation history in long sessions.

> "By keeping only the last 6 messages (3 exchanges), you prevent the input token count from growing unbounded."

**Solution**: Implement rolling history buffer:

```javascript
// Session management enhancement
{
  "historyManagement": {
    "maxTurns": 6,
    "summarizeAfter": 10,
    "preserveTypes": ["error", "decision", "approval"]
  }
}
```

---

### Priority 5: Data Serialization Optimization

**Problem**: Verbose JSON structures in tool responses.

> "Poor data serialization consumes **40% to 70%** of available tokens through unnecessary formatting overhead."

> "CSV outperforms JSON by **40% to 50%** for tabular data."

**Solution**: Implement response compression in agent outputs:

```javascript
// Before (Verbose JSON)
{
  "user": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "admin",
    "createdAt": "2026-01-15T10:30:00Z",
    "updatedAt": "2026-02-01T14:22:00Z",
    "lastLogin": "2026-02-06T09:15:00Z"
  }
}

// After (Compressed)
user:123|John Doe|admin|active
```

---

### Priority 6: Prompt Caching Structure

**Problem**: Not maximizing cache hits for repeated content.

> "Cached tokens are **75% cheaper** to process. Move static system prompt parts to the top."

**Solution**: Restructure agent prompts for caching:

```markdown
# Agent Prompt Structure (Optimized for Caching)

## STATIC SECTION (Cached - Put First)
You are @TestAgent. You write tests.
Coverage requirement: 80%.
Framework: Jest/Vitest.
Report format: coverage/file/line.

## DYNAMIC SECTION (Not Cached - Put Last)
Current task: {task_description}
Files to test: {file_list}
```

---

### Priority 7: External Memory System (Future Enhancement)

**Problem**: Re-processing same information across sessions.

> "Mem0 achieves **91% faster responses** than full-context approaches and **90% lower token usage**."

**Solution**: Implement tiered memory architecture:

```
┌─────────────────────────────────────────┐
│ Working Memory (Context Window)          │ ← Current conversation
├─────────────────────────────────────────┤
│ Session Memory (Redis/SQLite)            │ ← Recent history, summaries
├─────────────────────────────────────────┤
│ Episodic Memory (Vector DB)              │ ← Semantic search of past work
├─────────────────────────────────────────┤
│ Semantic Memory (Artifact Index)         │ ← Facts, patterns, decisions
└─────────────────────────────────────────┘
```

**Legendary Team already has**:
- ✅ Artifact Index (SQLite + FTS5)
- ✅ Ledgers and Handoffs
- ❌ Missing: Vector embeddings for semantic retrieval
- ❌ Missing: Automatic summarization on context threshold

---

### Priority 8: Compaction Strategy

**Problem**: Auto-compact at 95% loses important context.

> "Use `/compact` when reaching **70% context capacity**—don't wait for auto-compact at 95%."

**Solution**: Add proactive compaction hook:

```javascript
// In hooks/config.json
{
  "contextManagement": {
    "compactThreshold": 0.70,
    "preserveOnCompact": [
      "current_task",
      "active_plan",
      "pending_approvals",
      "error_context"
    ],
    "summarizeOnCompact": [
      "completed_tasks",
      "tool_outputs",
      "conversation_history"
    ]
  }
}
```

---

## Implementation Roadmap

### Phase 1: Quick Wins (1-2 hours)
- [ ] Optimize CLAUDE.md to <150 tokens
- [ ] Add compaction threshold to hooks
- [ ] Restructure agent prompts for caching

### Phase 2: Architecture Changes (4-6 hours)
- [ ] Implement agent context isolation
- [ ] Add dynamic agent loading
- [ ] Create compressed output formats

### Phase 3: Advanced Features (1-2 days)
- [ ] Implement rolling history buffer
- [ ] Add automatic summarization
- [ ] Integrate vector memory for semantic search

---

## Expected Results

Based on community reports and research:

| Optimization | Expected Savings |
|-------------|------------------|
| CLAUDE.md optimization | 60-80% per-prompt overhead |
| Agent context isolation | 67% fewer tokens per subagent |
| Dynamic tool loading | 70-98% agent definition overhead |
| History limiting | 50-70% history tokens |
| Data compression | 40-70% tool response tokens |
| Prompt caching | 75% on repeated content |

**Combined potential**: **50-84% total token reduction**

---

## Key Quotes from Research

> "Most developers cut consumption by **50-70%** with `/clear` discipline and a good CLAUDE.md alone."
> — [ClaudeLog](https://claudelog.com/faqs/how-to-optimize-claude-code-token-usage/)

> "Context editing automatically clearing stale tool calls while preserving conversation flow... reducing token consumption by **84%**."
> — [Anthropic Engineering](https://www.anthropic.com/engineering/multi-agent-research-system)

> "Subagents process **67% fewer tokens** overall due to context isolation."
> — [Agno Blog](https://www.agno.com/blog/context-engineering-in-multi-agent-systems)

---

## Conclusion

The Legendary Team's parallel autonomous operation architecture is well-suited for token optimization. The key insight is that **multi-agent systems amplify context bloat** - but they also provide natural isolation boundaries that can be leveraged to **reduce total token consumption**.

The most impactful changes are:
1. **Agent context isolation** - Don't pass full history to subagents
2. **Dynamic agent loading** - Only load agent definitions when needed
3. **Compressed outputs** - Minimize tool response verbosity
4. **Proactive compaction** - Summarize before hitting limits

Implementing these strategies should reduce token consumption by **50-84%** while potentially improving response quality through better signal-to-noise ratio in context.

---

**Next Steps**: Review recommendations with team and prioritize implementation based on effort vs. impact.
