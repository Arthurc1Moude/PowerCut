# Quick Fix for "恶意应用" Warning

## Problem

When you open PowerCut, macOS shows: **"恶意应用"** (malicious app) or "unidentified developer"

## Why?

PowerCut is not signed with an Apple Developer certificate (costs $99/year). This is normal for free open-source apps.

## Solution (Choose One)

### ✅ Method 1: Right-Click to Open (Easiest)

1. **Right-click** (or Control+click) on PowerCut.app
2. Select **"Open"**
3. Click **"Open"** in the dialog
4. Done! The app is now trusted

### ✅ Method 2: Terminal Command

Open Terminal and run:

```bash
xattr -cr /Applications/PowerCut.app
```

Then launch PowerCut normally.

### ✅ Method 3: System Settings

1. Try to open PowerCut (it will be blocked)
2. Go to **System Settings** > **Privacy & Security**
3. Find "PowerCut was blocked"
4. Click **"Open Anyway"**

## Is It Safe?

**YES!** PowerCut is:
- ✅ Open source (all code on GitHub)
- ✅ Built by GitHub Actions (automated)
- ✅ No malware or tracking
- ✅ Works offline

## Full Instructions

See [INSTALLATION.md](INSTALLATION.md) for detailed instructions.

## Download

Latest release: https://github.com/Arthurc1Moude/PowerCut/releases/latest
