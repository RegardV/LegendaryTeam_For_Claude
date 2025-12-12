#!/bin/bash
# =============================================================================
# Add Troubleshooting Guide to Legendary Team – 2025
# Run this anytime — safe even if file already exists
# =============================================================================

set -e

echo -e "\nAdding Troubleshooting Guide to your Legendary Team...\n"

ROOT="$(pwd)"
CLAUDE="$ROOT/.claude"
TROUBLESHOOTING="$CLAUDE/troubleshooting.md"

mkdir -p "$CLAUDE"

cat > "$TROUBLESHOOTING" << 'EOF'
# TROUBLESHOOTING GUIDE – Legendary Team 2025

Problem: Team not responding or seems stuck
→ Type: /bootstrap

Problem: Drift detected (>15% mismatch)
→ Reply exactly: discovery complete — proceed

Problem: Chat TODO lists appearing
→ Run: /openspec-police activate

Problem: Wrong AI model being used
→ Run: /swap-model zai   (or kimi / claude)

Problem: Want a completely fresh start
→ Delete the .claude folder and re-run the legendary script

Problem: Session not resuming properly
→ Run: @chief resume session

Problem: OpenSpec got corrupted
→ Run: /skill rollback-openspec

Problem: Emergency stop needed
→ Run: /emergency-stop

You are legendary. You are unbreakable. You are never stuck.
EOF

chmod 644 "$TROUBLESHOOTING"

echo -e "Troubleshooting guide added: $TROUBLESHOOTING"
echo -e "You are now 100% unbreakable.\n"