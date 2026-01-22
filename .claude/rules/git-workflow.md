# 🔀 Git Workflow Rules

## Purpose
Mandatory Git workflow and commit practices for all Legendary Team agents.

---

## Branch Strategy

### 1. **Main Branch is Protected**
```bash
# ❌ FORBIDDEN
git checkout main
git commit -m "changes"
git push origin main

# ✅ REQUIRED
git checkout -b feature/my-feature
git commit -m "feat: add new feature"
git push origin feature/my-feature
# Then create PR
```

**Rule**: NEVER push directly to `main` branch. Always use feature branches and PRs.

---

### 2. **Branch Naming Convention**
```bash
# ✅ REQUIRED - Use consistent naming
feature/user-authentication
fix/login-bug
refactor/api-cleanup
docs/update-readme
test/add-unit-tests
chore/update-dependencies

# ❌ FORBIDDEN
my-branch
temp
test123
```

**Rule**: Branch names MUST follow pattern: `type/description`

**Types**:
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation
- `test/` - Test additions
- `chore/` - Maintenance tasks

---

### 3. **Create Feature Branch from Latest Main**
```bash
# ✅ REQUIRED
git checkout main
git pull origin main
git checkout -b feature/new-feature

# ❌ FORBIDDEN - Creating branch from outdated main
git checkout -b feature/new-feature  # Without pulling latest
```

**Rule**: Always create feature branches from up-to-date `main`.

---

## Commit Practices

### 4. **Conventional Commits**
```bash
# ✅ REQUIRED format:
# type(scope): subject
#
# body
#
# footer

# Examples:
git commit -m "feat(auth): add OAuth2 authentication

Implemented Google OAuth2 integration with JWT tokens.
Added login and logout endpoints.

Closes #123"

git commit -m "fix(api): handle null response from user service

Added null check to prevent crash when user service returns null.

Fixes #456"

git commit -m "refactor(db): optimize user query performance

Replaced N+1 queries with single JOIN query.
Reduced response time from 500ms to 50ms."
```

**Required Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Code style (formatting, no logic change)
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance (deps, build, etc.)
- `perf` - Performance improvement

**Rule**: All commits MUST follow Conventional Commits format.

---

### 5. **Atomic Commits**
```bash
# ❌ FORBIDDEN - Multiple unrelated changes
git add .
git commit -m "fix bugs and add new feature and update docs"

# ✅ REQUIRED - Separate commits for separate changes
git add src/auth.ts
git commit -m "fix(auth): handle expired tokens"

git add src/profile.ts
git commit -m "feat(profile): add profile picture upload"

git add README.md
git commit -m "docs: update authentication section"
```

**Rule**: Each commit should contain ONE logical change.

---

### 6. **Meaningful Commit Messages**
```bash
# ❌ FORBIDDEN
git commit -m "fix"
git commit -m "updates"
git commit -m "wip"
git commit -m "asdf"

# ✅ REQUIRED
git commit -m "fix(auth): prevent token replay attacks"
git commit -m "feat(api): add pagination to user list endpoint"
git commit -m "refactor(db): extract connection pooling to separate module"
```

**Rule**: Commit messages MUST be descriptive and explain WHAT and WHY.

---

### 7. **Commit Message Length**
```bash
# ✅ REQUIRED
# Subject: ≤ 72 characters
# Body: Wrapped at 72 characters

git commit -m "feat(auth): add two-factor authentication

Implemented TOTP-based 2FA using speakeasy library.
Users can enable 2FA in account settings.
Backup codes are generated and can be downloaded.

Closes #789"
```

**Rule**: Subject line ≤ 72 chars. Body wrapped at 72 chars.

---

### 8. **Commit Frequency**
```bash
# ✅ GOOD - Commit after completing a logical unit
git add src/auth.ts tests/auth.test.ts
git commit -m "feat(auth): add password reset functionality"

# ❌ BAD - Committing every line change
git commit -m "add import"
git commit -m "add function"
git commit -m "fix typo"

# ❌ BAD - Committing at end of day with everything
git add .
git commit -m "day's work"
```

**Rule**: Commit when you complete a logical unit of work (feature, fix, refactor).

---

## Pull Requests

### 9. **Create PR Early**
```bash
# ✅ REQUIRED - Create draft PR when starting work
git push origin feature/my-feature
# Create draft PR on GitHub

# Work on feature...
git commit -m "feat: implement core functionality"
git push

# When ready
# Convert to ready for review
```

**Rule**: Create draft PR early to show progress. Convert to "Ready for Review" when done.

---

### 10. **PR Title and Description**
```markdown
## ✅ REQUIRED PR format:

### Title:
feat(auth): Add two-factor authentication

### Description:
## Summary
Implemented TOTP-based 2FA for enhanced security.

## Changes
- Added 2FA setup flow in user settings
- Implemented TOTP verification using speakeasy
- Generated and stored backup codes
- Added 2FA requirement for sensitive operations

## Testing
- [ ] Unit tests added for 2FA logic
- [ ] Integration tests for setup flow
- [ ] Manual testing on staging
- [ ] Tested backup code recovery

## Screenshots
[Attach screenshots if UI changes]

## Related Issues
Closes #789

---

## ❌ FORBIDDEN:
### Title: "updates"
### Description: "made some changes"
```

**Rule**: PRs MUST have descriptive title and comprehensive description.

---

### 11. **PR Size**
```bash
# ✅ GOOD - Small, focused PR
# Changed files: 5
# Lines changed: +150 -50

# ⚠️ ACCEPTABLE - Medium PR with good reason
# Changed files: 15
# Lines changed: +500 -200

# ❌ BAD - Large, unfocused PR
# Changed files: 50
# Lines changed: +2000 -1000
```

**Rule**: PRs SHOULD be small (< 400 lines changed). Break large features into multiple PRs.

---

### 12. **Self-Review Before Requesting Review**
```markdown
# ✅ REQUIRED - Checklist before requesting review:
- [ ] Code follows style guide
- [ ] All tests pass
- [ ] Test coverage ≥ 80%
- [ ] No console.logs or debug code
- [ ] No commented-out code
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] PR description is complete
```

**Rule**: Self-review and complete checklist BEFORE requesting review.

---

### 13. **Respond to Review Comments**
```markdown
# ✅ REQUIRED - Respond to each comment:

Reviewer: "This function is too long. Can we break it down?"
You: "Good point! I've extracted the validation logic into a separate
function. See commit abc123."

Reviewer: "What happens if the API returns null?"
You: "Added null check and error handling. Updated tests to cover this case."

# Mark conversations as "Resolved" after addressing
```

**Rule**: Respond to ALL review comments. Mark as resolved after addressing.

---

## Merging

### 14. **Squash Commits When Merging**
```bash
# ✅ REQUIRED - Squash merge for clean history
# Before merge:
- feat: add login endpoint
- fix: typo in login
- fix: add validation
- refactor: improve error handling
- fix: another typo

# After merge (single commit):
- feat(auth): add login endpoint with validation and error handling

# ❌ FORBIDDEN - Merge commit with messy history
# Creates merge commit with all intermediate commits
```

**Rule**: Use "Squash and Merge" for clean Git history (unless preserving history is important).

---

### 15. **Delete Branch After Merge**
```bash
# ✅ REQUIRED
# After PR is merged:
git checkout main
git pull origin main
git branch -d feature/my-feature  # Delete local branch
# Delete remote branch on GitHub
```

**Rule**: Delete feature branches after merging.

---

## Conflict Resolution

### 16. **Resolve Conflicts Promptly**
```bash
# ✅ REQUIRED - When conflicts occur:

# 1. Pull latest main
git checkout main
git pull origin main

# 2. Merge main into your branch
git checkout feature/my-feature
git merge main

# 3. Resolve conflicts
# Edit conflicted files
git add resolved-file.ts

# 4. Commit merge
git commit -m "chore: resolve merge conflicts with main"

# 5. Push
git push origin feature/my-feature
```

**Rule**: Resolve merge conflicts as soon as they occur.

---

### 17. **Never Force Push to Shared Branches**
```bash
# ❌ FORBIDDEN on shared branches
git push --force origin main
git push -f origin develop

# ✅ ACCEPTABLE on your own feature branch (with caution)
git push --force origin feature/my-feature

# ✅ SAFER - Force push with lease
git push --force-with-lease origin feature/my-feature
```

**Rule**: NEVER force push to `main` or shared branches. Use `--force-with-lease` if you must force push your feature branch.

---

## Collaboration

### 18. **Keep Feature Branch Updated**
```bash
# ✅ REQUIRED - Regularly sync with main
git checkout main
git pull origin main
git checkout feature/my-feature
git merge main
git push origin feature/my-feature

# Do this at least daily for long-running branches
```

**Rule**: Keep feature branches up-to-date with `main` to avoid large conflicts.

---

### 19. **Communicate Major Changes**
```bash
# ✅ REQUIRED - Before making breaking changes:
# 1. Create RFC (Request for Comments) issue
# 2. Discuss with team
# 3. Get approval
# 4. Make changes
# 5. Document migration guide
```

**Rule**: Discuss breaking changes with team BEFORE implementing.

---

## Git Hygiene

### 20. **Don't Commit Sensitive Data**
```bash
# ❌ FORBIDDEN - Never commit:
# - .env files with secrets
# - API keys, tokens, passwords
# - Private keys
# - credentials.json
# - Database dumps with real data

# ✅ REQUIRED - Use .gitignore
.env
.env.local
*.key
*.pem
credentials.json
secrets/
```

**Rule**: NEVER commit secrets. Use `.gitignore` and environment variables.

---

### 21. **Don't Commit Generated Files**
```bash
# ❌ FORBIDDEN - Don't commit:
# - node_modules/
# - dist/
# - build/
# - .DS_Store
# - *.log

# ✅ REQUIRED - Add to .gitignore
node_modules/
dist/
build/
.DS_Store
*.log
coverage/
```

**Rule**: Don't commit build artifacts or dependencies.

---

### 22. **Write Good .gitignore**
```bash
# ✅ REQUIRED .gitignore structure:

# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
*.js.map

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Test coverage
coverage/
.nyc_output/

# Temp files
*.tmp
.cache/
```

**Rule**: Maintain comprehensive `.gitignore`.

---

## Git Commands Reference

### Essential Commands
```bash
# Status
git status

# Stage changes
git add <file>
git add .

# Commit
git commit -m "type(scope): message"

# Push
git push origin <branch-name>

# Pull
git pull origin main

# Create branch
git checkout -b feature/name

# Switch branch
git checkout main

# Delete branch
git branch -d feature/name

# View log
git log --oneline
git log --graph --oneline --all

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard changes
git checkout -- <file>
git restore <file>

# Stash changes
git stash
git stash pop
```

---

## Pre-Commit Checklist

**Before committing, verify:**
- [ ] Code compiles/runs without errors
- [ ] All tests pass (`npm test`)
- [ ] Linter passes (`npm run lint`)
- [ ] No console.logs or debug code
- [ ] No commented-out code
- [ ] No secrets or sensitive data
- [ ] Commit message follows convention
- [ ] Changes are atomic (one logical change)

---

**REMEMBER**: Good Git practices make collaboration easier and history clearer.

**Last Updated**: 2026-01-22
**Maintained By**: Legendary Team Agents
