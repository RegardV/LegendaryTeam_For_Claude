# /refactor-clean - Dead Code & Unused Import Detection

Detect and remove dead code, unused imports, and unnecessary dependencies for cleaner, more maintainable codebase.

---

## Usage

```bash
# Scan for and remove all dead code
/refactor-clean

# Scan only (no changes)
/refactor-clean --dry-run

# Clean specific directory
/refactor-clean src/components

# Clean unused imports only
/refactor-clean --imports-only

# Clean unused dependencies
/refactor-clean --deps

# Aggressive mode (removes more aggressively)
/refactor-clean --aggressive
```

---

## What This Command Does

1. **Scans codebase** for unused code
2. **Identifies**:
   - Unused imports
   - Unused variables
   - Unused functions
   - Unused types/interfaces
   - Dead code paths
   - Unused dependencies
3. **Removes** safely (with verification)
4. **Verifies** build and tests still pass
5. **Reports** what was removed and why

---

## Command Flow

```markdown
Step 1: Analyze codebase
  → Scan all source files
  → Identify unused code
  → Categorize by type

Step 2: Plan removals
  → Prioritize safe removals
  → Flag risky removals
  → Create backup plan

Step 3: Execute removals
  → Remove unused imports
  → Remove unused code
  → Update references

Step 4: Verify
  → Run build
  → Run tests
  → Confirm no breakage

Step 5: Report
  → List removed code
  → Calculate savings (LOC, bundle size)
  → Provide statistics
```

---

## Invokes Agent

**@RefactorAgent** will handle this command with the following context:

```markdown
Task: Identify and remove dead code
Mode: ${mode} (default: safe, aggressive, dry-run)

Requirements:
1. Scan codebase for unused code
2. Categorize unused code by type
3. Remove unused code safely
4. Verify build and tests pass after each removal
5. Report removals and impact
6. Rollback if any issues detected

Safety:
- Remove only truly unused code
- Preserve public APIs
- Keep code referenced in tests
- Verify build and tests after changes

Output:
- List of removed code
- Lines of code reduced
- Bundle size impact
- Build/test verification status
```

---

## What Gets Detected & Removed

### 1. Unused Imports

**Before**:
```typescript
import React, { useState, useEffect } from 'react';
import { formatDate } from './utils';
import { API_URL } from './config';
import _ from 'lodash'; // Not used anywhere

export function UserCard({ user }) {
  return <div>{user.name}</div>;
}
```

**After**:
```typescript
import React from 'react';

export function UserCard({ user }) {
  return <div>{user.name}</div>;
}
```

**Removed**:
- `useState`, `useEffect` (not used)
- `formatDate` function (not used)
- `API_URL` constant (not used)
- `lodash` library (not used)

---

### 2. Unused Variables

**Before**:
```typescript
function calculateTotal(items: Item[]): number {
  const taxRate = 0.1; // Defined but never used
  const discount = 0.05; // Defined but never used

  return items.reduce((sum, item) => sum + item.price, 0);
}
```

**After**:
```typescript
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

---

### 3. Unused Functions

**Before**:
```typescript
// This function is never called anywhere
function oldCalculateTotal(items: Item[]): number {
  // Old implementation
  return items.length * 100;
}

// This function is actually used
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

**After**:
```typescript
// Old unused function removed

function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

---

### 4. Unused Types/Interfaces

**Before**:
```typescript
// Not used anywhere
interface OldUserShape {
  id: number;
  name: string;
}

// Actually used
interface User {
  id: string;
  name: string;
  email: string;
}

function getUser(id: string): User {
  // ...
}
```

**After**:
```typescript
interface User {
  id: string;
  name: string;
  email: string;
}

function getUser(id: string): User {
  // ...
}
```

---

### 5. Dead Code Paths

**Before**:
```typescript
function processUser(user: User) {
  if (user.isActive) {
    return processActiveUser(user);
  } else if (false) { // This will never execute
    return processInactiveUser(user);
  }

  return null;
}
```

**After**:
```typescript
function processUser(user: User) {
  if (user.isActive) {
    return processActiveUser(user);
  }

  return null;
}
```

---

### 6. Commented-Out Code

**Before**:
```typescript
function calculateTotal(items: Item[]): number {
  // Old implementation
  // return items.length * 100;

  // Another old approach
  // let total = 0;
  // for (const item of items) {
  //   total += item.price;
  // }
  // return total;

  // Current implementation
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

**After**:
```typescript
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

---

### 7. Unused npm Dependencies

**Before** (package.json):
```json
{
  "dependencies": {
    "react": "^18.0.0",
    "lodash": "^4.17.21",  // Not imported anywhere
    "moment": "^2.29.0",   // Not imported anywhere
    "axios": "^1.0.0"
  }
}
```

**After** (package.json):
```json
{
  "dependencies": {
    "react": "^18.0.0",
    "axios": "^1.0.0"
  }
}
```

**Savings**: Removed 2 unused dependencies

---

## Safety Mechanisms

### 1. Dry Run Mode (Default for Large Changes)

```bash
/refactor-clean --dry-run
```

**Output**:
```markdown
## Dead Code Analysis (DRY RUN)

### Unused Imports: 23
- src/auth.ts: lodash, moment
- src/user.ts: React.useEffect, React.useCallback
- src/api.ts: axios (use fetch instead)

### Unused Functions: 7
- src/utils.ts: oldFormatDate (replaced by formatDate)
- src/helpers.ts: deprecatedHelper
- src/legacy.ts: entire file unused

### Unused Variables: 15
- Across multiple files

### Total Removable:
- Lines of Code: 450
- Files: 3 entire files
- Bundle Size Reduction: ~15KB

**Would you like to proceed with these changes?** (y/n)
```

---

### 2. Incremental Verification

```markdown
Remove unused imports → Build → Test → ✅
Remove unused functions → Build → Test → ✅
Remove unused variables → Build → Test → ✅
Remove unused types → Build → Test → ✅

All changes verified safe ✅
```

---

### 3. Preserve Public APIs

```typescript
// This export is kept even if not used internally
// (it's part of the public API)
export function publicUtility() {
  // Implementation
}

// This is removed (internal and unused)
function internalHelper() {
  // Implementation
}
```

---

## Report Example

```markdown
## Refactor Clean Report ✅

**Date**: 2026-01-22
**Duration**: 45 seconds
**Mode**: Safe (default)

---

### Changes Summary

**Unused Imports Removed**: 23
**Unused Functions Removed**: 7
**Unused Variables Removed**: 15
**Unused Types Removed**: 5
**Commented Code Removed**: 180 lines
**Unused Dependencies Removed**: 2

---

### Impact

**Lines of Code**: 2,450 → 2,000 (450 lines removed, -18%)
**Bundle Size**: 245 KB → 230 KB (15 KB saved, -6%)
**npm Dependencies**: 24 → 22 (2 removed)

---

### Detailed Changes

#### 1. Unused Imports
```
src/auth.ts
  - Removed: lodash (not used)
  - Removed: moment (not used)
  - Removed: React.useEffect (not used)

src/user.ts
  - Removed: axios (switched to fetch)
  - Removed: _ from lodash (not used)
```

#### 2. Unused Functions
```
src/utils.ts
  - Removed: oldFormatDate() (replaced by formatDate)
  - Removed: deprecatedCalculate() (no longer used)

src/helpers.ts
  - Removed: legacyHelper() (replaced by new implementation)
```

#### 3. Unused Files
```
src/legacy.ts - Entire file removed (no imports found)
src/old-api.ts - Entire file removed (deprecated)
src/temp.ts - Entire file removed (temporary code)
```

#### 4. Unused Dependencies
```
package.json
  - Removed: lodash (not imported anywhere)
  - Removed: moment (not imported anywhere)

Savings: ~450KB node_modules size
```

---

### Verification

✅ **Build**: Success (no errors)
✅ **Tests**: All 450 tests passing
✅ **Linting**: No new warnings
✅ **Type Check**: No errors

---

### Recommendations

1. **Consider removing more**:
   - src/deprecated/ directory (contains old code)
   - Old test snapshots (15 unused)

2. **Update documentation**:
   - Remove references to deleted functions
   - Update API documentation

3. **Monitor**:
   - No increase in error rates detected
   - Performance unchanged
   - Bundle size reduced

---

### Git Commit

Created commit:
```
chore: remove dead code and unused imports

- Removed 450 lines of unused code
- Removed 2 unused dependencies (lodash, moment)
- Reduced bundle size by 15KB
- All tests passing ✅
```

**Branch**: feature/refactor-clean
**Ready for**: Review and merge
```

---

## Advanced Options

### Aggressive Mode

```bash
/refactor-clean --aggressive
```

More aggressive removal:
- Removes code with low test coverage
- Removes deprecated functions (even if still called)
- Suggests replacements for deprecated code
- Removes old commented code everywhere

**Use with caution**: Review changes carefully before committing.

---

### Import Analysis

```bash
/refactor-clean --imports-only
```

Focus only on unused imports:
- Faster execution
- Safe to run frequently
- Good for quick cleanups

---

### Dependency Audit

```bash
/refactor-clean --deps
```

Focus on unused npm packages:
- Scans package.json
- Checks for unused dependencies
- Suggests removal
- Estimates size savings

---

## Integration with Workflow

### Pre-Commit Hook

```bash
# .husky/pre-commit
npm run lint
npm run refactor-clean --dry-run --imports-only
```

### CI/CD Pipeline

```yaml
# .github/workflows/code-quality.yml
- name: Check for dead code
  run: npm run refactor-clean --dry-run
- name: Fail if too much dead code found
  run: |
    if [ $(npm run refactor-clean --dry-run | grep "Lines:" | awk '{print $3}') -gt 100 ]; then
      echo "Too much dead code detected (> 100 lines)"
      exit 1
    fi
```

---

## When to Use This Command

**Use /refactor-clean when**:
- ✅ After major refactoring
- ✅ Before release
- ✅ Quarterly code cleanup
- ✅ After removing features
- ✅ When bundle size is too large

**Run regularly**:
- Weekly: `--imports-only`
- Monthly: Full scan
- Before releases: `--dry-run` first, then full clean

---

## Safety Guidelines

**Will NOT remove**:
- Exported functions (public API)
- Code with tests
- Code referenced in config
- Dynamic imports (require/import())
- Code in node_modules

**Will flag for review**:
- Functions with low usage
- Large unused blocks
- Dependencies with high risk

---

## Related Commands

- `/test-run` - Run after cleanup to verify
- `/build-fix` - Fix any build errors from cleanup
- `/security-scan` - Security audit after dependency removal

---

**Remember**: Dead code is technical debt. Clean regularly to maintain a healthy codebase.
