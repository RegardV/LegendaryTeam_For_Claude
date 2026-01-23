# 🔄 Iteration Rules

## Purpose
Rules for autonomous iteration mode, inspired by the Ralph-loop pattern for self-improving agent behavior.

---

## When to Use Iteration Mode

### 1. **Iterative Problems Only**
```markdown
# ✅ GOOD - Use iteration for:
- Performance optimization (target: < 100ms)
- Test coverage improvement (target: ≥ 80%)
- Bug fixing with unclear root cause
- Code quality improvements (target: linter score > 90)
- Security vulnerability remediation

# ❌ BAD - Don't use iteration for:
- Simple deterministic tasks ("add a button")
- One-time operations ("create a file")
- Tasks with no measurable outcome
```

**Rule**: Only use iteration mode for tasks with measurable goals that may require multiple attempts.

---

## Iteration Setup

### 2. **Define Measurable Goals**
```markdown
# ✅ REQUIRED - Clear success criteria
Goal: Reduce API response time
Baseline: 450ms
Target: < 100ms
Measurement: Average response time over 100 requests
Max iterations: 5

# ❌ FORBIDDEN - Vague goals
Goal: Make it faster
Target: Better performance
```

**Rule**: Every iteration MUST have a specific, measurable success criterion.

---

### 3. **Set Iteration Limits**
```markdown
# ✅ REQUIRED - Define limits
Max iterations: 5
Timeout per iteration: 5 minutes
Total timeout: 30 minutes

# If limits reached without success:
- Report best effort
- Suggest alternative approach
- Escalate to human if critical
```

**Rule**: Set maximum iterations (typically 3-5) and time limits to prevent infinite loops.

---

## Iteration Workflow

### 4. **Measure Baseline**
```typescript
// ✅ REQUIRED - Start with measurement
async function iteratePerformance(fn: Function) {
  // Step 1: Measure baseline
  const baseline = await measurePerformance(fn);
  console.log(`Baseline: ${baseline}ms`);

  // Step 2: Check if already meeting target
  if (baseline < TARGET) {
    return { success: true, iterations: 0, baseline };
  }

  // Step 3: Begin iterations
  // ...
}
```

**Rule**: Always measure baseline BEFORE starting iterations.

---

### 5. **Iteration Loop Structure**
```typescript
// ✅ REQUIRED iteration pattern
interface IterationResult {
  success: boolean;
  iterations: number;
  baseline: number;
  final: number;
  improvements: string[];
}

async function iterate(
  goal: string,
  target: number,
  maxIterations: number
): Promise<IterationResult> {
  const baseline = await measure();
  let current = baseline;
  const improvements: string[] = [];

  for (let i = 1; i <= maxIterations; i++) {
    console.log(`\nIteration ${i}/${maxIterations}`);
    console.log(`Current: ${current}, Target: ${target}`);

    // Check if target achieved
    if (current <= target) {
      return {
        success: true,
        iterations: i - 1,
        baseline,
        final: current,
        improvements
      };
    }

    // Make improvement
    const improvement = await makeImprovement();
    improvements.push(improvement.description);

    // Measure result
    const newValue = await measure();

    // Check for improvement
    if (newValue >= current) {
      console.log(`No improvement. Reverting change.`);
      await revertChange();
      continue;
    }

    current = newValue;
    console.log(`Improved: ${current} (${((baseline - current) / baseline * 100).toFixed(1)}% better)`);
  }

  // Max iterations reached
  return {
    success: false,
    iterations: maxIterations,
    baseline,
    final: current,
    improvements
  };
}
```

**Rule**: Follow structured iteration loop with measurement, improvement, and validation.

---

### 6. **Incremental Improvements**
```markdown
# ✅ GOOD - One change per iteration
Iteration 1: Add database index on user_id
Result: 450ms → 250ms ✓

Iteration 2: Implement Redis caching
Result: 250ms → 120ms ✓

Iteration 3: Optimize query (remove unnecessary JOIN)
Result: 120ms → 80ms ✓
Target achieved (< 100ms)

# ❌ BAD - Multiple changes at once
Iteration 1: Add index, caching, optimize query, rewrite entire module
Result: 450ms → ??? (can't tell what worked)
```

**Rule**: Make ONE change per iteration so you know what worked.

---

### 7. **Validate Each Change**
```typescript
// ✅ REQUIRED - Validate improvements
async function makeAndValidateImprovement(): Promise<boolean> {
  const before = await measure();

  // Make change
  await makeChange();

  // Validate
  const after = await measure();

  // If worse, revert
  if (after >= before) {
    await revertChange();
    return false;
  }

  return true;
}
```

**Rule**: Validate that each change actually improves the metric. Revert if it doesn't.

---

## Stopping Criteria

### 8. **Stop When Target Achieved**
```markdown
# ✅ GOOD - Clear success
Iteration 3: Response time 80ms
Target: < 100ms
✓ Target achieved. Stopping iteration.

# ❌ BAD - Continuing past target
Iteration 3: Response time 80ms (target achieved)
Iteration 4: Trying to get to 70ms...
Iteration 5: Trying to get to 60ms...
(Wasting time on unnecessary optimization)
```

**Rule**: STOP iterating as soon as target is achieved.

---

### 9. **Stop on Diminishing Returns**
```markdown
# ✅ GOOD - Recognizing diminishing returns
Iteration 1: 450ms → 250ms (44% improvement) ✓
Iteration 2: 250ms → 120ms (52% improvement) ✓
Iteration 3: 120ms → 105ms (12.5% improvement) ⚠️
Iteration 4: 105ms → 102ms (2.8% improvement) ⚠️

Diminishing returns detected. Further optimization requires
architectural changes. Current result (102ms) is acceptable.
Recommendation: Stop or escalate to @ArchitectureAgent.
```

**Rule**: Stop when improvements become negligible (< 5% per iteration).

---

### 10. **Stop on Max Iterations**
```markdown
# ✅ GOOD - Graceful handling of max iterations
Iteration 5/5: 150ms → 145ms
Target: < 100ms (not achieved)
Max iterations reached.

Best effort: Improved from 450ms to 145ms (68% improvement)
Remaining gap: 45ms

Recommendations:
1. Accept current performance (145ms may be acceptable)
2. Investigate architectural changes (move to async processing)
3. Consider caching at application level
4. Profile to identify remaining bottlenecks
```

**Rule**: If max iterations reached, report best effort and suggest next steps.

---

## Reporting

### 11. **Structured Progress Reports**
```markdown
# ✅ REQUIRED - Clear iteration reporting

## Performance Optimization Report

**Goal**: Reduce API response time to < 100ms
**Baseline**: 450ms
**Target**: < 100ms
**Max Iterations**: 5

### Iteration 1: Database Indexing
- Change: Added index on `users.email`
- Result: 450ms → 250ms
- Improvement: 44% faster
- Status: ✓ Significant improvement

### Iteration 2: Redis Caching
- Change: Implemented Redis cache for user lookups
- Result: 250ms → 120ms
- Improvement: 52% faster
- Status: ✓ Significant improvement

### Iteration 3: Query Optimization
- Change: Removed unnecessary JOIN, used single query
- Result: 120ms → 80ms
- Improvement: 33% faster
- Status: ✓ Target achieved

## Final Results
- **Final**: 80ms
- **Total Improvement**: 82% faster (450ms → 80ms)
- **Iterations Used**: 3/5
- **Status**: ✅ Success - Target achieved
```

**Rule**: Provide detailed report showing each iteration's changes and results.

---

### 12. **Report Failures Clearly**
```markdown
# ✅ GOOD - Honest failure reporting

## Test Coverage Improvement - Failed

**Goal**: Increase coverage to ≥ 80%
**Baseline**: 45%
**Target**: ≥ 80%
**Max Iterations**: 5

### Iterations
1. Added unit tests for user service: 45% → 52%
2. Added integration tests for API: 52% → 61%
3. Added tests for utils: 61% → 68%
4. Added tests for middleware: 68% → 74%
5. Added tests for controllers: 74% → 77%

## Result
- **Final**: 77%
- **Target**: 80%
- **Status**: ❌ Target not achieved (3% short)

## Analysis
- Significant progress made (32% increase)
- Remaining uncovered code:
  - Error handling paths (difficult to trigger)
  - Edge cases in payment processing
  - Legacy code without clear test strategy

## Recommendations
1. Accept 77% as sufficient (close to target)
2. Manual review of uncovered code (may not need tests)
3. Additional 2 iterations may reach 80%
4. Refactor legacy code to be more testable
```

**Rule**: Be honest about failures. Provide analysis and recommendations.

---

## Optimization Strategies

### 13. **Prioritize High-Impact Changes**
```markdown
# ✅ GOOD - Start with high-impact changes
Iteration 1: Add database index (expected: 40% improvement)
Iteration 2: Implement caching (expected: 30% improvement)
Iteration 3: Optimize algorithm (expected: 10% improvement)

# ❌ BAD - Start with low-impact changes
Iteration 1: Rename variable (expected: 0% improvement)
Iteration 2: Adjust whitespace (expected: 0% improvement)
Iteration 3: Actually fix the problem...
```

**Rule**: Start with changes likely to have the biggest impact.

---

### 14. **Use Profiling to Guide Iterations**
```typescript
// ✅ GOOD - Data-driven iteration
async function optimizeWithProfiling() {
  // Profile to find bottleneck
  const profile = await profileFunction();

  // Bottleneck: Database query (80% of time)
  // Iteration 1: Optimize database query

  // Re-profile
  const profile2 = await profileFunction();

  // New bottleneck: JSON serialization (60% of time)
  // Iteration 2: Optimize serialization

  // Continue until target achieved
}
```

**Rule**: Use profiling data to identify bottlenecks and guide iterations.

---

## Safety Rules

### 15. **Don't Break Functionality**
```typescript
// ✅ REQUIRED - Verify correctness after each change
async function safeIteration() {
  const before = await measure();

  // Make change
  await makeOptimization();

  // Run tests to ensure functionality preserved
  const testsPass = await runTests();

  if (!testsPass) {
    console.log('Tests failed. Reverting optimization.');
    await revertChange();
    return false;
  }

  const after = await measure();
  return after < before;
}
```

**Rule**: Run tests after EVERY iteration to ensure functionality is preserved.

---

### 16. **Keep Changes Atomic**
```markdown
# ✅ GOOD - Atomic, revertible changes
Iteration 1: Add index (easy to revert)
Iteration 2: Add caching (easy to disable)

# ❌ BAD - Non-atomic changes
Iteration 1: Rewrite entire module (can't easily revert)
```

**Rule**: Make changes that can be easily reverted if they don't improve metrics.

---

### 17. **No Infinite Loops**
```typescript
// ✅ REQUIRED - Hard limit on iterations
const MAX_ITERATIONS = 10; // Safety limit
const MAX_TIME_MS = 30 * 60 * 1000; // 30 minutes

async function iterateWithSafety() {
  const startTime = Date.now();

  for (let i = 0; i < MAX_ITERATIONS; i++) {
    if (Date.now() - startTime > MAX_TIME_MS) {
      throw new Error('Iteration timeout exceeded');
    }

    // Iteration logic
  }
}
```

**Rule**: ALWAYS have hard limits on iterations and total time to prevent infinite loops.

---

## Iteration Checklist

Before starting iteration:
- [ ] Measurable goal defined
- [ ] Baseline measured
- [ ] Target set
- [ ] Max iterations defined (3-5)
- [ ] Timeout set
- [ ] Success criteria clear

During iteration:
- [ ] One change per iteration
- [ ] Validate each change
- [ ] Run tests after change
- [ ] Revert if no improvement
- [ ] Document each iteration

After iteration:
- [ ] Report final results
- [ ] Compare to baseline
- [ ] Document what worked
- [ ] Provide recommendations if failed

---

**REMEMBER**: Iteration mode is powerful but must be used responsibly with clear goals and limits.

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
