# 🧪 Testing Rules

## Purpose
Mandatory testing requirements and best practices for all Legendary Team agents.

---

## Test Coverage Requirements

### 1. **Minimum Coverage: 80%**
```bash
# ✅ REQUIRED - Run coverage report
npm test -- --coverage

# Target metrics:
# - Overall: ≥ 80%
# - Critical paths: 100% (auth, payments, data integrity)
# - Utilities: ≥ 90%
# - UI Components: ≥ 70%
```

**Rule**: New code MUST maintain ≥80% overall test coverage.

---

### 2. **Critical Paths: 100% Coverage**
```typescript
// ✅ REQUIRED - Full coverage for critical code
describe('Authentication', () => {
  it('should authenticate valid credentials', async () => { });
  it('should reject invalid credentials', async () => { });
  it('should hash passwords before storing', async () => { });
  it('should generate secure tokens', async () => { });
  it('should validate token expiry', async () => { });
  it('should handle missing credentials', async () => { });
});

describe('PaymentProcessor', () => {
  it('should process valid payment', async () => { });
  it('should reject invalid card', async () => { });
  it('should handle network errors', async () => { });
  it('should refund payments', async () => { });
  it('should log all transactions', async () => { });
});
```

**Rule**: Authentication, payments, and data integrity code MUST have 100% test coverage.

---

## Test-Driven Development (TDD)

### 3. **Write Tests First for New Features**
```typescript
// ✅ REQUIRED - TDD Workflow

// Step 1: Write failing test (RED)
describe('calculateDiscount', () => {
  it('should return 10% discount for orders over $100', () => {
    expect(calculateDiscount(150)).toBe(15);
  });
});
// Test fails → calculateDiscount doesn't exist

// Step 2: Write minimal code (GREEN)
function calculateDiscount(amount: number): number {
  return amount > 100 ? amount * 0.1 : 0;
}
// Test passes

// Step 3: Refactor if needed (REFACTOR)
// Improve code without breaking tests
```

**Rule**: For new features, write tests BEFORE implementation.

---

## Test Organization

### 4. **AAA Pattern: Arrange-Act-Assert**
```typescript
// ✅ REQUIRED
it('should update user email', async () => {
  // ARRANGE: Set up test data
  const user = await createTestUser();
  const newEmail = 'new@example.com';

  // ACT: Perform the action
  await user.updateEmail(newEmail);

  // ASSERT: Verify the outcome
  expect(user.email).toBe(newEmail);
});
```

**Rule**: All tests MUST follow AAA pattern.

---

### 5. **One Assertion Concept Per Test**
```typescript
// ❌ DISCOURAGED - Testing multiple things
it('should create user', async () => {
  const user = await createUser({ name: 'John' });
  expect(user.id).toBeDefined();
  expect(user.name).toBe('John');
  expect(user.createdAt).toBeDefined();
  expect(user.role).toBe('user');
});

// ✅ REQUIRED - Focus on one concept
describe('createUser', () => {
  it('should assign a unique ID', async () => {
    const user = await createUser({ name: 'John' });
    expect(user.id).toBeDefined();
  });

  it('should set the provided name', async () => {
    const user = await createUser({ name: 'John' });
    expect(user.name).toBe('John');
  });

  it('should set default role to user', async () => {
    const user = await createUser({ name: 'John' });
    expect(user.role).toBe('user');
  });
});
```

**Rule**: Each test should focus on ONE concept. Multiple assertions are okay if testing the same concept.

---

### 6. **Descriptive Test Names**
```typescript
// ❌ FORBIDDEN
it('should work', () => { });
it('test user', () => { });

// ✅ REQUIRED
it('should return user when valid ID is provided', async () => { });
it('should throw NotFoundError when user does not exist', async () => { });
it('should hash password before storing in database', async () => { });
```

**Rule**: Test names MUST clearly describe what is being tested and expected outcome.

---

## Test Independence

### 7. **Tests Must Be Independent**
```typescript
// ❌ FORBIDDEN - Tests depend on each other
let userId: string;

it('should create user', async () => {
  userId = await createUser({ name: 'John' });
  expect(userId).toBeDefined();
});

it('should get user', async () => {
  const user = await getUser(userId); // Depends on previous test
  expect(user.name).toBe('John');
});

// ✅ REQUIRED - Each test is independent
describe('User operations', () => {
  beforeEach(async () => {
    await cleanDatabase();
  });

  it('should create user', async () => {
    const userId = await createUser({ name: 'John' });
    expect(userId).toBeDefined();
  });

  it('should get user', async () => {
    const userId = await createUser({ name: 'Jane' });
    const user = await getUser(userId);
    expect(user.name).toBe('Jane');
  });
});
```

**Rule**: Tests MUST run independently in any order.

---

### 8. **Clean Up After Tests**
```typescript
// ✅ REQUIRED
describe('UserService', () => {
  let testUser: User;

  beforeEach(async () => {
    testUser = await createTestUser();
  });

  afterEach(async () => {
    await deleteUser(testUser.id);
    await cleanupTestData();
  });

  it('should update user', async () => {
    // Test implementation
  });
});
```

**Rule**: Always clean up test data in `afterEach` or `afterAll`.

---

## Mocking and Test Doubles

### 9. **Mock External Dependencies**
```typescript
// ✅ REQUIRED - Mock external services
describe('OrderService', () => {
  let mockEmailService: jest.Mocked<EmailService>;
  let mockPaymentService: jest.Mocked<PaymentService>;

  beforeEach(() => {
    mockEmailService = {
      send: jest.fn().mockResolvedValue(true)
    };

    mockPaymentService = {
      charge: jest.fn().mockResolvedValue({ id: 'payment-123' })
    };
  });

  it('should send confirmation email after order', async () => {
    const orderService = new OrderService(mockEmailService, mockPaymentService);

    await orderService.createOrder({ items: [...] });

    expect(mockEmailService.send).toHaveBeenCalledWith(
      expect.objectContaining({
        subject: 'Order Confirmation'
      })
    );
  });
});
```

**Rule**: External dependencies (APIs, databases, email services) MUST be mocked in unit tests.

---

### 10. **Don't Mock What You Don't Own**
```typescript
// ❌ DISCOURAGED - Mocking third-party library internals
jest.mock('some-library', () => ({
  internalMethod: jest.fn()
}));

// ✅ REQUIRED - Create adapter and mock the adapter
interface PaymentGateway {
  charge(amount: number): Promise<PaymentResult>;
}

class StripeAdapter implements PaymentGateway {
  async charge(amount: number): Promise<PaymentResult> {
    // Use Stripe library
  }
}

// In tests, mock your adapter
const mockGateway: jest.Mocked<PaymentGateway> = {
  charge: jest.fn().mockResolvedValue({ success: true })
};
```

**Rule**: Create adapters for third-party libraries. Mock your adapters, not the libraries.

---

## Test Types

### 11. **Unit Tests (70% of tests)**
```typescript
// ✅ REQUIRED - Test pure functions and methods in isolation
describe('calculateTax', () => {
  it('should return 0 for zero income', () => {
    expect(calculateTax(0)).toBe(0);
  });

  it('should calculate 10% tax for income under $10,000', () => {
    expect(calculateTax(5000)).toBe(500);
  });

  it('should calculate progressive tax for higher incomes', () => {
    expect(calculateTax(50000)).toBe(7500);
  });
});
```

**Rule**: Most tests should be unit tests - fast, isolated, focused.

---

### 12. **Integration Tests (20% of tests)**
```typescript
// ✅ REQUIRED - Test component interactions
describe('OrderService integration', () => {
  it('should create order, charge payment, and send email', async () => {
    const orderService = new OrderService(
      new OrderRepository(db),
      new PaymentService(),
      new EmailService()
    );

    const order = await orderService.createOrder({
      userId: 'user-123',
      items: [{ id: 'item-1', quantity: 2 }]
    });

    // Verify order was created
    const savedOrder = await db.orders.findById(order.id);
    expect(savedOrder).toBeDefined();

    // Verify payment was processed
    const payment = await db.payments.findOne({ orderId: order.id });
    expect(payment.status).toBe('completed');

    // Verify email was sent (check email queue)
    const emailJob = await emailQueue.getJob(order.id);
    expect(emailJob).toBeDefined();
  });
});
```

**Rule**: Integration tests verify that components work together correctly.

---

### 13. **E2E Tests (10% of tests)**
```typescript
// ✅ REQUIRED - Test critical user flows
import { test, expect } from '@playwright/test';

test('user can complete purchase', async ({ page }) => {
  // Navigate to product page
  await page.goto('/products/laptop');

  // Add to cart
  await page.click('[data-testid="add-to-cart"]');

  // Go to checkout
  await page.click('[data-testid="checkout"]');

  // Fill payment info
  await page.fill('[name="cardNumber"]', '4242424242424242');
  await page.fill('[name="expiry"]', '12/25');
  await page.fill('[name="cvc"]', '123');

  // Submit payment
  await page.click('[data-testid="submit-payment"]');

  // Verify success
  await expect(page.locator('.success-message')).toContainText('Order confirmed');
});
```

**Rule**: E2E tests verify critical user journeys work end-to-end.

---

## Test Performance

### 14. **Fast Tests**
```typescript
// ✅ REQUIRED - Unit tests should be fast (< 10ms each)
describe('calculateTotal', () => {
  it('should sum item prices', () => {
    const items = [{ price: 10 }, { price: 20 }];
    expect(calculateTotal(items)).toBe(30);
  });
  // This test runs in ~1ms
});

// ✅ ACCEPTABLE - Integration tests can be slower (< 1s each)
describe('UserService integration', () => {
  it('should create and fetch user', async () => {
    const user = await createUser({ name: 'John' });
    const fetched = await getUser(user.id);
    expect(fetched.name).toBe('John');
  });
  // This test runs in ~100ms
});
```

**Rule**: Unit tests SHOULD run in < 10ms. Integration tests SHOULD run in < 1s.

---

### 15. **Parallel Test Execution**
```json
// package.json
{
  "scripts": {
    "test": "jest --maxWorkers=4",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

**Rule**: Tests SHOULD run in parallel for faster feedback.

---

## Error Cases

### 16. **Test Error Conditions**
```typescript
// ✅ REQUIRED - Test both success and failure
describe('getUser', () => {
  it('should return user when ID exists', async () => {
    const user = await getUser('valid-id');
    expect(user).toBeDefined();
  });

  it('should throw NotFoundError when ID does not exist', async () => {
    await expect(getUser('invalid-id')).rejects.toThrow(NotFoundError);
  });

  it('should throw ValidationError for invalid ID format', async () => {
    await expect(getUser('')).rejects.toThrow(ValidationError);
  });
});
```

**Rule**: Test both happy path AND error cases.

---

### 17. **Test Edge Cases**
```typescript
// ✅ REQUIRED - Test boundary conditions
describe('calculateDiscount', () => {
  it('should return 0 for $0', () => {
    expect(calculateDiscount(0)).toBe(0);
  });

  it('should return 0 for $99.99 (just below threshold)', () => {
    expect(calculateDiscount(99.99)).toBe(0);
  });

  it('should return discount for $100.00 (at threshold)', () => {
    expect(calculateDiscount(100)).toBe(10);
  });

  it('should return discount for $100.01 (just above threshold)', () => {
    expect(calculateDiscount(100.01)).toBe(10.001);
  });

  it('should handle very large amounts', () => {
    expect(calculateDiscount(1000000)).toBe(100000);
  });
});
```

**Rule**: Test edge cases and boundary conditions.

---

## Test Data

### 18. **Use Test Fixtures**
```typescript
// tests/fixtures/users.ts
export const mockUsers = {
  john: {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'user'
  },
  admin: {
    id: '2',
    name: 'Admin User',
    email: 'admin@example.com',
    role: 'admin'
  }
};

// In tests
import { mockUsers } from '../fixtures/users';

it('should process user', () => {
  const result = processUser(mockUsers.john);
  expect(result.displayName).toBe('John Doe');
});
```

**Rule**: Use test fixtures for consistent test data.

---

### 19. **Test Data Builders**
```typescript
// ✅ REQUIRED - Use builders for complex objects
class UserBuilder {
  private user: Partial<User> = {
    id: 'test-id',
    name: 'Test User',
    email: 'test@example.com',
    role: 'user',
    isActive: true
  };

  withName(name: string): this {
    this.user.name = name;
    return this;
  }

  withRole(role: string): this {
    this.user.role = role;
    return this;
  }

  inactive(): this {
    this.user.isActive = false;
    return this;
  }

  build(): User {
    return this.user as User;
  }
}

// Usage
it('should not allow inactive users', () => {
  const user = new UserBuilder()
    .withName('John')
    .inactive()
    .build();

  expect(canAccess(user)).toBe(false);
});
```

**Rule**: Use builders for creating test data with different variations.

---

## Continuous Testing

### 20. **Run Tests Before Committing**
```bash
# ✅ REQUIRED - Add pre-commit hook
# .husky/pre-commit
#!/bin/sh
npm test
npm run lint

# Only commit if tests pass
```

**Rule**: Tests MUST pass before committing.

---

### 21. **Run Tests in CI/CD**
```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: npm install
      - run: npm test -- --coverage
      - run: npm run lint
```

**Rule**: CI/CD pipeline MUST run tests on every push.

---

## Test Maintenance

### 22. **No Skipped Tests in Main Branch**
```typescript
// ❌ FORBIDDEN in main branch
it.skip('should process payment', () => {
  // Test implementation
});

// ✅ ACCEPTABLE temporarily in feature branch
it.skip('should process payment - TODO: fix after API update', () => {
  // Test implementation
});
```

**Rule**: No `skip` or `todo` tests allowed in main branch.

---

### 23. **Update Tests When Code Changes**
```typescript
// ✅ REQUIRED - When refactoring code, update tests too

// Old implementation
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Refactored implementation
function calculateTotal(items: Item[], taxRate: number = 0): number {
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  return subtotal * (1 + taxRate);
}

// Update tests
describe('calculateTotal', () => {
  it('should calculate subtotal without tax', () => {
    expect(calculateTotal(items)).toBe(100);
  });

  it('should calculate total with tax', () => {
    expect(calculateTotal(items, 0.1)).toBe(110);
  });
});
```

**Rule**: Tests MUST be updated when implementation changes.

---

**REMEMBER**: Tests are not optional. They are your safety net and documentation.

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
