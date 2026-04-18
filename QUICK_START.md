# Quick Start: Build PowerCut from Debian

## Prerequisites

```bash
# Install GitHub CLI
sudo apt install gh

# Authenticate
gh auth login
```

## Build Your First DMG (5 minutes)

```bash
# 1. Initialize and push to GitHub
make init

# 2. Wait for build (5-10 minutes)
# Check: https://github.com/YOUR_USERNAME/PowerCut/actions

# 3. Download DMG
make download

# 4. Find your app
ls downloads/PowerCut-macOS/
```

## Daily Development Workflow

```bash
# Edit code
vim PowerCut/Core/ProjectManager.swift

# Push and build
make push

# Wait 5-10 minutes...

# Download
make download

# Test on macOS
```

## Create a Release

```bash
make release
# Enter version: 1.0.0

# DMG will be attached to GitHub release
```

## That's It!

You're now building macOS apps from Debian using GitHub Actions.

No macOS needed. No SDK needed. No Xcode needed locally.

Just push code, wait 5-10 minutes, download DMG.
