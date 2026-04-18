#!/bin/bash
# This script must be run on macOS with Xcode installed
# It creates a proper Xcode project for PowerCut

set -e

echo "🔨 Creating PowerCut Xcode Project"
echo "=================================="
echo ""
echo "⚠️  This script must run on macOS with Xcode installed"
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script must run on macOS"
    echo ""
    echo "Options:"
    echo "  1. Run this on a Mac"
    echo "  2. Use GitHub Actions (see below)"
    echo "  3. Use a macOS VM"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "Install Xcode from the App Store"
    exit 1
fi

echo "✅ Running on macOS"
echo "✅ Xcode is installed"
echo ""

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "📦 Creating new Xcode project..."

# Create project using xcodebuild
cat > create_project.swift << 'EOF'
import Foundation

// This would use Xcode's project generation
// For now, we'll use a template
print("Creating project structure...")
EOF

# Actually, let's use a simpler approach - copy from a template
echo "⚠️  Manual step required:"
echo ""
echo "1. Open Xcode"
echo "2. File > New > Project"
echo "3. Choose: macOS > App"
echo "4. Product Name: PowerCut"
echo "5. Interface: SwiftUI"
echo "6. Language: Swift"
echo "7. Save to: $(pwd)/PowerCut"
echo "8. Close Xcode"
echo "9. Press Enter to continue..."
read

if [ ! -d "PowerCut/PowerCut.xcodeproj" ]; then
    echo "❌ Project not found. Please create it first."
    exit 1
fi

echo "✅ Project created"
echo ""
echo "📝 Copying PowerCut source files..."

# Copy all Swift files
cp -r ~/PowerCut/PowerCut/* PowerCut/PowerCut/

echo "✅ Files copied"
echo ""
echo "📦 Copying project file back..."

cp -r PowerCut/PowerCut.xcodeproj ~/PowerCut/

echo "✅ Done!"
echo ""
echo "Next steps:"
echo "  cd ~/PowerCut"
echo "  git add PowerCut.xcodeproj"
echo "  git commit -m 'Add proper Xcode project file'"
echo "  git push"
