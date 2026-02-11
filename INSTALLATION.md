# Installation Guide

## Prerequisites

- Git
- Bash (Linux/macOS) or PowerShell (Windows)
- Claude Code CLI installed

## Quick Install

### Option 1: One-Liner (Recommended)

```bash
cd ~/your-project && \
git clone https://github.com/RegardV/LegendaryTeam_For_Claude .legendary-tmp && \
cp -r .legendary-tmp/.claude . && \
cp .legendary-tmp/CLAUDE.md .legendary-tmp/"Orchestration SOP.md" . && \
rm -rf .legendary-tmp && \
bash .claude/../LegendaryTeamDeploy.sh
```

### Option 2: Step-by-Step

```bash
# 1. Backup existing .claude (optional but safe)
mv ~/your-project/.claude ~/your-project/.claude.backup

# 2. Clone to temp location
git clone https://github.com/RegardV/LegendaryTeam_For_Claude /tmp/legendary-temp

# 3. Copy what you need to your project
cp -r /tmp/legendary-temp/.claude ~/your-project/
cp /tmp/legendary-temp/CLAUDE.md ~/your-project/
cp /tmp/legendary-temp/"Orchestration SOP.md" ~/your-project/

# 4. Run the deploy script to initialize
cd ~/your-project && bash LegendaryTeamDeploy.sh

# 5. Cleanup temp
rm -rf /tmp/legendary-temp
```

### Option 3: Windows PowerShell

```powershell
cd C:\your-project
git clone https://github.com/RegardV/LegendaryTeam_For_Claude legendary-tmp
Copy-Item -Recurse legendary-tmp\.claude .
Copy-Item legendary-tmp\CLAUDE.md .
Copy-Item "legendary-tmp\Orchestration SOP.md" .
Remove-Item -Recurse legendary-tmp
.\LegendaryTeamDeploy.ps1
```

## What Gets Installed

```
~/your-project/
├── .claude/
│   ├── agents/              # 25 specialist agents
│   ├── agents-lite/         # Token-optimized versions
│   ├── agents-full/         # Full definitions for self-escalation
│   ├── hooks/               # Lifecycle hooks (SessionStart, etc.)
│   ├── rules/               # Behavioral rules (security, git, etc.)
│   ├── skills/              # Best practice patterns
│   ├── commands/            # Slash commands (/bootstrap, etc.)
│   ├── settings.json        # Hook registration with Claude Code
│   ├── session-state.json   # Session tracking
│   └── codebase-map.json    # File tracking
├── thoughts/
│   ├── ledgers/             # Current session state
│   ├── shared/
│   │   ├── handoffs/        # Cross-session knowledge transfer
│   │   └── plans/           # Execution plans
│   └── templates/           # Standard formats
├── CLAUDE.md                # Entry point (read by Claude Code)
└── Orchestration SOP.md     # Full operational documentation
```

## Post-Installation

1. **Start Claude Code** in your project directory
2. **Run `/bootstrap`** to initialize the team
3. **Verify with `/team-status`** to see all agents

## Updating

To update to the latest version:

```bash
cd ~/your-project
git clone https://github.com/RegardV/LegendaryTeam_For_Claude /tmp/legendary-update

# Update only what you want (preserves your customizations)
cp -r /tmp/legendary-update/.claude/agents-lite .claude/
cp -r /tmp/legendary-update/.claude/agents-full .claude/
cp -r /tmp/legendary-update/.claude/hooks .claude/
cp -r /tmp/legendary-update/.claude/rules .claude/

rm -rf /tmp/legendary-update
```

## Troubleshooting

### Hooks not firing
- Check `.claude/settings.json` exists
- Verify hook files are executable: `chmod +x .claude/hooks/*.js`
- Check Claude Code version supports hooks

### Agents not found
- Run `bash LegendaryTeamDeploy.sh` to regenerate
- Verify `.claude/agents/` contains .md files

### Permission errors
- On Linux/macOS: `chmod -R 755 .claude/`
- On Windows: Run PowerShell as Administrator
