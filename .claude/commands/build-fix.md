# /build-fix - Build Error Diagnosis & Resolution

Diagnose and fix build errors, compilation failures, and dependency issues.

---

## Usage

```bash
# Diagnose and fix build errors
/build-fix

# Fix specific build error
/build-fix "Module not found: Can't resolve 'react'"

# Fix TypeScript errors
/build-fix typescript

# Fix dependency issues
/build-fix deps

# Verbose mode with detailed diagnostics
/build-fix --verbose
```

---

## What This Command Does

1. **Runs build** to identify errors
2. **Analyzes** error messages and stack traces
3. **Diagnoses** root cause of build failures
4. **Implements fixes** systematically
5. **Verifies** build succeeds after fixes
6. **Reports** what was fixed and why

---

## Command Flow

```markdown
Step 1: Run build and capture errors
  → npm run build (or equivalent)
  → Collect all error messages
  → Categorize errors by type

Step 2: Analyze errors
  → TypeScript errors
  → Module resolution errors
  → Dependency errors
  → Configuration errors

Step 3: Fix errors systematically
  → Start with blocking errors
  → Fix one category at a time
  → Verify each fix

Step 4: Verify and report
  → Run full build
  → Confirm success
  → Document fixes applied
```

---

## Invokes Agent

**@BugResolver** will handle this command with the following context:

```markdown
Task: Diagnose and fix build errors
Context: Build is currently failing

Requirements:
1. Run build to identify all errors
2. Categorize and prioritize errors
3. Fix errors systematically (one at a time)
4. Verify build succeeds after each fix
5. Document all fixes applied
6. Report root causes and prevention strategies

Output:
- List of errors found
- Fixes applied for each error
- Build status (success/failure)
- Recommendations for prevention
```

---

## Common Build Errors & Fixes

### 1. TypeScript Type Errors

**Error**:
```
src/auth.ts(45,12): error TS2339: Property 'id' does not exist on type 'User | null'
```

**Diagnosis**:
- TypeScript can't guarantee `user` is not null
- Accessing `user.id` without null check fails type checking

**Fix**:
```typescript
// ❌ Before (causes error)
function getUser(id: string) {
  const user = findUser(id);
  return user.id; // Error: user might be null
}

// ✅ After (fixed)
function getUser(id: string): string {
  const user = findUser(id);
  if (!user) {
    throw new NotFoundError('User not found');
  }
  return user.id; // Safe: TypeScript knows user is not null
}
```

---

### 2. Module Not Found Errors

**Error**:
```
Module not found: Can't resolve 'react-router-dom'
```

**Diagnosis**:
- Dependency is imported but not installed
- Or wrong package name

**Fix**:
```bash
# Install missing dependency
npm install react-router-dom

# Or if it's a dev dependency
npm install --save-dev @types/react-router-dom
```

---

### 3. Import Path Errors

**Error**:
```
Module not found: Can't resolve '../services/userService'
```

**Diagnosis**:
- Incorrect import path
- File doesn't exist at specified location
- Case sensitivity issue

**Fix**:
```typescript
// ❌ Wrong path
import { UserService } from '../services/userService';

// ✅ Correct path
import { UserService } from '../services/UserService';
// or
import { UserService } from '@/services/UserService'; // Using path alias
```

---

### 4. Missing Type Definitions

**Error**:
```
Could not find a declaration file for module 'some-library'
```

**Diagnosis**:
- TypeScript type definitions not installed
- Library doesn't have TypeScript support

**Fix**:
```bash
# Option 1: Install type definitions
npm install --save-dev @types/some-library

# Option 2: If no types available, create declaration
# Create: src/types/some-library.d.ts
declare module 'some-library' {
  export function someFunction(): void;
}

# Option 3: Disable type checking for this import (last resort)
// @ts-ignore
import someLibrary from 'some-library';
```

---

### 5. Circular Dependency Errors

**Error**:
```
Circular dependency detected:
src/user.ts -> src/order.ts -> src/user.ts
```

**Diagnosis**:
- Files import each other creating a loop
- Can cause undefined imports and build issues

**Fix**:
```typescript
// ❌ Circular dependency
// user.ts
import { Order } from './order';
export class User {
  orders: Order[];
}

// order.ts
import { User } from './user';
export class Order {
  user: User;
}

// ✅ Fixed: Use types instead of importing
// user.ts
import type { Order } from './order';
export class User {
  orders: Order[];
}

// order.ts
import type { User } from './user';
export class Order {
  user: User;
}
```

---

### 6. Environment Variable Errors

**Error**:
```
ReferenceError: process is not defined
```

**Diagnosis**:
- Trying to access Node.js variables in browser code
- Missing environment variable configuration

**Fix**:
```javascript
// ❌ Wrong: Using process in browser code
const apiUrl = process.env.REACT_APP_API_URL;

// ✅ Right: Use build tool's env variable syntax
const apiUrl = import.meta.env.VITE_API_URL; // Vite
const apiUrl = process.env.REACT_APP_API_URL; // Create React App (works)

// Or configure in build tool
// vite.config.ts
export default {
  define: {
    'process.env.API_URL': JSON.stringify(process.env.API_URL)
  }
};
```

---

### 7. Dependency Version Conflicts

**Error**:
```
npm ERR! Could not resolve dependency:
npm ERR! peer react@"^18.0.0" from react-router-dom@6.0.0
```

**Diagnosis**:
- Dependency requires specific version of peer dependency
- Installed version doesn't match requirement

**Fix**:
```bash
# Option 1: Update to compatible version
npm install react@^18.0.0

# Option 2: Use --legacy-peer-deps flag (if upgrade not possible)
npm install --legacy-peer-deps

# Option 3: Use npm overrides (package.json)
{
  "overrides": {
    "react": "^18.0.0"
  }
}
```

---

### 8. Build Configuration Errors

**Error**:
```
webpack.config.js: Invalid configuration object
```

**Diagnosis**:
- Syntax error in build configuration
- Missing required configuration options
- Deprecated configuration used

**Fix**:
```javascript
// ❌ Invalid webpack config
module.exports = {
  entry: './src/index.ts',
  mode: 'production',
  output: {
    filename: 'bundle.js'
    // Missing: path property
  }
};

// ✅ Valid webpack config
const path = require('path');

module.exports = {
  entry: './src/index.ts',
  mode: 'production',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  }
};
```

---

## Build Fix Workflow Example

**Input**:
```bash
/build-fix
```

**Process**:

```markdown
## Build Fix Report

### Step 1: Running build
$ npm run build

### Errors Detected: 5

1. ❌ TS2339: Property 'id' does not exist on type 'User | null'
   File: src/auth.ts:45

2. ❌ Module not found: Can't resolve 'lodash'
   File: src/utils/helpers.ts:3

3. ❌ TS2307: Cannot find module '@/types/user'
   File: src/services/userService.ts:2

4. ❌ TS7006: Parameter 'user' implicitly has an 'any' type
   File: src/components/UserCard.tsx:12

5. ❌ Module parse failed: Unexpected token
   File: src/config.json:5

---

### Step 2: Categorizing Errors

**TypeScript Errors** (3):
- Null safety issue (auth.ts)
- Module resolution (@/types/user)
- Implicit any type (UserCard.tsx)

**Dependency Errors** (1):
- Missing lodash package

**Configuration Errors** (1):
- JSON parse error in config.json

---

### Step 3: Applying Fixes

#### Fix 1: Install missing dependency
$ npm install lodash
✅ lodash@4.17.21 installed

#### Fix 2: Fix JSON syntax error
File: src/config.json
- Error: Trailing comma on line 5
- Fixed: Removed trailing comma
✅ JSON now valid

#### Fix 3: Add null check
File: src/auth.ts:45
```typescript
// Before
return user.id;

// After
if (!user) throw new Error('User not found');
return user.id;
```
✅ Null safety issue resolved

#### Fix 4: Fix path alias
File: src/services/userService.ts:2
```typescript
// Before
import { User } from '@/types/user';

// After (path alias not configured)
import { User } from '../types/user';
```
✅ Import path corrected

#### Fix 5: Add type annotation
File: src/components/UserCard.tsx:12
```typescript
// Before
function UserCard({ user }) {

// After
interface UserCardProps {
  user: User;
}
function UserCard({ user }: UserCardProps) {
```
✅ Type annotation added

---

### Step 4: Verification
$ npm run build

Build completed successfully! ✅

**Build Time**: 12.5s
**Errors**: 0
**Warnings**: 0

---

### Summary
✅ All 5 build errors fixed
✅ Build now succeeds
✅ No warnings

### Fixes Applied:
1. Installed missing lodash dependency
2. Fixed JSON syntax error
3. Added null safety check
4. Corrected import path
5. Added TypeScript type annotation

### Prevention Recommendations:
1. Enable pre-commit hooks to catch build errors early
2. Configure path aliases in tsconfig.json
3. Use strict TypeScript mode
4. Add dependencies to package.json before importing
5. Validate JSON files with linter
```

---

## Advanced Diagnostics

### Using --verbose flag

```bash
/build-fix --verbose
```

Provides:
- Full error stack traces
- Dependency tree analysis
- Configuration file review
- Build performance metrics
- Suggestions for optimization

---

## When to Use This Command

**Use /build-fix when**:
- ✅ Build is failing
- ✅ TypeScript compilation errors
- ✅ Dependency issues
- ✅ Module resolution problems
- ✅ Configuration errors

**Don't use /build-fix when**:
- ❌ Tests are failing (use /test-run)
- ❌ Application has runtime errors (use @BugResolver)
- ❌ Performance issues (use @PerformanceOptimizer)

---

## Integration with Quality Gates

/build-fix ensures:
- Build must succeed before deployment
- No TypeScript errors allowed
- All dependencies resolved
- Configuration files valid

---

## Related Commands

- `/test-run` - Run tests after build is fixed
- `/security-scan` - Security audit after build succeeds
- `/review-queue` - Add for review if complex fixes needed

---

**Remember**: A clean build is the foundation. Fix build errors before moving to other tasks.
