# 📐 Coding Standards

## Purpose
Unified coding standards for maintaining consistency, readability, and maintainability across all code written by Legendary Team agents.

---

## General Principles

### 1. **Code Clarity Over Cleverness**
- Write code that is easy to understand
- Avoid overly complex one-liners
- Use descriptive variable and function names
- Comment non-obvious logic

### 2. **Consistency**
- Follow established patterns in the codebase
- Match existing code style before introducing new patterns
- Use consistent naming conventions throughout

### 3. **Maintainability**
- Write code that's easy to change
- Keep functions small and focused (single responsibility)
- Minimize dependencies between modules
- Avoid premature optimization

---

## Naming Conventions

### Variables
- **Use descriptive names**: `userAccount` not `ua`
- **Boolean variables**: Start with `is`, `has`, `can`, `should`
  - `isActive`, `hasPermission`, `canEdit`, `shouldValidate`
- **Arrays/Collections**: Use plural nouns
  - `users`, `items`, `transactions`
- **Constants**: UPPER_SNAKE_CASE
  - `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT`

### Functions/Methods
- **Use verbs**: `getUser()`, `calculateTotal()`, `validateInput()`
- **Boolean returns**: Start with `is`, `has`, `can`, `should`
  - `isValid()`, `hasAccess()`, `canDelete()`
- **Event handlers**: Start with `handle` or `on`
  - `handleClick()`, `onSubmit()`

### Classes/Components
- **PascalCase**: `UserAccount`, `PaymentProcessor`
- **Descriptive**: Indicate purpose clearly
- **Avoid generic names**: `Manager`, `Handler`, `Utility` (be specific)

---

## Code Organization

### File Structure
```
src/
├── components/       # UI components
├── services/         # Business logic
├── utils/            # Pure helper functions
├── types/            # TypeScript types/interfaces
├── hooks/            # React hooks (if applicable)
├── config/           # Configuration files
└── tests/            # Test files
```

### Module Organization
```javascript
// 1. Imports (grouped)
import { external } from 'library';
import { internalA, internalB } from './internal';
import type { MyType } from './types';

// 2. Constants
const MAX_RETRIES = 3;

// 3. Types/Interfaces
interface User {
  id: string;
  name: string;
}

// 4. Main code
export function processUser(user: User) {
  // implementation
}

// 5. Helper functions (if private to module)
function helperFunction() {
  // implementation
}
```

---

## Best Practices

### 1. **Error Handling**
```javascript
// ✅ Good: Specific error handling
try {
  const data = await fetchUser(id);
  return processData(data);
} catch (error) {
  if (error instanceof NetworkError) {
    logger.error('Network failed', { error, userId: id });
    throw new ServiceUnavailableError('User service unavailable');
  }
  throw error;
}

// ❌ Bad: Silent failure
try {
  const data = await fetchUser(id);
  return processData(data);
} catch (error) {
  return null; // Silent failure
}
```

### 2. **Immutability**
```javascript
// ✅ Good: Immutable updates
const updatedUser = {
  ...user,
  name: newName,
  updatedAt: Date.now()
};

const updatedItems = items.map(item =>
  item.id === targetId ? { ...item, status: 'active' } : item
);

// ❌ Bad: Direct mutation
user.name = newName;
items[0].status = 'active';
```

### 3. **Function Purity**
```javascript
// ✅ Good: Pure function
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ❌ Bad: Side effects
let total = 0;
function calculateTotal(items: Item[]): void {
  items.forEach(item => {
    total += item.price; // Mutates external state
  });
}
```

### 4. **Async/Await Over Promises**
```javascript
// ✅ Good: Clean async/await
async function loadUserData(userId: string) {
  const user = await fetchUser(userId);
  const posts = await fetchUserPosts(userId);
  return { user, posts };
}

// ❌ Bad: Promise chains
function loadUserData(userId: string) {
  return fetchUser(userId)
    .then(user => {
      return fetchUserPosts(userId)
        .then(posts => ({ user, posts }));
    });
}
```

### 5. **Early Returns**
```javascript
// ✅ Good: Early returns reduce nesting
function processOrder(order: Order) {
  if (!order.isValid) {
    return { error: 'Invalid order' };
  }

  if (!order.isPaid) {
    return { error: 'Payment required' };
  }

  return fulfillOrder(order);
}

// ❌ Bad: Nested conditions
function processOrder(order: Order) {
  if (order.isValid) {
    if (order.isPaid) {
      return fulfillOrder(order);
    } else {
      return { error: 'Payment required' };
    }
  } else {
    return { error: 'Invalid order' };
  }
}
```

---

## Language-Specific Standards

### TypeScript
- Always use explicit types for function parameters and returns
- Prefer interfaces for object shapes
- Use strict mode (`"strict": true` in tsconfig.json)
- Avoid `any` - use `unknown` if type is truly unknown

### React
- Use functional components with hooks
- Keep components small (< 200 lines)
- Extract custom hooks for reusable logic
- Use proper dependency arrays in useEffect

### Node.js
- Use async/await for async operations
- Proper error handling middleware
- Environment variables for configuration
- Structured logging

---

## Comments

### When to Comment
- **Complex algorithms**: Explain the "why" not the "what"
- **Business logic**: Document business rules
- **Workarounds**: Explain why a workaround is necessary
- **Public APIs**: Document parameters, returns, and behavior

### When NOT to Comment
```javascript
// ❌ Bad: Obvious comments
// Increment counter by 1
counter++;

// Get user by ID
const user = await getUser(id);

// ✅ Good: Explains non-obvious logic
// Use exponential backoff to avoid overwhelming the API
// during high-traffic periods (max 5 retries)
const data = await retryWithBackoff(fetchData, { maxRetries: 5 });
```

---

## Security Standards

### Input Validation
- Validate all user inputs
- Sanitize data before using in queries
- Use parameterized queries (never string concatenation)

### Sensitive Data
- Never log passwords, tokens, or API keys
- Use environment variables for secrets
- Encrypt sensitive data at rest

### Dependencies
- Keep dependencies up to date
- Review security advisories regularly
- Minimize dependency count

---

## Testing Standards

### Test Coverage
- Aim for 80%+ code coverage
- Focus on critical paths and edge cases
- Test public APIs, not implementation details

### Test Structure
```javascript
describe('calculateTotal', () => {
  it('should return 0 for empty array', () => {
    expect(calculateTotal([])).toBe(0);
  });

  it('should sum item prices correctly', () => {
    const items = [
      { price: 10 },
      { price: 20 },
      { price: 30 }
    ];
    expect(calculateTotal(items)).toBe(60);
  });
});
```

---

## Documentation Standards

### README Requirements
- Project overview and purpose
- Installation instructions
- Usage examples
- API documentation (if applicable)
- Contributing guidelines

### Code Documentation
- Document public APIs with JSDoc/TSDoc
- Include parameter types and return types
- Provide usage examples for complex functions

---

## Version Control

### Commit Messages
```
type(scope): subject

body

footer
```

**Types**: feat, fix, docs, style, refactor, test, chore

**Examples**:
```
feat(auth): add OAuth2 authentication flow

Implemented Google OAuth2 integration for user authentication.
Added login/logout endpoints and JWT token management.

Closes #123
```

### Branch Naming
- `feature/description` - New features
- `fix/description` - Bug fixes
- `refactor/description` - Code refactoring
- `docs/description` - Documentation updates

---

## Performance Considerations

### Avoid Premature Optimization
- Write clear code first
- Profile before optimizing
- Focus on algorithmic improvements over micro-optimizations

### Common Optimizations
- Memoization for expensive calculations
- Lazy loading for large data sets
- Debouncing/throttling for frequent events
- Virtual scrolling for long lists

---

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
