# Handoff - [Feature/Task Name]

**Date**: [YYYY-MM-DD]
**Session Duration**: [X hours Y minutes]
**Outcome**: 🎯 SUCCEEDED | ⏳ PARTIAL | ❌ FAILED
**Completion**: [X%]
**Session ID**: [session-id]
**Agent**: @[agent-name]

---

## 📋 Executive Summary

[2-3 sentence summary of what was accomplished, what remains, and any critical issues]

**Status at a Glance**:
- ✅ [Major accomplishment 1]
- ✅ [Major accomplishment 2]
- ⏳ [Work in progress]
- 🚫 [Blocked or incomplete]

---

## 🎯 Original Goal

[Restate the original goal from the session start or planning phase]

**Success Criteria**:
- [x] [Criterion 1] - ✅ Met
- [x] [Criterion 2] - ✅ Met
- [ ] [Criterion 3] - ⏳ Partial
- [ ] [Criterion 4] - ❌ Not met

---

## 📝 Changes Made

### 1. [Component/Feature Name]

**Files Modified**:
- `path/to/file1.ext` (NEW)
  - Lines 1-50: [Description of what was added]
  - Purpose: [Why these changes were needed]
  - Dependencies: [What this depends on]

- `path/to/file2.ext` (MODIFIED)
  - Lines 34-45: [What was changed]
  - Lines 67-89: [What was added]
  - Reason: [Why these changes were necessary]

- `path/to/file3.ext` (DELETED)
  - Reason: [Why this file was removed]

**What It Does**:
[Detailed explanation of the functionality added or modified]

**How to Use It**:
```typescript
// Example code showing how to use the new feature
import { newFeature } from './path/to/file1'

const result = newFeature({ option: 'value' })
```

**Tests Added**:
- `tests/file1.test.ts:10-45` - Tests basic functionality
- `tests/file1.test.ts:47-82` - Tests edge cases

---

### 2. [Another Component/Feature]

**Files Modified**:
- `path/to/another.ext` (MODIFIED)
  - Lines 100-150: [Description]

**What It Does**:
[Explanation]

**Integration Points**:
- Integrates with [Component X] via [method]
- Called by [Component Y] in [scenario]
- Depends on [Component Z] for [reason]

---

## ✅ What Worked Well

### Success 1: [What went smoothly]
**Description**: [Detailed explanation of what worked]
**Why**: [Root cause of success]
**Takeaway**: [What to replicate in future]

### Success 2: [Another success]
**Description**: [What worked]
**Why**: [Why it worked]
**Takeaway**: [Learning for future]

---

## ❌ What Didn't Work

### Issue 1: [Problem encountered]
**Problem**: [Detailed description of the issue]
**Root Cause**: [Why it didn't work]
**Attempts Made**:
1. [Attempt 1] - Failed because [reason]
2. [Attempt 2] - Failed because [reason]
3. [Attempt 3] - Gave up due to [reason]

**Recommended Approach**: [How this should be solved in the future]

### Issue 2: [Another problem]
**Problem**: [Description]
**Root Cause**: [Why]
**Solution Attempted**: [What was tried]
**Current Status**: [Where it stands]

---

## 🧠 Key Decisions

### Decision 1: [Decision Title]
**Context**: [What situation required this decision]
**Options**:
1. **[Option A]**: [Description] - ❌ Not chosen because [reason]
2. **[Option B]**: [Description] - ✅ Chosen because [reason]
3. **[Option C]**: [Description] - ❌ Not chosen because [reason]

**Impact**: [How this decision affects the codebase/architecture]
**Reversibility**: Easy/Medium/Hard to change later

### Decision 2: [Another Decision]
**What**: [What was decided]
**Why**: [Rationale]
**Trade-offs**: [What was sacrificed for what benefits]

---

## 🚧 Known Issues

### Critical Issues 🔴
1. **[Issue Title]**
   - File: `path/to/file.ext:line-number`
   - Impact: [How severe - breaks functionality/causes errors/etc]
   - Workaround: [Temporary solution if any]
   - Next Steps: [How to fix permanently]

### Non-Critical Issues 🟡
1. **[Issue Title]**
   - File: `path/to/file.ext:line-number`
   - Impact: [Minor annoyance/technical debt/optimization]
   - Priority: Low/Medium
   - Notes: [Additional context]

---

## 📋 Next Steps

### Immediate (Do First)
1. **[Task 1]** - Priority: High
   - File: `path/to/file.ext`
   - Description: [What needs to be done]
   - Estimated Time: [X hours]
   - Blockers: [None/What's blocking]

2. **[Task 2]** - Priority: High
   - File: `path/to/file.ext`
   - Description: [What needs to be done]
   - Estimated Time: [X hours]

### Soon (This Week)
3. **[Task 3]** - Priority: Medium
   - Description: [What needs to be done]
   - Why: [Why this is important]

4. **[Task 4]** - Priority: Medium
   - Description: [What needs to be done]

### Eventually (Nice to Have)
5. **[Task 5]** - Priority: Low
   - Description: [What could be improved]
   - Benefit: [What would be gained]

---

## 🧪 Testing Status

### Tests Written
- ✅ Unit tests: [X/Y passing]
- ✅ Integration tests: [X/Y passing]
- ⏳ E2E tests: [Not yet written]

### Test Coverage
- Overall: [X%]
- Critical paths: [X%]
- Edge cases: [X%]

### Tests Needed
- [ ] Test for [scenario]
- [ ] Test for [edge case]
- [ ] Test for [integration]

---

## 🏗️ Architecture Notes

### Design Patterns Used
- **Pattern 1**: [Name] - Used in [where] for [reason]
- **Pattern 2**: [Name] - Used in [where] for [reason]

### Architectural Decisions
1. **[Decision]**: [Description and rationale]
2. **[Decision]**: [Description and rationale]

### Tech Stack Changes
- Added: [Library/Tool] - [Why]
- Removed: [Library/Tool] - [Why]
- Updated: [Library/Tool] - [Version] → [Version] - [Why]

---

## 🔗 Dependencies

### New Dependencies
```json
{
  "dependency-name": "^version",
  "another-dep": "^version"
}
```

**Rationale**: [Why these were added]

### Modified Dependencies
- Updated [dep] from [old] to [new] - [Reason]

### Breaking Changes
- ⚠️ [What changed that might break things]
- ⚠️ [Migration steps if needed]

---

## 💡 Context for Future Work

### Important Background
[Information that someone continuing this work needs to know. Explain the "why" behind non-obvious decisions, architectural constraints, or gotchas in the codebase]

### Gotchas to Watch Out For
1. **[Gotcha 1]**: [What to watch out for and why]
2. **[Gotcha 2]**: [Potential pitfall]

### Helpful Resources
- [Link to documentation]
- [Link to related issue/PR]
- [Link to Stack Overflow discussion]

---

## 🎓 Learnings

### Technical Learnings
1. **[Learning 1]**: [What you learned about the technology/framework]
2. **[Learning 2]**: [Something new about the codebase]
3. **[Learning 3]**: [Best practice discovered]

### Process Learnings
1. **[Learning 1]**: [What worked well in the workflow]
2. **[Learning 2]**: [What to do differently next time]

### Do Next Time ✅
- [Thing that worked well - repeat it]
- [Approach that was efficient]

### Avoid Next Time ❌
- [Thing that wasted time]
- [Approach that didn't work]

---

## 📊 Session Metrics

**Time Breakdown**:
- Planning: [X minutes]
- Implementation: [X hours Y minutes]
- Testing: [X minutes]
- Debugging: [X minutes]
- Documentation: [X minutes]

**Code Changes**:
- Files Created: [Number]
- Files Modified: [Number]
- Files Deleted: [Number]
- Lines Added: [Number]
- Lines Removed: [Number]
- Net Change: [+/- Number]

**Quality Metrics**:
- Tests Passing: [Number/Total]
- Linter Warnings: [Number]
- Type Errors: [Number]
- Code Coverage: [X%]

**Cost**:
- Tokens Used: [Input/Output]
- Estimated Cost: $[Amount]

---

## 🔍 Search Keywords

[Add keywords that future sessions might search for to find this handoff]

`authentication, jwt, tokens, login, security, middleware, user-auth, session-management`

---

## 📎 Attachments

### Screenshots
- [Link to screenshot 1] - [Description]
- [Link to screenshot 2] - [Description]

### Related Handoffs
- `handoff-YYYYMMDD-related-feature.md` - [How it relates]

### Related Plans
- `plan-feature-name.md` - [How it relates]

---

## 🤝 Handoff Checklist

Before marking this handoff complete, verify:

- [x] All file changes documented with line numbers
- [x] Key decisions explained with rationale
- [x] Known issues clearly identified
- [x] Next steps prioritized
- [x] Tests status documented
- [x] Context provided for future work
- [x] Search keywords added
- [x] Code changes committed to git
- [x] Outcome status updated (SUCCEEDED/PARTIAL/FAILED)

---

## 📞 Contact

**If you have questions about this work:**
- Check related plan: `thoughts/shared/plans/plan-[feature].md`
- Search artifacts: `/skill query-artifacts "[keywords]"`
- Review commit history: `git log --oneline -- [files]`

---

**Handoff Created**: [YYYY-MM-DD HH:MM:SS]
**Last Updated**: [YYYY-MM-DD HH:MM:SS]
**Handoff Version**: v2026-continuity
**Indexed**: [Yes/No] (Auto-indexed by PostToolUse hook)
