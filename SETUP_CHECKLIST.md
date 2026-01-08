# Setup Checklist for Claude Bridge

This checklist clearly shows what gets automated vs. what you need to do manually.

## ✅ **AUTOMATED by Scripts** (No manual work needed)

- [x] Install Homebrew packages (tmux, uv)
- [x] Create Python virtual environment
- [x] Install Python dependencies (FastAPI, uvicorn, pydantic)
- [x] Generate authentication token
- [x] Create configuration files
- [x] Set up LaunchAgent for auto-start
- [x] Create tmux session
- [x] Test local bridge functionality

## ⚠️ **MANUAL Steps Required** (Cannot be automated)

### 1. Network Connection
- [ ] Ensure Mac and iPhone are on the same WiFi network
- [ ] Note your Mac's IP address (shown by setup script)

### 2. iOS Shortcut Creation
- [ ] Follow [ios-shortcut-guide.md](ios-shortcut-guide.md)
- [ ] Use your authentication token from `~/.claude-bridge/token.txt`
- [ ] Configure with your Mac's IP address

## 🚀 **Quick Start Workflow**

```bash
# 1. Run automated setup
./setup.sh

# 2. Note the IP address and token shown by the script
# 3. Create iOS Shortcut following the guide
# 4. Test from iPhone!
```

## 🔍 **Verification Commands**

```bash
# Check system health
./status.sh

# Test bridge locally
./demo.sh

# Get your Mac's IP address
ipconfig getifaddr en0

# Test from iPhone (replace with your Mac's IP)
# Open Safari on iPhone and visit:
http://YOUR-MAC-IP:8008/healthz
```

## ❓ **Common Questions**

**Q: Why can't I connect from my iPhone?**
A: Ensure both devices are on the same WiFi network and check your Mac's firewall settings.

**Q: Do I need to use the same WiFi network?**
A: Yes, both devices must be on the same local network for this setup to work.

**Q: What if my IP address changes?**
A: You'll need to update the URL in your iOS Shortcut. Consider setting a static IP for your Mac in your router settings.

**Q: Can I access this from outside my home network?**
A: Not with this basic setup. You would need to configure VPN, port forwarding, or use a tunneling service.

## 🎯 **Success Criteria**

You're ready to use Claude Bridge when:
- [ ] Bridge responds to `curl http://127.0.0.1:8008/healthz`
- [ ] You know your Mac's IP address
- [ ] iPhone can reach `http://YOUR-MAC-IP:8008/healthz` from Safari
- [ ] iOS Shortcut successfully sends commands and receives responses
