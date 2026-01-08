#!/bin/bash

# Quick Start Script for Claude Bridge
# This script runs the essential setup steps in sequence

set -e

echo "🚀 Quick Start: Claude Bridge Setup"
echo "=================================="
echo ""

echo "📦 Step 1: Installing dependencies and setting up bridge..."
./setup.sh

echo ""
echo "⏳ Waiting for bridge server to start..."
sleep 5

# Step 2: Test the bridge
echo ""
echo "🧪 Step 2: Testing bridge functionality..."
./test-bridge.sh

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📱 Next steps:"
echo "   1. Ensure your iPhone and Mac are on the same WiFi network"
echo "   2. Note your Mac's IP address (shown above)"
echo "   3. Create iOS Shortcut using the guide in ios-shortcut-guide.md"
echo ""
echo "🔑 Your authentication token:"
cat ~/.claude-bridge/token.txt
echo ""
echo "🌐 Test locally: curl -s http://127.0.0.1:8008/healthz"
echo ""
echo "💡 Use './status.sh' to check system health anytime"
