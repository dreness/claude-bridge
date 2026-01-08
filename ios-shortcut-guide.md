# iOS Shortcut Setup Guide for Claude Bridge

This guide will help you create an iOS Shortcut that allows you to control Claude Code on your Mac from your iPhone.

## Prerequisites

1. ✅ Claude Bridge server running on your Mac
2. ✅ Mac and iPhone connected to the same WiFi network
3. ✅ Your Mac's IP address (from setup script or `ipconfig getifaddr en0`)
4. ✅ Your authentication token from `~/.claude-bridge/token.txt`

## Step-by-Step Shortcut Creation

### 1. Create New Shortcut
- Open the **Shortcuts** app on your iPhone
- Tap the **+** button to create a new shortcut
- Name it "Send to Claude"

### 2. Add Actions

#### Action 1: Dictate Text
- Add the action
- Configure:
  - Language: Your preferred language
  - Stop Listening: After pause (or your preference)

OR 

#### Action 1: Ask for Input
- Add the action
- Configure:
  - wih: What do you want to send Claude?
  - Default Answer: blank
  - Allow multiple lines

#### Action 2: Get Contents of URL (POST)
- Add the action
- Configure:
  - URL: `http://[YOUR-MAC-IP]:8008/send`
  - Method: `POST`
  - Headers: Add new header
    - Add entry
      - Key: `Authorization`
      - Value: `Bearer YOUR_TOKEN_HERE`
    - Add another entry:
      - Key: `text`
      - Value: `Dictated Text` or `Ask for Input` (from previous action)

#### Action 3: Get Dictionary from Input
- Add the action
- Configure:
  - Input: `Contents of URL` (from previous action)

#### Action 4: Get Dictionary Value
- Add the action
- Configure:
  - Input: `Dictionary` (from previous action)
  - Key: `id`

#### Action 5: Text (URL Construction)
- Add the action
- Configure:
  - Text: `http://[YOUR-MAC-IP]:8008/jobs/`[Dictionary Value]`/live`
  - Note: "Dictionary Value" will be highlighted in orange, indicating it's a variable

#### Action 6: Open URL in Chrome (or another browser)
- Add the action
- Configure:
  - Input: `Text` (from previous action)

#### Action 7: Stop this Shortcut 
- Add the action

## Configuration Notes

### Replace Placeholders
- `YOUR-MAC-IP`: Your Mac's IP address (e.g., `192.168.1.100`)
- `YOUR_TOKEN_HERE`: Your authentication token from `~/.claude-bridge/token.txt`

### How to Find Your Mac's IP Address
```bash
# Run this on your Mac
ipconfig getifaddr en0
# Or if that doesn't work:
ipconfig getifaddr en1
```

### Example URL
If your Mac's IP is `192.168.1.100`, your URL would be:
```
http://192.168.1.100:8008/send
```

## Usage

1. **Tap the Shortcut** on your iPhone
2. **Dictate your command** when prompted
3. **Wait for the response** - the shortcut will poll for updates
4. **View the output** in Quick Look
5. **Continue or stop** polling as needed

## Troubleshooting

### Connection Issues
- Ensure both devices are on the same WiFi network
- Check that the bridge server is running on your Mac
- Verify the IP address hasn't changed (DHCP can reassign IPs)
- Check Mac's firewall settings allow Python connections

### Authentication Issues
- Ensure the token in the shortcut matches your Mac's token
- Check that the Authorization header format is correct: `Bearer TOKEN`

### No Response
- Check that Claude Code is running in the tmux session on your Mac
- Verify the bridge server is running: `curl http://127.0.0.1:8008/healthz`

### "Not Found" or "jobs" Errors
- Ensure you've added the "Get Dictionary Value" action to extract the `id` field
- The URL should be `/jobs/abc123/tail`, not `/jobs/Dictionary/tail`
- Check that "Dictionary Value" (not "Dictionary") is used in the Text action

### "Field required" or "missing body" Errors
- **Symptoms**: `{"detail":[{"loc":["body"],"type":"missing","msg":"Field required","input":null}]}`
- **Cause**: GET request to `/jobs/{id}/tail` is accidentally including a request body
- **Fix**: In Action 7 (Get Contents of URL for polling):
  - Ensure Method is set to `GET`
  - Ensure "Request Body" is set to `None` or completely empty
  - Do NOT include any JSON or request body for the polling requests
  - Only the initial `/send` request should have a request body
