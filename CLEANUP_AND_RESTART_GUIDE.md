# Legendary Team - Clean Up and Restart Guide

## Current Situation
- You ran setup from **wrong location**: `projectroot/LegendaryTeam_For_Claude/`
- You have TWO `.claude/` directories (conflict)
- Database was created in wrong location
- Need to start fresh from `projectroot/`

---

## Step 1: Remove Incorrect Setup

```bash
# Navigate to your project root
cd /path/to/your/projectroot/

# Remove the entire LegendaryTeam_For_Claude folder
rm -rf LegendaryTeam_For_Claude/

# If you have an old .claude/ directory at project root, decide:
# Option A: Keep it (if it has your existing setup)
# Option B: Remove it (if starting completely fresh)
# rm -rf .claude/  # Only if starting completely fresh
```

---

## Step 2: Clone Legendary Team to Project Root

```bash
# Still in projectroot/
git clone https://github.com/RegardV/LegendaryTeam_For_Claude.git legendary-temp

# Move all contents from legendary-temp to project root
cp -r legendary-temp/.claude ./
cp legendary-temp/RunThisFirst.sh ./
cp -r legendary-temp/scripts ./

# Optional: Copy other files you need
cp legendary-temp/README.md ./LEGENDARY_TEAM_README.md
cp legendary-temp/Orchestration\ SOP.md ./

# Remove the temp clone folder
rm -rf legendary-temp/
```

**Alternative: If you want to keep LegendaryTeam_For_Claude as reference**
```bash
# Just copy the .claude folder to project root
cp -r LegendaryTeam_For_Claude/.claude ./
cp LegendaryTeam_For_Claude/RunThisFirst.sh ./
cp -r LegendaryTeam_For_Claude/scripts ./
```

---

## Step 3: Verify Directory Structure

Your `projectroot/` should now look like:

```
projectroot/
├── .claude/                    # ✅ Legendary Team configuration
│   ├── agents/                 # 14 AI agents
│   ├── commands/               # 10 commands
│   ├── skills/                 # 6 skill files
│   ├── rules/                  # 6 rule files
│   ├── hooks/
│   └── ...
├── scripts/                    # ✅ Legendary Team scripts
│   └── init-artifact-index.sh
├── RunThisFirst.sh             # ✅ Setup script
├── your-app-code/              # ✅ Your actual project files
├── package.json                # ✅ Your project files
└── ...                         # ✅ All your other project files
```

**Key Point**: `.claude/` is now in the SAME directory as your project files!

---

## Step 4: Run Setup Scripts (From Correct Location)

```bash
# Make sure you're in projectroot/
pwd  # Should show /path/to/your/projectroot

# Run first-time setup
bash RunThisFirst.sh

# Initialize the artifact index database
bash scripts/init-artifact-index.sh
```

This will create:
- `.claude/cache/artifact-index/` - Database in CORRECT location
- Session configuration files
- Cache directories

---

## Step 5: Start Claude Code

```bash
# Still in projectroot/ - this is critical!
claude

# Once Claude Code starts, you can run:
# @chief run bootstrap
```

---

## Verification Checklist

Before running `claude`, verify:

- [ ] `.claude/` exists in project root
- [ ] Your project files (package.json, src/, etc.) are in project root
- [ ] `RunThisFirst.sh` has been executed successfully
- [ ] `scripts/init-artifact-index.sh` has been executed successfully
- [ ] You are in `projectroot/` directory (use `pwd` to confirm)

---

## The Golden Rule

**Always run `claude` from the directory that contains:**
1. Your `.claude/` folder
2. Your actual project files

For you, this is `projectroot/` - NOT any subdirectory!

---

## What Happens When You Run `claude` from Correct Location

✅ **Agents can see**: All files in `projectroot/` and subdirectories
✅ **Agents can modify**: Your project files
✅ **Database location**: `projectroot/.claude/cache/artifact-index/`
✅ **Scope**: Entire project visible to @chief and all agents

---

## Common Mistakes to Avoid

❌ **Running `claude` from a subdirectory**
→ Agents cannot see parent directory files

❌ **Having multiple `.claude/` directories**
→ Causes conflicts and confusion

❌ **Running setup scripts from wrong location**
→ Creates database/cache in wrong place

---

## Next Steps After Setup

Once you've completed Steps 1-5:

1. **Start Claude Code**: `claude` (from projectroot/)
2. **Bootstrap the team**: `@chief run bootstrap`
3. **Follow the orchestration**: @chief will guide you through initial setup
4. **Start building**: Use /plan, /e2e, /test-run, etc.

---

## Need Help?

If you encounter issues:
- Verify you're in the correct directory: `pwd`
- Check .claude/ exists: `ls -la .claude/`
- Review this guide step-by-step
- Make sure you completed RunThisFirst.sh successfully

---

**You're now ready to start fresh with Legendary Team in the correct location! 🚀**
