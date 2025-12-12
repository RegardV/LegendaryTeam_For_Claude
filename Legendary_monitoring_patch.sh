#!/bin/bash
# =============================================================================
# Legendary Team 2025 – LIVE PROGRESS DASHBOARD
# Run once → opens a beautiful real-time dashboard in your browser
# Updates every 5 seconds — no extra tools needed
# =============================================================================

set -e

ROOT="$(pwd)"
CLAUDE="$ROOT/.claude"
DASHBOARD="$ROOT/legendary-dashboard.html"

echo -e "\nLaunching Legendary Team Live Progress Dashboard...\n"

cat > "$DASHBOARD" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Legendary Team 2025 – Live Dashboard</title>
<style>
  body { background:#0d1117; color:#c9d1d9; font-family:system-ui; margin:0; padding:2rem; }
  .card { background:#161b22; padding:2rem; border-radius:12px; margin:1rem 0; border:1px solid #30363d; }
  .status { font-size:3rem; text-align:center; margin:2rem 0; }
  .good { color:#7ce38b; }
  .warn { color:#f0b94c; }
  .bad { color:#f85149; }
  pre { background:#0d1117; padding:1rem; border-radius:8px; white-space:pre-wrap; }
</style>
<script>
function update() {
  fetch('.claude/session-state.json?' + Date.now())
   .then(r => r.json())
   .then(data => {
     document.getElementById('status').innerHTML = 
       `<span class="good">● ACTIVE</span><br>
        Last bootstrap: ${data.last_bootstrap || 'Never'}<br>
        Version: ${data.version || 'Unknown'}`;
   })
   .catch(() => document.getElementById('status').innerHTML = '<span class="bad">● OFFLINE</span>');

  fetch('.claude/codebase-map.json?' + Date.now())
   .then(r => r.json())
   .then(data => {
     const files = Object.keys(data.files || {}).length;
     document.getElementById('map').textContent = `Files tracked: ${files}`;
   });

  fetch('openspec/master-index.yaml?' + Date.now())
   .then(r => r.text())
   .then(text => {
     const proposals = (text.match(/^-\s/g) || []).length;
     document.getElementById('proposals').textContent = `OpenSpec proposals: ${proposals}`;
   });
}
setInterval(update, 5000);
update();
</script>
</head>
<body>
<div class="card">
  <h1>Legendary Team 2025 – Live Status</h1>
  <div id="status" class="status">Loading...</div>
</div>
<div class="card">
  <h2>Codebase Map</h2>
  <pre id="map">Loading...</pre>
</div>
<div class="card">
  <h2>OpenSpec Status</h2>
  <pre id="proposals">Loading...</pre>
</div>
<div class="card">
  <p>Dashboard auto-refreshes every 5 seconds<br>
     Works on phone, tablet, second monitor — anywhere</p>
</div>
</body>
</html>
EOF

echo "Dashboard created: $DASHBOARD"
echo "Opening in default browser..."

# Cross-platform browser open
if command -v xdg-open &>/dev/null; then
    xdg-open "$DASHBOARD"
elif command -v open &>/dev/null; then
    open "$DASHBOARD"
elif command -v start &>/dev/null; then
    start "$DASHBOARD"
else
    echo "Open this file in your browser: $DASHBOARD"
fi

echo -e "\nLive dashboard is running — keep this terminal open or run again anytime!\n"