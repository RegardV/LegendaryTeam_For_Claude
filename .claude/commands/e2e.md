# /e2e - E2E Test Generation & Execution

Generate and execute end-to-end tests for user workflows using Playwright.

---

## Usage

```bash
# Generate E2E test for a user flow
/e2e "user can login and view dashboard"

# Generate E2E test with specific steps
/e2e "checkout flow: add item to cart, proceed to checkout, complete payment"

# Run existing E2E tests
/e2e run

# Run specific E2E test file
/e2e run auth/login.spec.ts

# Generate test for specific page/component
/e2e "test profile page with all user interactions"
```

---

## What This Command Does

1. **Analyzes** the requested user flow or feature
2. **Generates** Playwright E2E test with proper selectors
3. **Creates** test file in `e2e/` directory
4. **Runs** the test to verify it works
5. **Reports** results with screenshots on failure

---

## Command Flow

```markdown
Step 1: Parse user request
  → Identify user flow/journey
  → Break down into testable steps

Step 2: Generate test
  → Create Playwright test file
  → Use proper selectors (data-testid preferred)
  → Add proper waits and assertions

Step 3: Execute test
  → Run Playwright test
  → Capture screenshots/videos on failure
  → Report results

Step 4: Integrate
  → Add test to test suite
  → Update CI/CD if needed
```

---

## Invokes Agent

**@E2ERunner** will handle this command with the following context:

```markdown
Task: Generate E2E test for user workflow
Description: ${user_input}

Requirements:
1. Create Playwright test file
2. Use proper selectors (prefer data-testid)
3. Include proper waits and assertions
4. Handle errors and edge cases
5. Run test to verify it works
6. Provide test report with results

Output:
- Test file path
- Test execution results
- Screenshots on failure
- Recommendations for improvement
```

---

## Example: Login Flow

**Input**:
```bash
/e2e "user can login with email and password"
```

**Generated Test** (`e2e/auth/login.spec.ts`):
```typescript
import { test, expect } from '@playwright/test';

test.describe('User Login', () => {
  test('should login with valid credentials', async ({ page }) => {
    // Navigate to login page
    await page.goto('/login');

    // Fill login form
    await page.fill('[data-testid="email-input"]', 'test@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');

    // Submit form
    await page.click('[data-testid="login-button"]');

    // Verify redirect to dashboard
    await expect(page).toHaveURL(/\/dashboard/);
    await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[data-testid="email-input"]', 'invalid@example.com');
    await page.fill('[data-testid="password-input"]', 'wrongpassword');

    await page.click('[data-testid="login-button"]');

    // Verify error message
    await expect(page.locator('[data-testid="error-message"]')).toContainText('Invalid credentials');
  });
});
```

**Output**:
```markdown
## E2E Test Generated ✅

**File**: `e2e/auth/login.spec.ts`
**Tests**: 2
**Execution Time**: 8.5s

### Test Results
1. ✅ should login with valid credentials (4.2s)
2. ✅ should show error for invalid credentials (4.3s)

### Coverage
- Happy path: User can login with valid credentials
- Error case: Invalid credentials handled properly

**Next Steps**:
- Add test for password reset flow
- Add test for "remember me" functionality
- Consider adding tests for:
  - Email validation
  - Password strength requirements
  - Account lockout after failed attempts
```

---

## Example: E-Commerce Checkout

**Input**:
```bash
/e2e "complete checkout flow: browse products, add to cart, checkout, payment"
```

**Generated Test** (`e2e/checkout/complete-flow.spec.ts`):
```typescript
import { test, expect } from '@playwright/test';

test.describe('Complete Checkout Flow', () => {
  test('should complete full purchase journey', async ({ page }) => {
    // 1. Browse products
    await page.goto('/products');
    await expect(page.locator('[data-testid="product-grid"]')).toBeVisible();

    // 2. Select product
    await page.click('[data-testid="product-card"]:first-child');
    await expect(page.locator('[data-testid="product-details"]')).toBeVisible();

    // 3. Add to cart
    await page.click('[data-testid="add-to-cart"]');
    await expect(page.locator('[data-testid="cart-count"]')).toContainText('1');

    // 4. View cart
    await page.click('[data-testid="cart-icon"]');
    await expect(page).toHaveURL(/\/cart/);

    // 5. Proceed to checkout
    await page.click('[data-testid="checkout-button"]');
    await expect(page).toHaveURL(/\/checkout/);

    // 6. Fill shipping info
    await page.fill('[data-testid="name"]', 'John Doe');
    await page.fill('[data-testid="address"]', '123 Main St');
    await page.fill('[data-testid="city"]', 'New York');
    await page.fill('[data-testid="zip"]', '10001');

    // 7. Continue to payment
    await page.click('[data-testid="continue-to-payment"]');

    // 8. Fill payment info (using test card)
    await page.fill('[data-testid="card-number"]', '4242424242424242');
    await page.fill('[data-testid="expiry"]', '12/25');
    await page.fill('[data-testid="cvc"]', '123');

    // 9. Complete purchase
    await Promise.all([
      page.waitForResponse(resp => resp.url().includes('/api/orders')),
      page.click('[data-testid="complete-order"]')
    ]);

    // 10. Verify success
    await expect(page).toHaveURL(/\/order\/confirmation/);
    await expect(page.locator('[data-testid="success-message"]')).toContainText('Order confirmed');
    await expect(page.locator('[data-testid="order-number"]')).toBeVisible();
  });
});
```

---

## Running Tests

```bash
# Run all E2E tests
/e2e run

# Run specific test file
/e2e run auth/login.spec.ts

# Run tests in headed mode (see browser)
/e2e run --headed

# Run tests in debug mode
/e2e run --debug
```

**Output**:
```markdown
## E2E Test Execution

Running: e2e/auth/login.spec.ts

### Results
✅ User Login > should login with valid credentials (4.2s)
✅ User Login > should show error for invalid credentials (4.3s)

**Duration**: 8.5s
**Tests**: 2 passed, 0 failed
**Status**: ✅ All tests passing
```

---

## Test Quality Guidelines

@E2ERunner will ensure tests follow best practices:

1. **Selectors**:
   - Prefer `data-testid` attributes
   - Fallback to role/name selectors
   - Avoid CSS classes and XPath

2. **Waits**:
   - Use proper wait strategies
   - Wait for API responses
   - No hard-coded timeouts

3. **Assertions**:
   - Verify expected behavior
   - Check both success and error cases
   - Validate navigation and UI state

4. **Organization**:
   - Group related tests in describe blocks
   - Use clear, descriptive test names
   - Keep tests independent

5. **Maintenance**:
   - Tests should be resilient to minor UI changes
   - Update tests when features change
   - Remove obsolete tests

---

## When to Use This Command

**Use /e2e when**:
- ✅ Testing complete user workflows
- ✅ Verifying critical paths (login, checkout, etc.)
- ✅ Testing UI interactions and navigation
- ✅ Validating integration between frontend and backend
- ✅ Regression testing after major changes

**Don't use /e2e when**:
- ❌ Testing individual functions (use /test-run for unit tests)
- ❌ Testing API endpoints (use integration tests)
- ❌ Performance testing (use @PerformanceOptimizer)
- ❌ Security testing (use /security-scan)

---

## Integration with CI/CD

Generated tests automatically integrate with CI/CD:

```yaml
# GitHub Actions workflow
name: E2E Tests
on: [push, pull_request]

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: npm ci
      - name: Install Playwright
        run: npx playwright install --with-deps
      - name: Run E2E tests
        run: npx playwright test
      - name: Upload artifacts
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright-report/
```

---

## Troubleshooting

**Test times out**:
- Check if selectors are correct
- Verify element is actually rendered
- Increase timeout if necessary

**Element not found**:
- Verify selector with Playwright Inspector
- Check if element is in iframe
- Ensure element is visible (not hidden)

**Flaky test**:
- Remove hard-coded waits
- Wait for specific conditions
- Check for race conditions

---

## Related Commands

- `/test-run` - Run unit and integration tests
- `/security-scan` - Run security tests
- `/build-fix` - Fix build errors preventing test runs

---

**Remember**: E2E tests are your safety net for critical user flows. Focus on high-value paths, not exhaustive coverage.
