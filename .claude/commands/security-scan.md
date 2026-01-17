# Security Scan

Run comprehensive security vulnerability scans and report findings to @chief.

---

## What This Command Does

Automatically runs security scans across multiple layers:
1. **Dependency vulnerabilities** - Known CVEs in packages
2. **Code vulnerabilities** - Static analysis for security issues
3. **Secrets detection** - Exposed API keys, passwords, tokens
4. **Container security** - Docker image vulnerabilities (if applicable)
5. **License compliance** - Check for restrictive licenses
6. **Security headers** - HTTP security header validation (if web app)

**Then reports all findings to @SecurityAgent and @chief for review.**

---

## Usage

```bash
/security-scan
```

**Optional flags:**
```bash
/security-scan --fix              # Auto-fix vulnerabilities where safe
/security-scan --dependencies-only # Only scan packages
/security-scan --secrets-only      # Only check for exposed secrets
/security-scan --severity=high     # Only show high/critical issues
/security-scan --json              # Output JSON for CI/CD
```

---

## Implementation

This command auto-detects your project and runs appropriate security tools.

### Auto-Detection & Tool Selection

**Node.js/JavaScript Projects:**
```bash
if [ -f "package.json" ]; then
  # npm audit (built-in)
  npm audit --json > npm-audit.json

  # Snyk (if installed)
  if command -v snyk &> /dev/null; then
    snyk test --json > snyk-results.json
  fi

  # retire.js for outdated libraries
  if command -v retire &> /dev/null; then
    retire --json > retire-results.json
  fi
fi
```

**Python Projects:**
```bash
if [ -f "requirements.txt" ] || [ -f "Pipfile" ] || [ -f "pyproject.toml" ]; then
  # safety for known vulnerabilities
  if command -v safety &> /dev/null; then
    safety check --json > safety-results.json
  fi

  # bandit for code security issues
  if command -v bandit &> /dev/null; then
    bandit -r . -f json -o bandit-results.json
  fi

  # pip-audit
  if command -v pip-audit &> /dev/null; then
    pip-audit --format json > pip-audit.json
  fi
fi
```

**Ruby Projects:**
```bash
if [ -f "Gemfile" ]; then
  # bundler-audit
  if command -v bundle-audit &> /dev/null; then
    bundle-audit check --format json > bundler-audit.json
  fi

  # brakeman for Rails security
  if command -v brakeman &> /dev/null; then
    brakeman -f json -o brakeman-results.json
  fi
fi
```

**Go Projects:**
```bash
if [ -f "go.mod" ]; then
  # gosec for security issues
  if command -v gosec &> /dev/null; then
    gosec -fmt json -out gosec-results.json ./...
  fi

  # nancy for dependency vulnerabilities
  if command -v nancy &> /dev/null; then
    go list -json -m all | nancy sleuth -o json > nancy-results.json
  fi
fi
```

**Docker/Container Projects:**
```bash
if [ -f "Dockerfile" ]; then
  # trivy for container scanning
  if command -v trivy &> /dev/null; then
    trivy image --format json -o trivy-results.json $(docker images -q | head -1)
  fi

  # grype
  if command -v grype &> /dev/null; then
    grype -o json > grype-results.json
  fi
fi
```

**Secrets Detection (All Projects):**
```bash
# gitleaks for exposed secrets
if command -v gitleaks &> /dev/null; then
  gitleaks detect --report-path gitleaks-report.json
fi

# truffleHog
if command -v trufflehog &> /dev/null; then
  trufflehog filesystem . --json > trufflehog-results.json
fi
```

---

## Output Format

### Clean Scan (No Vulnerabilities)

```
╔══════════════════════════════════════════════════════════╗
║ SECURITY SCAN RESULTS                                    ║
╚══════════════════════════════════════════════════════════╝

✅ Dependency Scan
  Scanned: 487 packages
  Vulnerabilities: 0 critical, 0 high, 0 medium, 0 low
  Status: CLEAN

✅ Code Analysis
  Files scanned: 234
  Security issues: 0
  Status: CLEAN

✅ Secrets Detection
  Commits scanned: 1,245
  Secrets found: 0
  Status: CLEAN

✅ License Compliance
  Packages checked: 487
  Incompatible licenses: 0
  Status: COMPLIANT

✅ Container Security
  Image: myapp:latest
  Vulnerabilities: 0 critical, 0 high
  Status: CLEAN

────────────────────────────────────────────

╔══════════════════════════════════════════════════════════╗
║ ✅ ALL SECURITY CHECKS PASSED                            ║
╚══════════════════════════════════════════════════════════╝

Summary:         0 vulnerabilities found
Risk Level:      NONE
Status:          READY FOR DEPLOYMENT

📊 Detailed report: thoughts/shared/security-reports/scan-2026-01-10-15-30-45.json
```

### Vulnerabilities Found

```
╔══════════════════════════════════════════════════════════╗
║ SECURITY SCAN RESULTS                                    ║
╚══════════════════════════════════════════════════════════╝

❌ Dependency Scan
  Scanned: 487 packages
  Vulnerabilities: 2 critical, 5 high, 12 medium, 8 low
  Status: VULNERABILITIES FOUND

🔴 Critical Vulnerabilities (2)

1. lodash (4.17.15)
   CVE: CVE-2021-23337
   Severity: CRITICAL (CVSS 9.8)
   Issue: Command injection in template
   Affected: lodash < 4.17.21
   Fix: npm install lodash@4.17.21
   Exploitable: Yes (Remote Code Execution)

2. axios (0.21.0)
   CVE: CVE-2021-3749
   Severity: CRITICAL (CVSS 9.1)
   Issue: Server-Side Request Forgery (SSRF)
   Affected: axios < 0.21.4
   Fix: npm install axios@0.21.4
   Exploitable: Yes (SSRF attack vector)

🟠 High Vulnerabilities (5)

3. express (4.16.0)
   CVE: CVE-2022-24999
   Severity: HIGH (CVSS 7.5)
   Issue: Open redirect vulnerability
   Affected: express < 4.17.3
   Fix: npm install express@4.17.3
   Exploitable: Yes (Phishing vector)

4. jsonwebtoken (8.5.0)
   CVE: CVE-2022-23529
   Severity: HIGH (CVSS 7.6)
   Issue: Algorithm confusion vulnerability
   Affected: jsonwebtoken < 9.0.0
   Fix: npm install jsonwebtoken@9.0.0
   Exploitable: Yes (Authentication bypass)

5. validator (10.8.0)
   CVE: CVE-2021-3765
   Severity: HIGH (CVSS 7.3)
   Issue: ReDoS in email validation
   Affected: validator < 13.6.0
   Fix: npm install validator@13.6.0
   Exploitable: Yes (DoS attack)

... (showing 5/5 high vulnerabilities)

⚠️  Code Analysis
  Files scanned: 234
  Security issues: 3

1. Hardcoded Secret (HIGH)
   File: server/config/database.js:12
   Issue: Database password in source code
   Code: const password = "SuperSecret123"
   Fix: Use environment variable (process.env.DB_PASSWORD)

2. SQL Injection Risk (MEDIUM)
   File: server/routes/users.js:45
   Issue: Unsanitized user input in SQL query
   Code: db.query(`SELECT * FROM users WHERE id = ${req.params.id}`)
   Fix: Use parameterized query

3. Weak Crypto (MEDIUM)
   File: server/utils/encryption.js:23
   Issue: Using MD5 for password hashing
   Code: crypto.createHash('md5').update(password)
   Fix: Use bcrypt or argon2

❌ Secrets Detection
  Commits scanned: 1,245
  Secrets found: 2

1. AWS Access Key (CRITICAL)
   File: .env.example:15
   Key: AKIAIOSFODNN7EXAMPLE
   Exposed: 3 commits ago (2026-01-07)
   Action: ROTATE IMMEDIATELY

2. GitHub Token (HIGH)
   File: scripts/deploy.sh:8
   Token: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Exposed: 12 commits ago (2025-12-28)
   Action: Revoke and regenerate

✅ License Compliance
  Packages checked: 487
  Incompatible licenses: 0
  Status: COMPLIANT

✅ Container Security
  Image: myapp:latest
  Vulnerabilities: 0 critical, 0 high
  Status: CLEAN

────────────────────────────────────────────

╔══════════════════════════════════════════════════════════╗
║ ❌ DEPLOYMENT BLOCKED - CRITICAL VULNERABILITIES         ║
╚══════════════════════════════════════════════════════════╝

Summary:         27 vulnerabilities (2 critical, 5 high, 12 medium, 8 low)
Secrets Exposed: 2 (1 critical, 1 high)
Risk Level:      CRITICAL
Status:          MUST FIX BEFORE DEPLOYMENT

🎯 Immediate Actions Required:
  1. Rotate exposed AWS key (CRITICAL)
  2. Update lodash to 4.17.21
  3. Update axios to 0.21.4
  4. Remove hardcoded database password
  5. Revoke GitHub token

Quick fix available:
  npm audit fix --force

⚠️  Warning: --force may introduce breaking changes
    Review changes before committing

📊 Detailed report: thoughts/shared/security-reports/scan-2026-01-10-15-30-45.json
```

---

## Severity Levels

| Severity | CVSS Score | Impact | Action Required |
|----------|------------|--------|-----------------|
| **CRITICAL** | 9.0-10.0 | Remote code execution, full system compromise | **IMMEDIATE FIX** - Block deployment |
| **HIGH** | 7.0-8.9 | Data breach, authentication bypass | **FIX ASAP** - Urgent priority |
| **MEDIUM** | 4.0-6.9 | Information disclosure, limited impact | **FIX SOON** - Schedule fix |
| **LOW** | 0.1-3.9 | Minor issues, difficult to exploit | **BACKLOG** - Fix when possible |

---

## Auto-Fix Capabilities

When safe to do so, `/security-scan --fix` can automatically remediate:

### ✅ Safe Auto-Fixes:
- Update dependencies to patched versions (minor/patch updates)
- Remove unused dependencies
- Update lock files
- Fix insecure package configurations

### ⚠️  Manual Review Required:
- Major version updates (may have breaking changes)
- Hardcoded secrets (need to be moved to env vars)
- SQL injection fixes (require code changes)
- Algorithm changes (may break existing functionality)

**Example auto-fix:**
```bash
$ /security-scan --fix

🔧 Auto-fixing safe vulnerabilities...

✅ Updated lodash: 4.17.15 → 4.17.21
✅ Updated axios: 0.21.0 → 0.21.4
✅ Updated express: 4.16.0 → 4.17.3
⚠️  jsonwebtoken requires manual update (breaking changes)
⚠️  Hardcoded secrets require manual removal

Fixed: 3 vulnerabilities
Remaining: 4 vulnerabilities (manual fix required)

Run /test-run to ensure nothing broke
```

---

## Integration with @SecurityAgent

When `/security-scan` detects vulnerabilities, it reports to @SecurityAgent:

**Critical/High Vulnerabilities:**
```
@SecurityAgent

Security scan detected CRITICAL vulnerabilities.
Deployment blocked until resolved.

Critical Issues (2):
1. lodash CVE-2021-23337 (RCE vulnerability)
2. AWS key exposed in .env.example

High Issues (5):
3. express open redirect
4. jsonwebtoken auth bypass
... (full list)

Actions:
1. Rotate AWS credentials immediately
2. Update vulnerable packages
3. Review and approve changes

Full report: thoughts/shared/security-reports/scan-2026-01-10-15-30-45.json
```

**Clean Scan:**
```
@chief

Security scan completed - all clear.
✅ 0 vulnerabilities
✅ 0 exposed secrets
✅ License compliance verified

Ready for deployment.
```

---

## Pre-Deployment Checklist

Before any production deployment, `/security-scan` must verify:

- ✅ No CRITICAL vulnerabilities
- ✅ No HIGH vulnerabilities (or approved exceptions)
- ✅ No exposed secrets (API keys, passwords, tokens)
- ✅ All dependencies up to date
- ✅ No incompatible licenses
- ✅ Container images scanned (if applicable)
- ✅ Security headers configured (if web app)

**If ANY critical/high issue found:** Deployment automatically blocked

---

## Tools Installation

### Node.js/JavaScript

```bash
# npm audit (built-in with npm 6+)
npm audit

# Snyk (recommended)
npm install -g snyk
snyk auth

# retire.js
npm install -g retire

# gitleaks (secrets)
brew install gitleaks  # macOS
# or download from https://github.com/zricethezav/gitleaks
```

### Python

```bash
# safety
pip install safety

# bandit
pip install bandit

# pip-audit
pip install pip-audit

# semgrep (advanced)
pip install semgrep
```

### Ruby

```bash
# bundler-audit
gem install bundler-audit

# brakeman (Rails)
gem install brakeman
```

### Go

```bash
# gosec
go install github.com/securego/gosec/v2/cmd/gosec@latest

# nancy
go install github.com/sonatype-nexus-community/nancy@latest
```

### Container Scanning

```bash
# trivy (recommended)
brew install aquasecurity/trivy/trivy  # macOS
# or: wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

# grype
brew tap anchore/grype && brew install grype
```

### Secrets Detection

```bash
# gitleaks
brew install gitleaks

# truffleHog
pip install truffleHog
```

---

## Security Report Format

Every scan creates a detailed JSON report:

```json
{
  "timestamp": "2026-01-10T15:30:45Z",
  "scan_type": "full",
  "summary": {
    "total_vulnerabilities": 27,
    "critical": 2,
    "high": 5,
    "medium": 12,
    "low": 8,
    "secrets_found": 2,
    "deployment_blocked": true
  },
  "dependencies": {
    "scanned": 487,
    "vulnerable": 19,
    "vulnerabilities": [
      {
        "package": "lodash",
        "version": "4.17.15",
        "severity": "critical",
        "cve": "CVE-2021-23337",
        "cvss": 9.8,
        "description": "Command injection in template",
        "fix_version": "4.17.21",
        "exploitable": true,
        "patch_available": true
      }
    ]
  },
  "code_analysis": {
    "files_scanned": 234,
    "issues_found": 3,
    "issues": [
      {
        "type": "hardcoded_secret",
        "severity": "high",
        "file": "server/config/database.js",
        "line": 12,
        "description": "Database password in source code",
        "recommendation": "Use environment variable"
      }
    ]
  },
  "secrets": {
    "commits_scanned": 1245,
    "secrets_found": 2,
    "findings": [
      {
        "type": "AWS Access Key",
        "severity": "critical",
        "file": ".env.example",
        "line": 15,
        "exposed_since": "2026-01-07",
        "action": "ROTATE IMMEDIATELY"
      }
    ]
  },
  "licenses": {
    "packages_checked": 487,
    "incompatible": 0,
    "status": "compliant"
  },
  "recommendations": [
    "Rotate exposed AWS credentials",
    "Update lodash to 4.17.21",
    "Update axios to 0.21.4",
    "Remove hardcoded database password",
    "Revoke GitHub token"
  ]
}
```

Saved to: `thoughts/shared/security-reports/scan-YYYY-MM-DD-HH-MM-SS.json`

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Security Scan
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for secrets scan

      - name: Run security scan
        run: /security-scan --json

      - name: Upload results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: security-scan-results.sarif

      - name: Block on critical
        run: |
          if grep -q '"critical": [1-9]' security-scan.json; then
            echo "❌ Critical vulnerabilities found - blocking deployment"
            exit 1
          fi
```

### GitLab CI

```yaml
security_scan:
  stage: test
  script:
    - /security-scan --json
  artifacts:
    reports:
      sast: security-scan-sast.json
      dependency_scanning: security-scan-deps.json
  allow_failure: false  # Block pipeline on vulnerabilities
```

---

## Common Vulnerabilities Detected

### 1. Dependency Vulnerabilities
- Outdated packages with known CVEs
- Transitive dependencies with vulnerabilities
- Unmaintained packages

**Fix:** Keep dependencies updated, use `npm audit fix`

### 2. Hardcoded Secrets
- API keys in source code
- Database passwords
- JWT secrets
- OAuth tokens

**Fix:** Use environment variables, secrets management (AWS Secrets Manager, HashiCorp Vault)

### 3. Injection Vulnerabilities
- SQL injection (unsanitized queries)
- Command injection
- LDAP injection
- NoSQL injection

**Fix:** Use parameterized queries, input validation, prepared statements

### 4. Weak Cryptography
- MD5/SHA1 for passwords
- Weak encryption algorithms
- Insufficient key lengths

**Fix:** Use bcrypt/argon2, AES-256, proper key management

### 5. Authentication Issues
- Missing authentication
- Weak password policies
- Insecure JWT handling
- Session fixation

**Fix:** Implement proper auth, strong password requirements, secure session management

### 6. Insecure Configurations
- Debug mode in production
- Verbose error messages
- Missing security headers
- CORS misconfiguration

**Fix:** Production-ready configs, proper CORS, security headers (CSP, HSTS, etc.)

---

## Exceptions and Whitelisting

For false positives or accepted risks, create `.securityignore`:

```
# .securityignore
# Format: <package>@<version> <reason>

lodash@4.17.15  # Breaking changes in 4.17.21, scheduled for v2.1.0
CVE-2021-23337  # False positive - not using template feature

# Secrets
.env.example    # Example file, not real credentials
```

**Note:** All exceptions require @SecurityAgent approval and documentation

---

## Security Scan Frequency

**Recommended schedule:**

- **Every commit:** Pre-commit hook (fast scan)
- **Every PR:** Full scan in CI/CD
- **Daily:** Scheduled scan (catch new CVEs)
- **Pre-deployment:** Mandatory full scan
- **Weekly:** Deep scan including containers

---

## Escalation Process

**Critical vulnerabilities:**
1. Scan detects critical vulnerability
2. Deployment automatically blocked
3. @SecurityAgent notified immediately
4. @chief escalates to human review
5. Emergency patch process initiated

**High vulnerabilities:**
1. Scan detects high vulnerability
2. Added to review queue (non-blocking for existing features)
3. @SecurityAgent creates fix plan
4. @chief schedules remediation
5. Fixed in next sprint

**Medium/Low vulnerabilities:**
1. Logged in security backlog
2. Reviewed during sprint planning
3. Fixed based on priority

---

## Best Practices

### ✅ DO:
- Run `/security-scan` before every deployment
- Fix critical/high vulnerabilities immediately
- Keep dependencies up to date
- Use environment variables for secrets
- Enable automated dependency updates (Dependabot, Renovate)
- Rotate credentials regularly

### ❌ DON'T:
- Ignore security warnings to "move faster"
- Commit secrets to version control
- Use `--force` without reviewing changes
- Whitelist vulnerabilities without @SecurityAgent approval
- Disable security scans in CI/CD

---

## Troubleshooting

### Issue: "npm audit found 0 vulnerabilities but Snyk found 15"

**Cause:** Different vulnerability databases

**Solution:** Trust the more comprehensive tool (Snyk) and investigate each finding

### Issue: "Too many false positives"

**Cause:** Overly sensitive rules, dev dependencies flagged

**Solution:**
```bash
# Scan production dependencies only
npm audit --production
# or
/security-scan --production-only
```

### Issue: "Scan is too slow (>10 minutes)"

**Cause:** Large dependency tree, container scanning

**Solution:**
```bash
# Skip container scan in development
/security-scan --skip-containers

# Dependencies only
/security-scan --dependencies-only
```

---

**Remember:** Security is not optional. Better to catch vulnerabilities now than in production. 🔒
