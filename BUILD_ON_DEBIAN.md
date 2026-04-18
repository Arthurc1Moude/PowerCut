# Building PowerCut on Debian for macOS

## The Reality

**You CANNOT directly cross-compile macOS apps from Linux.** Here's why:

1. SwiftUI requires macOS SDK
2. AVFoundation is macOS-only
3. AppKit requires macOS frameworks
4. Code signing requires macOS
5. The linker needs macOS system libraries

## The Solution: GitHub Actions

The **correct approach** is to use GitHub Actions with macOS runners. You develop on Debian, push to GitHub, and GitHub builds it on macOS for you.

### How It Works

```
Debian (Development)
  ↓ git push
GitHub (CI/CD)
  ↓ macOS runner
macOS Build
  ↓ artifact
PowerCut.dmg (Download)
```

## Setup Instructions

### 1. Initialize Git Repository

```bash
cd PowerCut
git init
git add .
git commit -m "Initial commit"
```

### 2. Create GitHub Repository

```bash
# Install GitHub CLI if not already installed
sudo apt install gh

# Authenticate
gh auth login

# Create repository
gh repo create PowerCut --public --source=. --remote=origin --push
```

### 3. Push Code

```bash
git push -u origin main
```

### 4. GitHub Actions Will Automatically:

- ✅ Build PowerCut on macOS
- ✅ Create DMG installer
- ✅ Upload as artifact
- ✅ Create release (on tags)

### 5. Download Built App

Go to: `https://github.com/YOUR_USERNAME/PowerCut/actions`

Click on latest workflow run → Artifacts → Download `PowerCut-macOS`

## Development Workflow

### On Debian

```bash
# Edit code
vim PowerCut/Core/ProjectManager.swift

# Commit changes
git add .
git commit -m "Add new feature"

# Push to GitHub
git push

# GitHub Actions builds automatically
# Wait 5-10 minutes
# Download DMG from Actions tab
```

### Local Testing (Limited)

You can test Swift logic on Debian:

```bash
# Create test file
cat > test.swift << 'EOF'
import Foundation

// Test TimeFormatter
struct TimeFormatter {
    static func format(seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        let frames = Int((seconds.truncatingRemainder(dividingBy: 1)) * 30)
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d:%02d", hours, minutes, secs, frames)
        } else {
            return String(format: "%02d:%02d:%02d", minutes, secs, frames)
        }
    }
}

// Test
print(TimeFormatter.format(seconds: 125.5))
EOF

# Run test
swift test.swift
```

## GitHub Actions Configuration

The workflow file `.github/workflows/build-macos.yml` does:

1. **Checkout code** from your repository
2. **Select Xcode 15.2** on macOS runner
3. **Build PowerCut** with xcodebuild
4. **Create DMG** with hdiutil
5. **Upload artifacts** for download
6. **Create release** (on version tags)

## Creating Releases

### Tag a Version

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will:
- Build the app
- Create a GitHub Release
- Attach PowerCut.dmg to the release

### Download Release

```bash
# Download latest release
gh release download --pattern "*.dmg"
```

## Cost

GitHub Actions is **FREE** for public repositories:
- 2,000 minutes/month for free
- macOS builds use 10x multiplier
- Each build takes ~5-10 minutes
- You get ~20-40 builds/month free

For private repos:
- $0.08/minute for macOS runners
- ~$0.40-$0.80 per build

## Alternative: Remote macOS

If you need local builds, rent a macOS machine:

### Option 1: MacStadium
- $79/month for Mac mini
- SSH access from Debian
- Build locally

### Option 2: AWS EC2 Mac
- $1.08/hour (~$800/month)
- Dedicated Mac mini
- SSH access

### Option 3: GitHub Codespaces
- Use macOS codespace
- $0.18/hour
- Full Xcode access

## Recommended Workflow

### For Development (Debian)

```bash
# 1. Edit code on Debian
vim PowerCut/Core/AIOrchestrator.swift

# 2. Test Swift logic locally (if possible)
swift test.swift

# 3. Commit and push
git add .
git commit -m "Improve AI orchestration"
git push

# 4. Wait for GitHub Actions
# Check: https://github.com/YOUR_USERNAME/PowerCut/actions

# 5. Download DMG
gh run download

# 6. Test on macOS (VM or physical)
```

### For Quick Iterations

Use GitHub Codespaces with macOS:

```bash
# Create codespace
gh codespace create --repo YOUR_USERNAME/PowerCut --machine macOS

# Connect
gh codespace ssh

# Build locally
xcodebuild -project PowerCut.xcodeproj -scheme PowerCut
```

## What You CAN Do on Debian

### ✅ Code Editing
- Edit all Swift files
- Modify UI layouts
- Update logic

### ✅ Git Operations
- Commit changes
- Push to GitHub
- Create branches
- Manage releases

### ✅ Documentation
- Write markdown docs
- Update README
- Create guides

### ✅ Testing (Limited)
- Test pure Swift logic
- Run Foundation code
- Test algorithms

### ❌ What You CANNOT Do

- Build the macOS app
- Run SwiftUI previews
- Test AVFoundation code
- Create DMG locally
- Code sign the app

## Summary

**Develop on Debian → Push to GitHub → Build on macOS → Download DMG**

This is the **standard approach** used by professional macOS developers who don't have local Macs. It's:
- ✅ Free (for public repos)
- ✅ Automated
- ✅ Reliable
- ✅ Industry standard
- ✅ No macOS SDK needed
- ✅ No legal issues

## Next Steps

1. Create GitHub repository
2. Push PowerCut code
3. Wait for Actions to build
4. Download DMG
5. Test on macOS

```bash
# Quick setup
cd PowerCut
git init
gh repo create PowerCut --public --source=. --push
# Wait 5-10 minutes
gh run download
```

Done! You now have a macOS app built from Debian.
