#!/bin/bash

# Load environment variables
if [ -f ~/.claude-bridge/.env ]; then
    source ~/.claude-bridge/.env
fi

# Set defaults if not in env
PORT=${PORT:-8008}
HOST=${HOST:-127.0.0.1}
TMUX_SESSION=${TMUX_SESSION:-claude}

echo "🔍 === CLAUDE BRIDGE DIAGNOSTICS ==="
echo ""

# Bridge Server Status
echo "🌉 Bridge Server Status:"
if ps aux | grep claude_bridge_server | grep -v grep > /dev/null; then
    echo "✅ Bridge server is running"
    echo "   PID: $(ps aux | grep claude_bridge_server | grep -v grep | awk '{print $2}')"
else
    echo "❌ Bridge server not running"
fi
echo ""

# tmux Session Status
echo "📱 tmux Session Status:"
if tmux list-sessions 2>/dev/null | grep $TMUX_SESSION > /dev/null; then
    echo "✅ $TMUX_SESSION tmux session exists"
    echo "   Session: $(tmux list-sessions | grep $TMUX_SESSION)"
    echo ""
    echo "   Current pane content (last 3 lines):"
    tmux capture-pane -t $TMUX_SESSION:0.0 -p 2>/dev/null | tail -3 | sed 's/^/   /'
else
    echo "❌ No $TMUX_SESSION tmux session found"
fi
echo ""

# Network Status
echo "🌐 Network Status:"
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "Unable to detect")
if [ "$LOCAL_IP" != "Unable to detect" ]; then
    echo "✅ Mac IP Address: $LOCAL_IP"
    echo "   Bridge accessible at: http://$LOCAL_IP:$PORT"
    echo ""
    echo "   Test from iPhone Safari:"
    echo "   http://$LOCAL_IP:$PORT/healthz"
else
    echo "❌ Unable to detect IP address"
    echo "   Run: ipconfig getifaddr en0"
fi
echo ""

# Health Check
echo "🏥 Local Health Check:"
if curl -s http://$HOST:$PORT/healthz > /dev/null 2>&1; then
    echo "✅ Bridge server responding to health checks"
    echo "   Response: $(curl -s http://$HOST:$PORT/healthz)"
else
    echo "❌ Bridge server not responding to health checks"
fi
echo ""

# Recent Logs
echo "📝 Recent Bridge Logs (last 10 lines):"
LOG_FILE=${LOG_FILE:-$HOME/.claude-bridge/logs/bridge.log}
if [ -f "$LOG_FILE" ]; then
    tail -10 "$LOG_FILE" | sed 's/^/   /'
else
    echo "   ❌ No log file found at $LOG_FILE"
fi
echo ""

# Environment Check
echo "🔧 Environment Check:"
if [ -f ~/.claude-bridge/.env ]; then
    echo "✅ Environment file exists"
else
    echo "❌ Environment file missing: ~/.claude-bridge/.env"
fi

TOKEN_FILE=${BEARER_TOKEN_FILE:-$HOME/.claude-bridge/token.txt}
if [ -f "$TOKEN_FILE" ]; then
    echo "✅ Token file exists"
    echo "   Token preview: $(head -c 10 "$TOKEN_FILE")..."
else
    echo "❌ Token file missing: $TOKEN_FILE"
fi
echo ""

# Quick Fixes
echo "🛠️  Quick Fixes:"
echo "   Restart bridge server:"
echo "     cd ~ && source ~/.venvs/claude-bridge/bin/activate && nohup python ~/bin/claude_bridge_server.py > ~/.claude-bridge/logs/bridge.log 2>&1 &"
echo ""
echo "   Restart Claude in tmux:"
echo "     tmux attach -t $TMUX_SESSION || tmux new -s $TMUX_SESSION"
echo "     cd ~/Documents/Code && claude"
echo ""
echo "   Prevent Mac sleep:"
echo "     caffeinate -d &"
echo ""

echo "🔍 === DIAGNOSTICS COMPLETE ==="
