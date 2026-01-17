# Test Run

Run all tests and report coverage to @chief.

---

## What This Command Does

Automatically detects your test framework and runs:
1. **Unit tests** - Individual function/component tests
2. **Integration tests** - Multi-component interaction tests
3. **E2E tests** - Full user flow tests (if configured)
4. **Coverage analysis** - Code coverage reporting
5. **Results summary** - Pass/fail counts, coverage %, slow tests

**Then reports findings to @chief for review.**

---

## Usage

```bash
/test-run
```

**Optional flags:**
```bash
/test-run --watch          # Run in watch mode
/test-run --coverage       # Force coverage report
/test-run --unit-only      # Skip integration/E2E tests
/test-run --verbose        # Detailed output
```

---

## Implementation

This command auto-detects your project type and runs the appropriate test command.

### Auto-Detection Logic

**Node.js/JavaScript Projects:**
```bash
if [ -f "package.json" ]; then
  # Detect framework from package.json
  if grep -q '"jest"' package.json; then
    npm test -- --coverage --verbose
  elif grep -q '"mocha"' package.json; then
    npm test -- --coverage
  elif grep -q '"vitest"' package.json; then
    npm test -- --coverage
  else
    npm test
  fi
fi
```

**Python Projects:**
```bash
if [ -f "pytest.ini" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
  # pytest with coverage
  pytest --cov --cov-report=term --cov-report=html -v
elif [ -f "manage.py" ]; then
  # Django tests
  python manage.py test --keepdb --parallel
else
  # unittest
  python -m unittest discover -v
fi
```

**Ruby Projects:**
```bash
if [ -f "Gemfile" ]; then
  if grep -q 'rspec' Gemfile; then
    bundle exec rspec --format documentation
  else
    bundle exec rake test
  fi
fi
```

**Go Projects:**
```bash
if [ -f "go.mod" ]; then
  go test -v -cover ./...
fi
```

**Rust Projects:**
```bash
if [ -f "Cargo.toml" ]; then
  cargo test --verbose
fi
```

---

## Output Format

### Successful Test Run

```
╔══════════════════════════════════════════════════════════╗
║ TEST RUN RESULTS                                         ║
╚══════════════════════════════════════════════════════════╝

📊 Test Summary
  ✅ Unit Tests:        487 passed, 0 failed
  ✅ Integration Tests: 124 passed, 0 failed
  ✅ E2E Tests:          23 passed, 0 failed
  ────────────────────────────────────────────
  Total:                634 passed, 0 failed

⏱️  Execution Time
  Unit:        12.3s
  Integration: 45.2s
  E2E:         2m 15s
  Total:       3m 12s

📈 Coverage Report
  Statements:   94.2% (1,254 / 1,331)
  Branches:     89.5% (456 / 510)
  Functions:    92.8% (234 / 252)
  Lines:        94.1% (1,189 / 1,263)

  ✅ Coverage meets 80% threshold

⚠️  Slow Tests (>1s)
  1. checkout integration test: 3.2s
  2. payment processing e2e: 5.8s
  3. user registration flow: 2.1s

🎯 Recommendation
  All tests passing with excellent coverage.
  Consider optimizing slow tests.

📂 Coverage Report: file:///path/to/coverage/index.html
```

### Failed Test Run

```
╔══════════════════════════════════════════════════════════╗
║ TEST RUN RESULTS                                         ║
╚══════════════════════════════════════════════════════════╝

❌ Test Summary
  ⚠️  Unit Tests:        485 passed, 2 failed
  ✅ Integration Tests: 124 passed, 0 failed
  ❌ E2E Tests:           22 passed, 1 failed
  ────────────────────────────────────────────
  Total:                631 passed, 3 failed

🔴 Failed Tests

1. Unit Test: UserService.updateProfile
   File: tests/unit/user-service.test.js:45
   Error: Expected email to be validated

   Expected: ValidationError
   Received: undefined

2. Unit Test: OrderController.cancelOrder
   File: tests/unit/order-controller.test.js:123
   Error: Order status not updated correctly

   Expected: 'cancelled'
   Received: 'pending'

3. E2E Test: Complete checkout flow
   File: tests/e2e/checkout.spec.js:78
   Error: Payment button not clickable

   Timeout: Element not found after 5000ms

📈 Coverage Report
  Statements:   91.2% (1,215 / 1,331) ⚠️ Below 94% target
  Branches:     87.1% (444 / 510)
  Functions:    90.5% (228 / 252)
  Lines:        91.0% (1,149 / 1,263)

  ⚠️  Coverage decreased by 3%

🎯 Action Required
  ❌ 3 tests failing - must fix before deployment
  ⚠️  Coverage dropped below target

  Next steps:
  1. Fix UserService email validation
  2. Debug OrderController status update
  3. Investigate checkout E2E timeout

📂 Full Report: file:///path/to/test-results.html
```

### Coverage Below Threshold

```
╔══════════════════════════════════════════════════════════╗
║ TEST RUN RESULTS                                         ║
╚══════════════════════════════════════════════════════════╝

✅ All tests passing (634/634)

❌ Coverage Report
  Statements:   72.4% (964 / 1,331) ⚠️ Below 80% threshold
  Branches:     68.2% (348 / 510)   ⚠️ Below 80% threshold
  Functions:    75.1% (189 / 252)   ⚠️ Below 80% threshold
  Lines:        72.8% (919 / 1,263) ⚠️ Below 80% threshold

📉 Uncovered Files
  1. server/services/payment-processor.js    45% coverage
  2. server/utils/email-sender.js            23% coverage
  3. server/middleware/rate-limiter.js       38% coverage
  4. frontend/components/AdminPanel.js       51% coverage

🎯 Action Required
  Coverage is below 80% threshold.

  Recommendations:
  1. Add unit tests for payment-processor.js
  2. Add tests for email-sender.js
  3. Test rate-limiter edge cases
  4. Add component tests for AdminPanel

  Estimated effort: 4-6 hours to reach 80%

📂 Coverage Report: file:///path/to/coverage/index.html
```

---

## Integration with @TestAgent

When `/test-run` completes, it reports findings to @chief:

**If all tests pass + coverage ≥80%:**
```
@chief

Test run completed successfully.
✅ 634 tests passing
✅ 94.2% coverage (above 80% threshold)
⏱️  3m 12s execution time

Ready for deployment.
```

**If tests fail:**
```
@chief

Test run failed - deployment blocked.
❌ 3 tests failing
📉 Coverage: 91.2% (down 3% from baseline)

Failures require attention:
1. UserService.updateProfile - validation missing
2. OrderController.cancelOrder - status not updated
3. Checkout E2E - payment button timeout

Spawning @TestAgent to investigate and fix.
```

**If coverage below threshold:**
```
@chief

All tests passing but coverage insufficient.
✅ 634 tests passing
❌ Coverage: 72.4% (below 80% threshold)

Uncovered critical files:
- payment-processor.js (45%)
- email-sender.js (23%)

Spawning @TestAgent to add missing test coverage.
```

---

## Coverage Thresholds

**Minimum acceptable coverage:** 80%

**Target coverage by file type:**
- **Business logic:** 90%+ (services, controllers, models)
- **Utilities:** 85%+ (helpers, formatters, validators)
- **Components:** 75%+ (UI components)
- **Integration:** 70%+ (full flows)

**Exceptions (may have lower coverage):**
- Configuration files
- Type definitions
- Generated code
- Third-party adapters

---

## Pre-Commit Hook Integration

Add `/test-run` to your pre-commit hook to catch issues early:

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "Running tests before commit..."
/test-run --unit-only

if [ $? -ne 0 ]; then
  echo "❌ Tests failed - commit blocked"
  echo "Fix failing tests before committing"
  exit 1
fi

echo "✅ Tests passed - proceeding with commit"
exit 0
```

---

## CI/CD Integration

**GitHub Actions:**
```yaml
name: Test Suite
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: /test-run --coverage
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
```

**GitLab CI:**
```yaml
test:
  script:
    - /test-run --coverage
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

---

## Troubleshooting

### Tests Not Found

**Issue:** "No tests found"

**Solution:**
```bash
# Ensure test files follow naming convention
# Jest/Vitest: *.test.js, *.spec.js
# Pytest: test_*.py, *_test.py
# RSpec: *_spec.rb

# Check test directory structure
ls -la tests/
ls -la __tests__/
ls -la spec/
```

### Coverage Not Generated

**Issue:** "Coverage report missing"

**Solution:**
```bash
# Install coverage tools
npm install --save-dev jest @coverage  # Node.js
pip install pytest-cov                # Python
gem install simplecov                 # Ruby

# Ensure coverage config exists
# jest.config.js
module.exports = {
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'html', 'lcov']
};
```

### Slow Test Execution

**Issue:** Tests take too long (>10 minutes)

**Solution:**
```bash
# Run tests in parallel
npm test -- --maxWorkers=4        # Jest
pytest -n 4                       # pytest with pytest-xdist
bundle exec rspec --parallel      # RSpec

# Skip slow E2E tests in development
/test-run --unit-only
```

### Flaky Tests

**Issue:** Tests randomly fail/pass

**Solution:**
```bash
# Run tests multiple times to identify flakes
npm test -- --runInBand  # Disable parallelism
pytest --count=10         # Run 10 times

# Common causes:
# - Race conditions (async timing)
# - Shared state between tests
# - External dependencies (databases, APIs)
# - Time-dependent logic

# Fix: Isolate tests, use mocks, reset state
```

---

## Best Practices

### ✅ DO:
- Run `/test-run` before every commit
- Maintain ≥80% coverage
- Fix failing tests immediately
- Keep tests fast (<5 minutes total)
- Use test doubles (mocks, stubs) for external dependencies
- Write tests before or alongside code (TDD)

### ❌ DON'T:
- Skip tests to "move faster"
- Commit failing tests
- Ignore coverage drops
- Test implementation details (test behavior)
- Write brittle tests that break on refactoring
- Mock everything (integration tests need real interactions)

---

## Reports to @chief

Every `/test-run` execution creates a report in:
```
thoughts/shared/test-reports/test-run-YYYY-MM-DD-HH-MM-SS.json
```

**Report structure:**
```json
{
  "timestamp": "2026-01-10T15:30:45Z",
  "summary": {
    "total": 634,
    "passed": 631,
    "failed": 3,
    "skipped": 0,
    "duration_ms": 192340
  },
  "coverage": {
    "statements": 91.2,
    "branches": 87.1,
    "functions": 90.5,
    "lines": 91.0,
    "threshold_met": false
  },
  "failures": [
    {
      "test": "UserService.updateProfile",
      "file": "tests/unit/user-service.test.js",
      "line": 45,
      "error": "Expected email to be validated"
    }
  ],
  "slow_tests": [
    {
      "name": "checkout integration test",
      "duration_ms": 3200,
      "file": "tests/integration/checkout.test.js"
    }
  ]
}
```

@chief uses this report to:
- Block deployment if tests fail
- Spawn @TestAgent to fix failures
- Track coverage trends over time
- Identify slow tests for optimization

---

## Success Criteria

A successful `/test-run` execution means:

✅ All tests passing (0 failures)
✅ Coverage ≥80% (statements, branches, functions, lines)
✅ No critical test execution errors
✅ Execution time <10 minutes (optimize if slower)
✅ No new flaky tests introduced

**Only when ALL criteria met:** Deployment approved

---

## Example: Full Test Run Output

```bash
$ /test-run

🧪 Legendary Team Test Runner
────────────────────────────────────────────

Detecting project type... Node.js (Jest)
Running test suite with coverage...

 PASS  tests/unit/user-service.test.js
 PASS  tests/unit/order-controller.test.js
 PASS  tests/unit/payment-processor.test.js
 PASS  tests/integration/api.test.js
 PASS  tests/integration/database.test.js
 PASS  tests/e2e/checkout.spec.js

Test Suites: 6 passed, 6 total
Tests:       634 passed, 634 total
Snapshots:   12 passed, 12 total
Time:        192.34s

────────────────────────────────────────────
Coverage Report
────────────────────────────────────────────
File                  | % Stmts | % Branch | % Funcs | % Lines
──────────────────────|─────────|──────────|─────────|─────────
All files             |   94.2  |    89.5  |   92.8  |   94.1
 server/
  services/           |   96.8  |    92.1  |   95.3  |   96.5
  controllers/        |   93.4  |    88.2  |   91.7  |   93.1
  utils/              |   90.2  |    85.4  |   89.1  |   90.5
 frontend/
  components/         |   92.1  |    87.3  |   90.2  |   92.4
  hooks/              |   95.6  |    91.8  |   94.1  |   95.7

✅ Coverage threshold met (>80%)

────────────────────────────────────────────

╔══════════════════════════════════════════════════════════╗
║ ✅ ALL TESTS PASSED                                      ║
╚══════════════════════════════════════════════════════════╝

Test Summary:     634 passed, 0 failed
Coverage:         94.2% (above 80% threshold)
Execution Time:   3m 12s
Status:           READY FOR DEPLOYMENT

📊 Coverage report: file:///coverage/index.html

Reporting results to @chief...
✅ Report saved: thoughts/shared/test-reports/test-run-2026-01-10-15-30-45.json
```

---

**Remember:** Tests are not a checkbox - they're your safety net. Keep them green. 🟢
