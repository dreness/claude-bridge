#!/bin/bash

# Status Checker for Claude Bridge
# This script provides a quick overview of system health

# Load environment variables
if [ -f ~/.claude-bridge/.env ]; then
    source ~/.claude-bridge/.env
fi

# Set defaults if not in env
PORT=${PORT:-8008}
HOST=${HOST:-127.0.0.1}
TMUX_SESSION=${TMUX_SESSION:-claude}
BRIDGE_BASE_DIR=${BRIDGE_BASE_DIR:-$HOME/.claude-bridge}
LOG_DIR=${LOG_DIR:-$HOME/.claude-bridge/logs}

echo "🔍 Claude Bridge System Status"
echo "=============================="
echo ""

# Check bridge server
echo "🌐 Bridge Server:"
if curl -s http://$HOST:$PORT/healthz > /dev/null; then
    HEALTH=$(curl -s http://$HOST:$PORT/healthz)
    echo "✅ Running - $(echo $HEALTH | grep -o '"ok":[^,]*' | cut -d':' -f2)"
    echo "   Target: $(echo $HEALTH | grep -o '"tmux_target":"[^"]*"' | cut -d'"' -f4)"
else
    echo "❌ Not running"
fi
echo ""

# Check tmux session
echo "📺 Tmux Session:"
if tmux has-session -t $TMUX_SESSION 2>/dev/null; then
    echo "✅ Session '$TMUX_SESSION' exists"
    PANES=$(tmux list-panes -t $TMUX_SESSION 2>/dev/null | wc -l)
    echo "   Panes: $PANES"
else
    echo "❌ Session '$TMUX_SESSION' not found"
fi
echo ""

# Check LaunchAgent
echo "🚀 LaunchAgent:"
LAUNCH_AGENT_ID=${LAUNCH_AGENT_ID:-com.$(whoami).claude-bridge}
if launchctl list | grep -q claude-bridge; then
    echo "✅ Loaded: $LAUNCH_AGENT_ID"
else
    echo "❌ Not loaded"
fi
echo ""

# Check network
echo "🌐 Network:"
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "Unable to detect")
if [ "$LOCAL_IP" != "Unable to detect" ]; then
    echo "✅ Mac IP Address: $LOCAL_IP"
    echo "   Bridge URL: http://$LOCAL_IP:$PORT"
else
    echo "⚠️  Unable to detect IP address"
    echo "   Run: ipconfig getifaddr en0"
fi
echo ""

# Check authentication
echo "🔐 Authentication:"
TOKEN_FILE=${BEARER_TOKEN_FILE:-$HOME/.claude-bridge/token.txt}
if [ -f "$TOKEN_FILE" ]; then
    TOKEN=$(cat "$TOKEN_FILE")
    echo "✅ Token exists: ${TOKEN:0:8}..."
else
    echo "❌ No token found"
fi
echo ""

# Check logs
echo "📋 Logs:"
LOG_FILE=${LOG_FILE:-$LOG_DIR/bridge.log}
if [ -f "$LOG_FILE" ]; then
    LOG_SIZE=$(ls -lh "$LOG_FILE" | awk '{print $5}')
    echo "✅ Bridge log: $LOG_SIZE"
    echo "   Recent entries:"
    tail -3 "$LOG_FILE" 2>/dev/null | sed 's/^/   /'
else
    echo "❌ No bridge log found"
fi
echo ""

# Check environment
echo "⚙️ Configuration:"
if [ -f ~/.claude-bridge/.env ]; then
    echo "✅ Environment file exists"
    echo "   Port: $(grep '^PORT=' ~/.claude-bridge/.env | cut -d'=' -f2)"
    echo "   Max lines: $(grep '^MAX_CAPTURE_LINES=' ~/.claude-bridge/.env | cut -d'=' -f2)"
else
    echo "❌ No environment file found"
fi
echo ""

echo "📱 To use from iPhone:"
echo "   1. Ensure both devices are on the same WiFi network"
echo "   2. Use this URL in your iOS Shortcut: http://$LOCAL_IP:$PORT/send"
echo "   3. Follow ios-shortcut-guide.md for setup instructions"
echo ""
echo "🧪 Test locally: ./demo.sh"
echo "🔧 Full test: ./test-bridge.sh"
