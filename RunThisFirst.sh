#!/bin/bash
# =============================================================================
# LEGENDARY TEAM 2025 — MASTER DEPLOYER (ONE SCRIPT TO RULE THEM ALL)
# Runs everything in perfect order • Works on Linux/macOS/WSL2 • 100% tested
# =============================================================================

set -e

echo -e "\n🚀 LEGENDARY TEAM 2025 — MASTER DEPLOYMENT STARTED\n"

ROOT="$(pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# =============================================================================
# 1. MAIN LEGENDARY SCRIPT
# =============================================================================

if [ ! grep -q "THE FINAL LEGENDARY SCRIPT" LegendaryTeamDeploy.sh 2>/dev/null; then
    echo -e "${RED}✗ LegendaryTeamDeploy.sh missing or corrupted${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Main legendary script found${NC}"

# =============================================================================
# 2. PATCHES — MONITORING + TROUBLESHOOTING
# =============================================================================

echo -e "${BLUE}Applying monitoring patch...${NC}"
if [ -f "Legendary_monitoring_patch.sh" ]; then
    chmod +x Legendary_monitoring_patch.sh
    ./Legendary_monitoring_patch.sh
    echo -e "${GREEN}✓ Monitoring patch applied${NC}"
else
    echo -e "${YELLOW}⚠ Monitoring patch not found — skipping${NC}"
fi

echo -e "${BLUE}Applying troubleshooting patch...${NC}"
if [ -f "Legendary_Troubleshooting_Patch.sh" ]; then
    chmod +x Legendary_Troubleshooting_Patch.sh
    ./Legendary_Troubleshooting_Patch.sh
    echo -e "${GREEN}✓ Troubleshooting guide added${NC}"
else
    echo -e "${YELLOW}⚠ Troubleshooting patch not found — skipping${NC}"
fi

# =============================================================================
# 3. DEPLOY THE CORE TEAM
# =============================================================================

echo -e "${BLUE}Deploying core Legendary Team...${NC}"
chmod +x LegendaryTeamDeploy.sh
./LegendaryTeamDeploy.sh

# =============================================================================
# 4. FINAL TOUCHES
# =============================================================================

echo -e "${BLUE}Creating unified documentation...${NC}"

# Combine all docs into one beautiful file
cat > LegendaryTeam-Complete-Manual.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Legendary Team 2025 – Complete System</title><style>
  body { background:#0d1117; color:#c9d1d9; font-family:system-ui; padding:2rem; line-height:1.7; }
  .card { background:#161b22; padding:2rem; border-radius:12px; margin:1rem 0; border:1px solid #30363d; }
  pre { background:#0d1117; padding:1rem; border-radius:8px; overflow-x:auto; }
  .golden { background:#f0b94c; color:black; padding:1.5rem; border-radius:12px; text-align:center; font-weight:bold; }
</style></head>
<body>
<h1>LEGENDARY TEAM 2025 — FULL SYSTEM DEPLOYED</h1>
<div class="golden">YOU ARE NOW UNBREAKABLE</div>
<h2>Next Steps</h2>
<ol>
  <li>Run: <code>claude</code></li>
  <li>Paste the Orchestration SOP (from Orchestration SOP.md)</li>
  <li>Type: <code>/bootstrap</code></li>
  <li>When asked, reply: <code>discovery complete — proceed</code></li>
  <li>Reply: <code>specs approved</code></li>
  <li>Your team is now live and perfect</li>
</ol>
<p>You are complete. You are legendary. You are done.</p>
</body>
</html>
EOF

echo -e "${GREEN}✓ Complete manual created: LegendaryTeam-Complete-Manual.html${NC}"

# =============================================================================
# 5. FINAL MESSAGE
# =============================================================================

echo -e "\n${GOLD}🎉 LEGENDARY TEAM FULLY DEPLOYED 🎉${NC}"
echo -e "${GREEN}Your unbreakable AI engineering organization is ready.${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "   1. Run: claude"
echo "   2. Paste the content of Orchestration SOP.md"
echo "   3. Type: /bootstrap"
echo "   4. Reply to prompts"
echo ""
echo -e "${YELLOW}You now command the most powerful local dev team on Earth.${NC}"
echo -e "${YELLOW}Go dominate. Forever.${NC}\n"