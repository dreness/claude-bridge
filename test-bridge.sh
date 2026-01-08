#!/bin/bash

# Test Script for Claude Bridge
# This script tests the bridge server functionality

set -e

# Load environment variables
if [ -f ~/.claude-bridge/.env ]; then
    source ~/.claude-bridge/.env
fi

# Set defaults if not in env
PORT=${PORT:-8008}
HOST=${HOST:-127.0.0.1}
TMUX_SESSION=${TMUX_SESSION:-claude}
LAUNCH_AGENT_ID=${LAUNCH_AGENT_ID:-com.$(whoami).claude-bridge}

echo "🧪 Testing Claude Bridge..."

# Check if the bridge server is running
echo "🔍 Checking if bridge server is running..."
if curl -s http://$HOST:$PORT/healthz > /dev/null; then
    echo "✅ Bridge server is running"
else
    echo "❌ Bridge server is not running. Starting it..."
    launchctl start "$LAUNCH_AGENT_ID"
    sleep 3
fi

# Test health endpoint
echo "🔍 Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://$HOST:$PORT/healthz)
echo "Health response: $HEALTH_RESPONSE"

# Check tmux session
echo "🔍 Checking tmux session..."
if tmux has-session -t $TMUX_SESSION 2>/dev/null; then
    echo "✅ Tmux session '$TMUX_SESSION' exists"
    TMUX_STATUS=$(tmux list-panes -t $TMUX_SESSION 2>/dev/null || echo "No panes")
    echo "Tmux panes: $TMUX_STATUS"
else
    echo "❌ Tmux session '$TMUX_SESSION' does not exist"
    echo "Creating it now..."
    tmux new -s $TMUX_SESSION -d
    echo "✅ Created tmux session '$TMUX_SESSION'"
fi

# Test authentication
echo "🔍 Testing authentication..."
TOKEN_FILE=${BEARER_TOKEN_FILE:-$HOME/.claude-bridge/token.txt}
TOKEN=$(cat "$TOKEN_FILE" 2>/dev/null || echo "NO_TOKEN")
if [ "$TOKEN" = "NO_TOKEN" ]; then
    echo "❌ No authentication token found"
    exit 1
fi

# Test send endpoint (if tmux is working)
if tmux has-session -t $TMUX_SESSION 2>/dev/null; then
    echo "🔍 Testing send endpoint..."
    TEST_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"text":"echo Hello from bridge test"}' \
        http://$HOST:$PORT/send)
    echo "Send response: $TEST_RESPONSE"
    
    # Extract job ID and test tail endpoint
    JOB_ID=$(echo "$TEST_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$JOB_ID" ]; then
        echo "🔍 Testing tail endpoint for job $JOB_ID..."
        sleep 2
        TAIL_RESPONSE=$(curl -s "http://$HOST:$PORT/jobs/$JOB_ID/tail?lines=10")
        echo "Tail response (first 200 chars): ${TAIL_RESPONSE:0:200}..."
    fi
fi

echo ""
echo "✅ Bridge test complete!"
echo "🔑 Your authentication token: $TOKEN"
echo "🌐 Local bridge URL: http://$HOST:$PORT"
echo ""
echo "📱 To test from iPhone:"
echo "   1. Make sure both devices are on the same WiFi network"
echo "   2. Find your Mac's IP: ipconfig getifaddr en0"
echo "   3. Test from iPhone browser: http://YOUR-MAC-IP:$PORT/healthz"
echo "   4. Create iOS Shortcut with your Mac's IP address"
