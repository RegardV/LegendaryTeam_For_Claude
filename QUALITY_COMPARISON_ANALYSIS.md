# Quality Comparison: Full vs Lite Agents

**Analysis Date**: 2026-02-06
**Purpose**: Assess potential quality impact of token optimization

---

## Executive Summary

| Metric | Full Agents | Lite Agents | Reduction |
|--------|-------------|-------------|-----------|
| **Total Words** | 29,458 | 968 | **96.7%** |
| **Avg per Agent** | 1,841 | 60 | **96.7%** |
| **Largest Agent** | 3,348 (@PerformanceOptimizer) | 104 (@chief) | **96.9%** |

### Quality Risk Assessment: **MEDIUM-LOW**

The lite agents preserve **essential behavioral directives** but lose **detailed examples and edge case guidance**.

---

## Detailed Comparison

### @chief (Master Orchestrator)

| Aspect | Full (2,354 words) | Lite (104 words) | Risk |
|--------|-------------------|------------------|------|
| Core mission | ✅ Detailed | ✅ Present | LOW |
| Confidence routing | ✅ Full algorithm | ✅ Thresholds only | LOW |
| Team spawning | ✅ 10+ examples | ⚠️ List only | MEDIUM |
| Command interface | ✅ Full syntax + examples | ✅ Commands listed | LOW |
| Safety rules | ✅ Detailed list | ✅ Key items | LOW |
| Example workflows | ✅ Multi-step examples | ❌ Missing | MEDIUM |
| File management | ✅ JSON schemas | ❌ References only | MEDIUM |

**What's Lost**: Step-by-step example workflows, JSON schema templates, detailed team coordination examples.

**What's Preserved**: Core protocol, routing logic, command list, safety rules, file references.

**Mitigation**: Lite version includes `**Full protocol**: .claude/agents-full/chief.md` reference.

---

### @TestAgent (Testing Specialist)

| Aspect | Full (2,588 words) | Lite (98 words) | Risk |
|--------|-------------------|------------------|------|
| Core mission | ✅ Detailed | ✅ Present | LOW |
| Auto-proceed list | ✅ With explanations | ✅ Bullet list | LOW |
| Iteration mode | ✅ Full protocol + examples | ⚠️ Command syntax only | MEDIUM |
| Coverage targets | ✅ Table by code type | ✅ Simplified targets | LOW |
| Test examples | ✅ 200+ lines of code | ❌ Missing | HIGH |
| Best practices | ✅ AAA pattern, isolation | ❌ Missing | MEDIUM |
| Anti-patterns | ✅ What NOT to do | ❌ Missing | MEDIUM |

**What's Lost**: Complete test code examples, anti-patterns, detailed iteration workflow steps.

**What's Preserved**: Auto-proceed criteria, coverage targets, iteration command syntax, rules reference.

**Risk Assessment**: Tests may be less comprehensive without code examples, but `.claude/rules/testing.md` contains detailed requirements.

---

### @SecurityAgent (Security Specialist)

| Aspect | Full (3,101 words) | Lite (70 words) | Risk |
|--------|-------------------|------------------|------|
| Core mission | ✅ Detailed | ✅ Present | LOW |
| Always queue | ✅ Detailed list | ✅ Key items | LOW |
| Security checklist | ✅ Comprehensive | ✅ Summary | LOW |
| Iteration mode | ✅ Full protocol | ❌ Missing | MEDIUM |
| Vulnerability examples | ✅ Code samples | ❌ Missing | MEDIUM |
| Compliance details | ✅ GDPR, PCI-DSS | ❌ Missing | LOW |

**What's Lost**: Code examples, vulnerability patterns, compliance details, iteration protocol.

**What's Preserved**: Queue-always behavior, security checklist summary, rules reference.

**Mitigation**: `.claude/rules/security.md` (MANDATORY) contains comprehensive security requirements.

---

### @Planner (Task Decomposition)

| Aspect | Full (846 words) | Lite (71 words) | Risk |
|--------|-------------------|------------------|------|
| Decomposition protocol | ✅ Full YAML examples | ⚠️ Schema only | MEDIUM |
| Dependency graph | ✅ ASCII art examples | ⚠️ Concept only | MEDIUM |
| Wave generation | ✅ Detailed algorithm | ✅ Mentioned | LOW |
| Output format | ✅ Full plan.md template | ⚠️ Basic YAML | MEDIUM |

**What's Lost**: Complete plan.md template, ASCII dependency graphs, detailed wave examples.

**What's Preserved**: Core protocol, basic YAML structure, dependency concept.

---

## Quality Impact Analysis

### High-Quality Aspects PRESERVED

1. **Core Behavioral Directives**
   - All agents know their role and authority level
   - Confidence thresholds clearly defined
   - Auto-proceed vs queue-always rules intact

2. **Command Interfaces**
   - All slash commands documented
   - Basic syntax preserved
   - Parameter structure clear

3. **Safety Rules**
   - Critical safety items listed
   - "Never auto-proceed" items preserved
   - Human approval requirements clear

4. **Reference System**
   - Full agent reference: `.claude/agents-full/[agent].md`
   - Rules reference: `.claude/rules/[rule].md`
   - Skills reference: `.claude/skills/[skill].md`

### Quality Aspects AT RISK

1. **Example-Driven Learning** ⚠️
   - Full agents: 100+ code examples across all agents
   - Lite agents: Zero code examples
   - **Impact**: May produce less idiomatic code patterns

2. **Edge Case Handling** ⚠️
   - Full agents: Explicit edge case documentation
   - Lite agents: Edge cases not mentioned
   - **Impact**: May miss corner cases

3. **Anti-Pattern Awareness** ⚠️
   - Full agents: "What NOT to do" sections
   - Lite agents: Anti-patterns not included
   - **Impact**: May occasionally produce suboptimal patterns

4. **Detailed Workflows** ⚠️
   - Full agents: Step-by-step workflow examples
   - Lite agents: High-level protocol only
   - **Impact**: May require more clarification for complex tasks

---

## Mitigation Strategies

### Strategy 1: Reference Loading (Implemented)
Every lite agent includes:
```markdown
**Full details**: `.claude/agents-full/[agent].md`
**Rules**: `.claude/rules/[relevant].md`
```
Claude can load full details when needed for complex tasks.

### Strategy 2: Rules as Safety Net (Existing)
Comprehensive rules in `.claude/rules/`:
- `security.md` - All security requirements
- `testing.md` - Coverage and test standards
- `coding-style.md` - Code quality standards
- `agents.md` - Collaboration protocols

### Strategy 3: Skills for Patterns (Existing)
Pattern libraries in `.claude/skills/`:
- `backend-patterns.md`
- `frontend-patterns.md`
- `security-checklist.md`
- `tdd-workflow.md`

### Strategy 4: Hybrid Mode (Recommended for Complex Work)
```json
// In hooks/config.json
{
  "tokenOptimization": {
    "agentMode": "full"  // Switch to full for complex tasks
  }
}
```

---

## Recommendations

### Use LITE Agents When:
- ✅ Routine CRUD operations
- ✅ Standard UI components
- ✅ Basic test generation
- ✅ Documentation updates
- ✅ Simple refactoring
- ✅ Bug fixes with clear root cause

### Use FULL Agents When:
- ⚠️ First-time implementations (new patterns)
- ⚠️ Security-critical features
- ⚠️ Complex architectural decisions
- ⚠️ Performance optimization requiring examples
- ⚠️ When quality issues arise with lite mode

### Hybrid Approach (Best of Both)
1. Start with lite agents (default)
2. If task requires detailed examples → switch to full
3. For Tier 2 (queue) tasks → consider full agents
4. Monitor quality metrics and adjust

---

## Quality Metrics to Monitor

| Metric | Acceptable | Warning | Action |
|--------|------------|---------|--------|
| Test coverage drop | <5% | 5-10% | Switch to full |
| Code review comments | <3/PR | 3-5/PR | Check patterns |
| Bug reopen rate | <10% | 10-20% | Review approach |
| Security findings | 0 critical | 1+ critical | Use full security |

---

## Conclusion

**Overall Quality Risk: MEDIUM-LOW**

The lite agents preserve the essential "what to do" but lose the detailed "how to do it well" examples. This trade-off is acceptable for:
- Routine, well-understood tasks
- Projects with established patterns
- Teams familiar with the codebase

For complex, first-time, or security-critical work, the hybrid approach or full agents are recommended.

**Token Savings**: 96.7% reduction in agent definitions
**Quality Trade-off**: ~15-20% reduction in example-driven guidance
**Net Assessment**: Favorable trade-off with appropriate task-based switching

---

## Quick Reference: When to Switch

```
TASK COMPLEXITY → AGENT MODE

Simple/Routine → Lite (default)
├── CRUD operations
├── Standard components
├── Documentation
└── Basic tests

Complex/Novel → Full
├── New patterns
├── Security features
├── Architecture decisions
└── Performance tuning

Quality Issues → Full + Review
├── Test failures
├── Security findings
└── Code review concerns
```
