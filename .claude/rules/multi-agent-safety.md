# 🤝 Multi-Agent Safety Rules

## Purpose
Critical safety rules for parallel agent operation. These rules prevent agents from interfering with each other's work and ensure coordinated, non-destructive collaboration.

---

## File Operations

### 1. **Delete With Extreme Caution**
```markdown
# ✅ GOOD - Delete only files YOU made obsolete
@RefactorAgent: "My refactor moved auth logic from utils/auth.ts to services/auth.ts.
Deleting obsolete utils/auth.ts since I created this change."

# ❌ FORBIDDEN - Deleting files you didn't author
@RefactorAgent: "I see src/components/Header.tsx has type errors.
Deleting it to fix the build."
```

**Rule**: Delete unused or obsolete files ONLY when YOUR changes made them irrelevant. If unsure about other agents' in-flight work, STOP and coordinate with @chief.

---

### 2. **Never Delete to Fix Errors**
```markdown
# ❌ ABSOLUTELY FORBIDDEN
@TestAgent: "types/api.d.ts is causing lint failures.
Deleting to make tests pass."

# ✅ REQUIRED
@TestAgent: "types/api.d.ts is causing lint failures.
STOPPING to ask user - another agent may be editing this file.
Should I delete or wait for coordination?"
```

**Rule**: Before attempting to delete a file to resolve a local type/lint failure, STOP AND ASK THE USER. Other agents are often editing adjacent files; deleting their work to silence an error is NEVER acceptable without explicit approval.

---

### 3. **Never Edit Environment Files**
```markdown
# ❌ ABSOLUTELY FORBIDDEN
@DatabaseAgent: "Need to update DATABASE_URL in .env"
*edits .env*

# ✅ REQUIRED
@DatabaseAgent: "The database connection requires updating.
User: Please update DATABASE_URL in .env to: postgres://..."
```

**Rule**: NEVER edit `.env` or any environment variable files. Only the user may change them. This includes:
- `.env`
- `.env.local`
- `.env.development`
- `.env.production`
- Any file matching `*.env*` pattern
- `credentials.json`, `secrets.yaml`, etc.

---

### 4. **Coordinate Before Reverting**
```markdown
# ❌ FORBIDDEN - Unilateral revert
@SecurityAgent: "I don't like the changes in auth.ts.
Running: git restore src/auth.ts"

# ✅ REQUIRED - Coordinate first
@SecurityAgent: "I found issues in auth.ts changes by @DatabaseAgent.
@chief: Please coordinate - should we revert or fix forward?"
```

**Rule**: Never use `git restore` (or similar commands) to revert files you didn't author. Coordinate with @chief and other agents so their in-progress work stays intact.

---

### 5. **Moving/Renaming Is Allowed**
```markdown
# ✅ ALLOWED
@RefactorAgent: "Moving utils/helpers.ts to lib/helpers.ts for better organization."
git mv utils/helpers.ts lib/helpers.ts

# ✅ ALLOWED
@RefactorAgent: "Restoring accidentally deleted test file from git."
git restore tests/auth.test.ts
```

**Rule**: Moving, renaming, and restoring files is allowed when it's part of your assigned task.

---

## Destructive Operations

### 6. **Destructive Git Commands Are FORBIDDEN**
```markdown
# ❌ ABSOLUTELY FORBIDDEN without explicit user instruction:
git reset --hard
git clean -f
git checkout . (to discard all changes)
git restore . (to discard all changes)
git push --force
rm -rf
git rebase -i (interactive)

# ❌ FORBIDDEN - Guessing user intent
"The build is broken, let me reset to clean state..."
git reset --hard HEAD~5

# ✅ REQUIRED - Ask first
"The build is broken. Options:
1. I can try to fix the specific issue
2. You can run: git reset --hard HEAD~5
Which do you prefer?"
```

**Rule**: ABSOLUTELY NEVER run destructive git operations unless the user gives an explicit, written instruction in this conversation. Treat these commands as catastrophic; if you are even slightly unsure, STOP AND ASK before touching them.

---

### 7. **Never Amend Without Approval**
```markdown
# ❌ FORBIDDEN
git commit --amend -m "Updated message"

# ✅ REQUIRED
"Should I amend the previous commit or create a new one?
Amending will rewrite history."
*waits for explicit approval*
```

**Rule**: Never amend commits unless you have explicit written approval in the current conversation.

---

## Git Hygiene

### 8. **Always Check Status First**
```markdown
# ✅ REQUIRED before every commit
git status

# Check for:
- Untracked files that shouldn't be committed
- Modified files you didn't touch
- Staged files from other operations
```

**Rule**: Always double-check `git status` before any commit.

---

### 9. **Atomic Commits with Explicit Paths**
```markdown
# ❌ DISCOURAGED - Too broad
git add .
git commit -m "updates"

# ✅ REQUIRED - Explicit paths
git commit -m "feat(auth): add password reset" -- src/auth.ts src/auth.test.ts

# ✅ REQUIRED - For new files
git restore --staged :/ && \
git add "src/services/auth.ts" "src/services/auth.test.ts" && \
git commit -m "feat(auth): add service" -- src/services/auth.ts src/services/auth.test.ts
```

**Rule**: Keep commits atomic. Commit only the files you touched and list each path explicitly.

---

### 10. **Quote Special Characters in Paths**
```markdown
# ❌ WILL FAIL - Shell interprets brackets
git add src/app/[candidate]/page.tsx

# ✅ REQUIRED - Quote the path
git add "src/app/[candidate]/page.tsx"
git commit -m "feat: add candidate page" -- "src/app/[candidate]/page.tsx"

# Special characters that need quoting:
- [ ] (brackets)
- ( ) (parentheses)
- * (asterisk)
- ? (question mark)
- $ (dollar sign)
- spaces
```

**Rule**: Quote any git paths containing brackets, parentheses, or special characters so the shell does not treat them as globs or subshells.

---

### 11. **Non-Interactive Rebase**
```markdown
# ❌ WILL HANG - Opens editor
git rebase main

# ✅ REQUIRED - Prevent editor
GIT_EDITOR=: GIT_SEQUENCE_EDITOR=: git rebase main --no-edit

# Or export first:
export GIT_EDITOR=:
export GIT_SEQUENCE_EDITOR=:
git rebase main
```

**Rule**: When running `git rebase`, avoid opening editors. Export `GIT_EDITOR=:` and `GIT_SEQUENCE_EDITOR=:` (or pass `--no-edit`) so default messages are used automatically.

---

## Coordination Protocol

### 12. **When Uncertain, Coordinate**
```markdown
# ✅ REQUIRED - Escalate to @chief
@DatabaseAgent: "I see uncommitted changes in models/user.ts that I didn't make.
@chief: Another agent may be working here. Should I proceed or wait?"

# ✅ REQUIRED - Check with team
@UIAgent: "Build failing due to missing type in shared/types.ts.
Checking if @DatabaseAgent is updating this file before I touch it."
```

**Rule**: If a git operation leaves you unsure about other agents' in-flight work, STOP and coordinate with @chief instead of making assumptions.

---

### 13. **Respect Work Boundaries**
```markdown
# ✅ GOOD - Stay in your lane
@UIAgent works on: src/components/*, src/pages/*, src/styles/*
@DatabaseAgent works on: prisma/*, src/models/*, src/services/db*
@TestAgent works on: tests/*, *.test.ts, *.spec.ts

# ❌ BAD - Crossing boundaries without coordination
@UIAgent editing prisma/schema.prisma without @DatabaseAgent awareness
```

**Rule**: Agents should primarily work in their domain. Cross-domain changes require coordination with the domain owner.

---

## Emergency Situations

### 14. **Build Failures from Other Agents**
```markdown
# ❌ FORBIDDEN
"Build failing due to @DatabaseAgent's changes. Reverting their work."

# ✅ REQUIRED
"Build failing due to @DatabaseAgent's changes.
Options:
1. Wait for @DatabaseAgent to complete and fix
2. Coordinate fix together
3. Ask user for guidance

@chief: Requesting coordination."
```

**Rule**: Build failures caused by other agents' in-progress work are NOT grounds for reverting. Coordinate instead.

---

### 15. **Merge Conflicts with Other Agents**
```markdown
# ✅ REQUIRED
1. Identify which agent made conflicting changes
2. Report to @chief
3. Coordinate resolution together
4. Never unilaterally choose "theirs" or "ours" for files you didn't author
```

**Rule**: Merge conflicts involving other agents' work require coordination. Don't resolve unilaterally.

---

## Checklist Before File Operations

Before deleting, reverting, or significantly modifying files:
- [ ] Did I create this file/change?
- [ ] Is another agent currently working on this?
- [ ] Will this affect other agents' in-flight work?
- [ ] Do I have explicit user approval for destructive operations?
- [ ] Have I coordinated with @chief if uncertain?

---

**REMEMBER**: In a multi-agent system, coordination prevents chaos. When in doubt, ask.

**Last Updated**: 2026-02-07
**Maintained By**: Legendary Team Agents
