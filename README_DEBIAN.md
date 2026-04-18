# PowerCut - Build macOS Apps from Debian

## TL;DR

```bash
# One-time setup (2 minutes)
./setup.sh

# Wait 5-10 minutes for GitHub Actions to build

# Download your macOS app
make download

# Find DMG in downloads/
ls downloads/PowerCut-macOS/PowerCut.dmg
```

## The Problem

You're on Debian. PowerCut is a macOS app using:
- SwiftUI (macOS-only)
- AVFoundation (macOS-only)
- AppKit (macOS-only)

**You cannot build it directly on Linux.**

## The Solution

Use **GitHub Actions** with macOS runners:

```
Debian (You) → GitHub → macOS Runner → PowerCut.dmg
```

## Quick Start

### 1. Run Setup (First Time Only)

```bash
./setup.sh
```

This will:
- Install GitHub CLI
- Configure Git
- Authenticate with GitHub
- Create GitHub repository
- Push code
- Trigger first build

### 2. Wait for Build

```bash
# Check build status
make status

# Or watch in real-time
make watch

# Or visit GitHub
# https://github.com/YOUR_USERNAME/PowerCut/actions
```

Builds take 5-10 minutes.

### 3. Download DMG

```bash
make download
```

Your macOS app is in `downloads/PowerCut-macOS/PowerCut.dmg`

## Daily Development

### Edit Code

```bash
vim PowerCut/Core/AIOrchestrator.swift
```

### Push and Build

```bash
make push
# Enter commit message
# Wait 5-10 minutes
```

### Download

```bash
make download
```

### Test

Transfer DMG to macOS machine and test.

## Commands

```bash
make help       # Show all commands
make init       # Initialize repository (first time)
make push       # Commit and push (triggers build)
make build      # Push and wait for completion
make download   # Download latest build
make release    # Create versioned release
make status     # Show git and build status
make watch      # Watch build in real-time
make clean      # Clean local artifacts
```

## Creating Releases

```bash
make release
# Enter version: 1.0.0
```

This creates a GitHub Release with DMG attached.

Download releases:

```bash
gh release download v1.0.0
```

## How It Works

### GitHub Actions Workflow

1. You push code from Debian
2. GitHub Actions starts macOS runner
3. Runner checks out your code
4. Xcode builds PowerCut
5. DMG is created
6. Artifact is uploaded
7. You download DMG

### What Runs on macOS

```yaml
- Select Xcode 15.2
- Build with xcodebuild
- Create DMG with hdiutil
- Upload artifact
```

### What You Do on Debian

```bash
- Edit Swift files
- Commit changes
- Push to GitHub
- Download DMG
```

## Cost

### Free Tier (Public Repos)
- 2,000 minutes/month
- macOS uses 10x multiplier
- = 200 minutes of macOS builds
- Each build: ~5-10 minutes
- = 20-40 builds/month FREE

### Private Repos
- $0.08/minute for macOS
- ~$0.40-$0.80 per build
- Still very affordable

## File Structure

```
PowerCut/
├── setup.sh                    # One-time setup script
├── Makefile                    # Build commands
├── .github/
│   └── workflows/
│       ├── build-macos.yml     # Main build workflow
│       └── test.yml            # Test workflow
├── PowerCut/                   # App source code
│   ├── PowerCutApp.swift
│   ├── Core/
│   ├── UI/
│   └── ...
├── BUILD_ON_DEBIAN.md          # Detailed guide
└── QUICK_START.md              # Quick reference
```

## Troubleshooting

### Build Fails

Check GitHub Actions logs:
```bash
gh run view --log
```

### Cannot Push

```bash
# Check authentication
gh auth status

# Re-authenticate
gh auth login
```

### No Artifacts

Wait for build to complete:
```bash
make watch
```

### DMG Won't Open on macOS

The app is not code-signed. On macOS:
1. Right-click DMG
2. Select "Open"
3. Click "Open" in dialog

## Advanced Usage

### Custom Build Configuration

Edit `.github/workflows/build-macos.yml`:

```yaml
- name: Build PowerCut
  run: |
    xcodebuild clean build \
      -project PowerCut.xcodeproj \
      -scheme PowerCut \
      -configuration Release \
      -derivedDataPath ./build
```

### Multiple Schemes

Add more build jobs for different configurations.

### Automated Testing

Tests run automatically on push. See `.github/workflows/test.yml`.

### Code Signing

For distribution, add signing:

```yaml
env:
  CERTIFICATE_BASE64: ${{ secrets.CERTIFICATE_BASE64 }}
  P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
```

## Alternatives

### Option 1: GitHub Codespaces (macOS)

```bash
gh codespace create --repo YOUR_USERNAME/PowerCut --machine macOS
gh codespace ssh
xcodebuild -project PowerCut.xcodeproj
```

Cost: $0.18/hour

### Option 2: Rent macOS Server

- MacStadium: $79/month
- AWS EC2 Mac: $1.08/hour
- SSH from Debian

### Option 3: Local macOS VM

Not recommended - violates Apple EULA

## Why This Approach?

### ✅ Advantages

- No macOS needed locally
- No SDK downloads
- No legal issues
- Automated builds
- Free for public repos
- Industry standard
- Reliable
- Fast (5-10 minutes)

### ❌ Disadvantages

- Requires internet
- 5-10 minute wait per build
- Limited free builds (20-40/month)
- Cannot test locally

## Best Practices

### 1. Batch Changes

Don't push every small change. Batch related changes:

```bash
# Make multiple edits
vim file1.swift
vim file2.swift
vim file3.swift

# Push once
make push
```

### 2. Test Locally (When Possible)

Test pure Swift logic on Debian:

```bash
swift test.swift
```

### 3. Use Branches

```bash
git checkout -b feature/new-ai-tool
# Make changes
git push origin feature/new-ai-tool
# Create PR on GitHub
```

### 4. Cache Dependencies

GitHub Actions caches Xcode builds automatically.

### 5. Monitor Usage

```bash
gh api /user/settings/billing/actions
```

## FAQ

**Q: Can I build locally on Debian?**
A: No. SwiftUI and AVFoundation require macOS.

**Q: How long does a build take?**
A: 5-10 minutes on GitHub Actions.

**Q: Is it free?**
A: Yes, for public repos (20-40 builds/month).

**Q: Can I test the app on Debian?**
A: No. You need macOS to run the app.

**Q: What about code signing?**
A: Not included. Add signing secrets for distribution.

**Q: Can I use this for production?**
A: Yes! Many companies use GitHub Actions for macOS builds.

**Q: What if I hit the free tier limit?**
A: Upgrade to paid plan or wait for next month.

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode)
- [GitHub CLI](https://cli.github.com/)

## Support

- Check `BUILD_ON_DEBIAN.md` for detailed docs
- See `QUICK_START.md` for quick reference
- Run `make help` for commands

## Summary

**You develop on Debian. GitHub builds on macOS. You download DMG.**

Simple, free, and industry-standard.

```bash
./setup.sh    # Once
make push     # Daily
make download # Daily
```

That's it!
