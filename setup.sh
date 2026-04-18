#!/bin/bash
# PowerCut Setup Script for Debian
# This script sets up everything needed to build macOS apps from Debian

set -e

echo "🚀 PowerCut Setup for Debian"
echo "=============================="
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "📦 Installing GitHub CLI..."
    sudo apt update
    sudo apt install -y gh
else
    echo "✅ GitHub CLI already installed"
fi

# Check if git is configured
if ! git config user.name &> /dev/null; then
    echo ""
    echo "⚙️  Configuring Git..."
    read -p "Your name: " name
    read -p "Your email: " email
    git config --global user.name "$name"
    git config --global user.email "$email"
else
    echo "✅ Git already configured"
fi

# Authenticate with GitHub
echo ""
echo "🔐 Authenticating with GitHub..."
if ! gh auth status &> /dev/null; then
    gh auth login
else
    echo "✅ Already authenticated"
fi

# Initialize repository
echo ""
echo "📁 Initializing Git repository..."
if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "Initial commit: PowerCut AI video editor"
    echo "✅ Repository initialized"
else
    echo "✅ Repository already initialized"
fi

# Create GitHub repository
echo ""
echo "☁️  Creating GitHub repository..."
if ! gh repo view &> /dev/null; then
    gh repo create PowerCut --public --source=. --remote=origin --push
    echo "✅ GitHub repository created"
else
    echo "✅ Repository already exists on GitHub"
    git push -u origin main 2>/dev/null || echo "Already pushed"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Wait 5-10 minutes for GitHub Actions to build"
echo "  2. Check: https://github.com/$(gh api user -q .login)/PowerCut/actions"
echo "  3. Download DMG: make download"
echo ""
echo "💡 Daily workflow:"
echo "  - Edit code: vim PowerCut/Core/ProjectManager.swift"
echo "  - Push: make push"
echo "  - Download: make download"
echo ""
echo "📖 Read BUILD_ON_DEBIAN.md for full documentation"
