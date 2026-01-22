# 🧪 TDD Workflow

## Purpose
Test-Driven Development methodology and best practices for writing tests first, ensuring code quality, and maintaining high test coverage.

---

## TDD Cycle: Red-Green-Refactor

```
┌─────────────┐
│   1. RED    │ ← Write a failing test
└──────┬──────┘
       │
       ↓
┌─────────────┐
│  2. GREEN   │ ← Write minimal code to pass
└──────┬──────┘
       │
       ↓
┌─────────────┐
│ 3. REFACTOR │ ← Improve code quality
└──────┬──────┘
       │
       ↓ (repeat)
```

**The Three Laws of TDD**:
1. **Don't write production code** until you have a failing test
2. **Don't write more test** than is sufficient to fail
3. **Don't write more production code** than is sufficient to pass the test

---

## Step-by-Step TDD Process

### Step 1: Write a Failing Test (RED)

```typescript
// calculator.test.ts
import { Calculator } from './calculator';

describe('Calculator', () => {
  describe('add', () => {
    it('should return sum of two positive numbers', () => {
      const calc = new Calculator();
      expect(calc.add(2, 3)).toBe(5);
    });
  });
});

// Run test → ❌ FAIL (Calculator doesn't exist yet)
```

**Why this step matters**:
- Clarifies requirements before coding
- Ensures test actually works (avoids false positives)
- Forces you to think about API design

---

### Step 2: Write Minimal Code to Pass (GREEN)

```typescript
// calculator.ts
export class Calculator {
  add(a: number, b: number): number {
    return a + b; // Simplest implementation that passes
  }
}

// Run test → ✅ PASS
```

**Key principle**: Write the simplest code that makes the test pass. Don't overthink it.

---

### Step 3: Refactor (REFACTOR)

```typescript
// No refactoring needed yet - code is simple and clean

// Run test again → ✅ PASS (ensure refactoring didn't break anything)
```

**Refactoring guidelines**:
- Improve code structure without changing behavior
- Remove duplication
- Improve names and clarity
- **Always keep tests passing**

---

## TDD Best Practices

### 1. **Start with the Simplest Test**

```typescript
// ❌ Bad: Starting with complex test
it('should calculate quarterly tax with deductions and credits', () => {
  // Complex test with many edge cases
});

// ✅ Good: Start simple, build up
it('should return 0 for zero income', () => {
  expect(calculateTax(0)).toBe(0);
});

it('should calculate basic tax for simple income', () => {
  expect(calculateTax(1000)).toBe(100);
});

// Then add complexity gradually...
```

---

### 2. **One Test at a Time**

```typescript
// Write one test
it('should add two numbers', () => {
  expect(add(2, 3)).toBe(5);
});

// Make it pass
export function add(a: number, b: number) {
  return a + b;
}

// ✅ GREEN → Now write next test
it('should handle negative numbers', () => {
  expect(add(-2, 3)).toBe(1);
});

// Code already handles it → ✅ GREEN → Next test
```

---

### 3. **Test Behavior, Not Implementation**

```typescript
// ❌ Bad: Testing implementation details
it('should call the internal cache method', () => {
  const service = new UserService();
  const cacheSpy = jest.spyOn(service, 'cacheUser');
  service.getUser('123');
  expect(cacheSpy).toHaveBeenCalled();
});

// ✅ Good: Testing behavior/outcome
it('should return user data for valid ID', async () => {
  const service = new UserService();
  const user = await service.getUser('123');
  expect(user).toEqual({ id: '123', name: 'John Doe' });
});

it('should return same user on subsequent calls (caching behavior)', async () => {
  const service = new UserService();
  const user1 = await service.getUser('123');
  const user2 = await service.getUser('123');
  expect(user1).toBe(user2); // Same object reference
});
```

---

### 4. **Arrange-Act-Assert (AAA) Pattern**

```typescript
it('should update user email', () => {
  // ARRANGE: Set up test data and dependencies
  const user = new User('123', 'john@old.com');
  const newEmail = 'john@new.com';

  // ACT: Perform the action being tested
  user.updateEmail(newEmail);

  // ASSERT: Verify the outcome
  expect(user.email).toBe(newEmail);
});
```

---

### 5. **Keep Tests Independent**

```typescript
// ❌ Bad: Tests depend on execution order
let userId: string;

it('should create user', () => {
  userId = createUser({ name: 'John' });
  expect(userId).toBeDefined();
});

it('should get user by id', () => {
  const user = getUser(userId); // Depends on previous test
  expect(user.name).toBe('John');
});

// ✅ Good: Each test is independent
describe('User operations', () => {
  beforeEach(() => {
    // Setup runs before each test
    cleanDatabase();
  });

  it('should create user', () => {
    const userId = createUser({ name: 'John' });
    expect(userId).toBeDefined();
  });

  it('should get user by id', () => {
    const userId = createUser({ name: 'Jane' });
    const user = getUser(userId);
    expect(user.name).toBe('Jane');
  });
});
```

---

## Test Types & Pyramid

```
        ┌─────────┐
        │   E2E   │ ← Few, slow, high confidence
        └─────────┘
       ┌───────────┐
       │Integration│ ← Some, medium speed
       └───────────┘
      ┌─────────────┐
      │    Unit     │ ← Many, fast, low-level
      └─────────────┘
```

### Unit Tests (70%)
Test individual functions/components in isolation.

```typescript
// Pure function unit test
describe('calculateDiscount', () => {
  it('should return 10% discount for orders over $100', () => {
    expect(calculateDiscount(150)).toBe(15);
  });

  it('should return 0 discount for orders under $100', () => {
    expect(calculateDiscount(50)).toBe(0);
  });
});
```

---

### Integration Tests (20%)
Test how multiple units work together.

```typescript
describe('UserService integration', () => {
  it('should create user and send welcome email', async () => {
    const emailSpy = jest.spyOn(emailService, 'send');

    const user = await userService.createUser({
      name: 'John',
      email: 'john@example.com'
    });

    expect(user.id).toBeDefined();
    expect(emailSpy).toHaveBeenCalledWith({
      to: 'john@example.com',
      subject: 'Welcome!',
      template: 'welcome'
    });
  });
});
```

---

### End-to-End Tests (10%)
Test complete user workflows.

```typescript
// Using Playwright
test('user can complete purchase flow', async ({ page }) => {
  await page.goto('/products');

  // Add item to cart
  await page.click('[data-testid="add-to-cart-123"]');

  // Go to checkout
  await page.click('[data-testid="checkout"]');

  // Fill payment info
  await page.fill('[name="cardNumber"]', '4242424242424242');
  await page.click('[data-testid="submit-payment"]');

  // Verify success
  await expect(page.locator('.success-message')).toContainText('Order confirmed');
});
```

---

## Mocking & Test Doubles

### 1. **Mocks**
Objects that verify interactions.

```typescript
it('should log errors when API call fails', async () => {
  const loggerMock = {
    error: jest.fn()
  };

  const service = new UserService(loggerMock);

  await service.getUser('invalid-id');

  expect(loggerMock.error).toHaveBeenCalledWith(
    'Failed to fetch user',
    expect.any(Object)
  );
});
```

---

### 2. **Stubs**
Provide predefined responses.

```typescript
it('should return user from API', async () => {
  const apiStub = {
    getUser: jest.fn().mockResolvedValue({
      id: '123',
      name: 'John Doe'
    })
  };

  const service = new UserService(apiStub);
  const user = await service.getUser('123');

  expect(user.name).toBe('John Doe');
});
```

---

### 3. **Spies**
Record information about function calls.

```typescript
it('should cache user after first fetch', async () => {
  const service = new UserService();
  const fetchSpy = jest.spyOn(service, 'fetchFromAPI');

  await service.getUser('123');
  await service.getUser('123');

  expect(fetchSpy).toHaveBeenCalledTimes(1); // Only fetched once
});
```

---

### 4. **Fakes**
Working implementations for testing.

```typescript
// Fake in-memory database for testing
class FakeUserRepository implements IUserRepository {
  private users = new Map<string, User>();

  async findById(id: string): Promise<User | null> {
    return this.users.get(id) || null;
  }

  async create(user: User): Promise<User> {
    this.users.set(user.id, user);
    return user;
  }
}

// Test using fake
it('should store and retrieve user', async () => {
  const repo = new FakeUserRepository();
  const service = new UserService(repo);

  await service.createUser({ name: 'John' });
  const user = await service.getUser('123');

  expect(user.name).toBe('John');
});
```

---

## Coverage Goals

### Target Metrics
- **Overall Coverage**: ≥80%
- **Critical Paths**: 100% (auth, payments, data integrity)
- **Utilities**: 90%+
- **UI Components**: 70%+

### What to Measure
```typescript
// Run coverage report
npm run test -- --coverage

// Coverage output
--------------------|---------|----------|---------|---------|
File                | % Stmts | % Branch | % Funcs | % Lines |
--------------------|---------|----------|---------|---------|
calculator.ts       |   100   |   100    |   100   |   100   |
user-service.ts     |   85.5  |   75     |   90    |   85    |
--------------------|---------|----------|---------|---------|
```

**Focus on**:
- Statement coverage (every line executed)
- Branch coverage (all if/else paths)
- Function coverage (all functions called)

**Don't obsess over 100%** - Some code isn't worth testing (simple getters, trivial wrappers).

---

## Common TDD Patterns

### 1. **Parameterized Tests**
```typescript
describe('calculateTax', () => {
  test.each([
    [0, 0],
    [1000, 100],
    [5000, 750],
    [10000, 2000]
  ])('calculateTax(%i) should return %i', (income, expectedTax) => {
    expect(calculateTax(income)).toBe(expectedTax);
  });
});
```

---

### 2. **Test Fixtures**
```typescript
// test/fixtures/users.ts
export const mockUsers = {
  john: {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com'
  },
  jane: {
    id: '2',
    name: 'Jane Smith',
    email: 'jane@example.com'
  }
};

// In tests
import { mockUsers } from '../fixtures/users';

it('should process user data', () => {
  const result = processUser(mockUsers.john);
  expect(result.displayName).toBe('John Doe');
});
```

---

### 3. **Test Builders**
```typescript
class UserBuilder {
  private user: Partial<User> = {
    id: '123',
    name: 'Default User',
    email: 'user@example.com',
    role: 'user'
  };

  withName(name: string) {
    this.user.name = name;
    return this;
  }

  withRole(role: string) {
    this.user.role = role;
    return this;
  }

  build(): User {
    return this.user as User;
  }
}

// Usage
it('should grant admin privileges', () => {
  const admin = new UserBuilder()
    .withName('Admin User')
    .withRole('admin')
    .build();

  expect(canAccessAdminPanel(admin)).toBe(true);
});
```

---

## Debugging Failing Tests

### 1. **Read the Error Message**
```typescript
// Test output:
// Expected: 5
// Received: 6

// Look at the test:
expect(calculator.add(2, 3)).toBe(5);

// Check implementation:
add(a: number, b: number) {
  return a + b + 1; // ← Bug here!
}
```

---

### 2. **Isolate the Problem**
```typescript
// If test fails, add debug output:
it('should calculate total', () => {
  const items = [{ price: 10 }, { price: 20 }];
  const total = calculateTotal(items);

  console.log('Items:', items); // Debug
  console.log('Total:', total); // Debug

  expect(total).toBe(30);
});
```

---

### 3. **Use Test.only**
```typescript
// Run only this test to focus on the issue
describe('Calculator', () => {
  it.only('should add numbers', () => {
    // This test will run
  });

  it('should subtract numbers', () => {
    // This test will be skipped
  });
});
```

---

## TDD Workflow Checklist

**Before Starting**:
- [ ] Understand the requirement clearly
- [ ] Think about edge cases
- [ ] Consider the API design

**During TDD Cycle**:
- [ ] Write smallest possible failing test (RED)
- [ ] Write minimal code to pass (GREEN)
- [ ] Run test and verify it passes
- [ ] Refactor if needed (REFACTOR)
- [ ] Run test again to ensure it still passes
- [ ] Commit if test passes

**After Implementation**:
- [ ] Review test coverage (aim for ≥80%)
- [ ] Check for missing edge cases
- [ ] Ensure tests are clear and maintainable
- [ ] Remove any skipped/disabled tests

---

## Benefits of TDD

1. **Better Design**: Writing tests first forces you to think about API design
2. **Confidence**: High test coverage means fewer bugs in production
3. **Documentation**: Tests serve as living documentation
4. **Refactoring Safety**: Can refactor confidently with tests as safety net
5. **Faster Debugging**: When tests fail, you know exactly what broke
6. **Reduced Debugging Time**: Catch bugs immediately, not in production

---

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
