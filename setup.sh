#!/bin/bash

# Claude Bridge Setup Script
# This script sets up the complete Claude Code remote control system

set -e

echo "🚀 Setting up Claude Bridge for remote control..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is required but not installed. Please install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "📦 Installing required packages..."
brew install tmux uv

echo "🔧 Setting up directory structure..."
mkdir -p ~/.claude-bridge/{logs,state} ~/bin

echo "🔐 Generating authentication token..."
if [ ! -f ~/.claude-bridge/token.txt ]; then
    openssl rand -hex 32 > ~/.claude-bridge/token.txt
    echo "✅ Generated new authentication token"
else
    echo "✅ Authentication token already exists"
fi

echo "📝 Creating environment configuration..."
cat > ~/.claude-bridge/.env << EOF
PORT=8008
HOST=127.0.0.1
TMUX_SESSION=claude
TMUX_TARGET=claude:0.0
MAX_CAPTURE_LINES=2000
CAPTURE_DELAY_MS=1500
BRIDGE_BASE_DIR=\$HOME/.claude-bridge
BEARER_TOKEN_FILE=\$HOME/.claude-bridge/token.txt
LOG_FILE=\$HOME/.claude-bridge/logs/bridge.log
STATE_DIR=\$HOME/.claude-bridge/jobs
LOG_DIR=\$HOME/.claude-bridge/logs
VENV_PATH=\$HOME/.venvs/claude-bridge
BIN_DIR=\$HOME/bin
LAUNCH_AGENT_ID=com.\$(whoami).claude-bridge
EOF

echo "🐍 Setting up Python virtual environment..."
VENV_PATH="$HOME/.venvs/claude-bridge"
uv venv "$VENV_PATH"
source "$VENV_PATH/bin/activate"
uv pip install fastapi "uvicorn[standard]" pydantic python-dotenv

echo "📁 Installing Claude bridge server..."
cp claude_bridge_server.py ~/bin/
chmod +x ~/bin/claude_bridge_server.py

echo "🚀 Setting up LaunchAgent..."
LAUNCH_AGENT_ID="com.$(whoami).claude-bridge"
LAUNCH_AGENT_FILE="$LAUNCH_AGENT_ID.plist"

# Create LaunchAgent plist from template
sed "s/com\.user\.claude-bridge/$LAUNCH_AGENT_ID/g; s|\$HOME|$HOME|g" com.user.claude-bridge.plist.template > "$LAUNCH_AGENT_FILE"
cp "$LAUNCH_AGENT_FILE" ~/Library/LaunchAgents/
launchctl unload ~/Library/LaunchAgents/"$LAUNCH_AGENT_FILE" 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/"$LAUNCH_AGENT_FILE"

echo "🔍 Testing tmux setup..."
if ! tmux has-session -t claude 2>/dev/null; then
    echo "📺 Creating tmux session 'claude'..."
    tmux new -s claude -d
    echo "💡 You can now start Claude Code in the tmux session with:"
    echo "   tmux attach -t claude"
    echo "   # Then run: claude"
else
    echo "✅ Tmux session 'claude' already exists"
fi

echo "🔑 Your authentication token is:"
echo "   $(cat ~/.claude-bridge/token.txt)"
echo ""
echo "🌐 Finding your Mac's network address..."
# Get the local IP address
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "Unable to detect")
if [ "$LOCAL_IP" != "Unable to detect" ]; then
    echo "   Your Mac's IP address: $LOCAL_IP"
    echo "   Bridge URL: http://$LOCAL_IP:8008"
else
    echo "   Run 'ifconfig' to find your network address"
    echo "   Look for 'inet' under your active network interface (en0 or en1)"
fi
echo ""
echo "📱 To use from your iPhone:"
echo "   1. Ensure your iPhone and Mac are on the same network"
echo "   2. Note your Mac's IP address from above"
echo "   3. Create iOS Shortcut using:"
echo "      - URL: http://YOUR-MAC-IP:8008/send"
echo "      - Token: $(cat ~/.claude-bridge/token.txt)"
echo ""
echo "✅ Setup complete! The bridge server should be running on 0.0.0.0:8008"
echo "🔍 Test with: curl -s http://127.0.0.1:8008/healthz"
