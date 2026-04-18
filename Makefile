# PowerCut Makefile
# For development on Debian, building on GitHub Actions

.PHONY: help init push build download release clean generate-project

help:
	@echo "PowerCut - macOS App Development from Debian"
	@echo ""
	@echo "Commands:"
	@echo "  make generate-project - Generate Xcode project with xcodegen (FREE)"
	@echo "  make init             - Initialize git and create GitHub repo"
	@echo "  make push             - Commit and push changes (triggers build)"
	@echo "  make build            - Push and wait for GitHub Actions build"
	@echo "  make download         - Download latest build from GitHub"
	@echo "  make release          - Create a new release version"
	@echo "  make clean            - Clean local artifacts"
	@echo ""
	@echo "First Time Setup:"
	@echo "  1. make generate-project  (generates Xcode project - FREE!)"
	@echo "  2. Wait 2-3 minutes for PR"
	@echo "  3. Merge the PR"
	@echo "  4. make push (to build)"
	@echo ""
	@echo "Daily Workflow:"
	@echo "  1. Edit code on Debian"
	@echo "  2. make push"
	@echo "  3. make download"
	@echo "  4. Test DMG on macOS"

init:
	@echo "Initializing Git repository..."
	git init
	git add .
	git commit -m "Initial commit: PowerCut video editor"
	@echo ""
	@echo "Creating GitHub repository..."
	gh repo create PowerCut --public --source=. --remote=origin --push
	@echo ""
	@echo "✅ Repository created! GitHub Actions will build automatically."
	@echo "Check: https://github.com/$$(gh repo view --json owner -q .owner.login)/PowerCut/actions"

push:
	@echo "Committing changes..."
	git add .
	@read -p "Commit message: " msg; \
	git commit -m "$$msg" || echo "No changes to commit"
	@echo ""
	@echo "Pushing to GitHub..."
	git push
	@echo ""
	@echo "✅ Pushed! GitHub Actions is building..."
	@echo "Check: https://github.com/$$(gh repo view --json owner -q .owner.login)/PowerCut/actions"

build: push
	@echo "Waiting for GitHub Actions to complete..."
	@echo "(This takes 5-10 minutes)"
	@gh run watch

download:
	@echo "Downloading latest build..."
	@mkdir -p downloads
	@gh run download --dir downloads
	@echo ""
	@echo "✅ Downloaded to: downloads/"
	@ls -lh downloads/

release:
	@read -p "Version (e.g., 1.0.0): " version; \
	git tag "v$$version"; \
	git push origin "v$$version"
	@echo ""
	@echo "✅ Release v$$version created!"
	@echo "GitHub Actions will build and attach DMG to release."

clean:
	@echo "Cleaning local artifacts..."
	rm -rf downloads/
	rm -f PowerCut.dmg
	@echo "✅ Cleaned"

# Development helpers
test-swift:
	@echo "Testing Swift logic locally..."
	@swift --version
	@echo ""
	@echo "Note: Only Foundation code can be tested on Linux"
	@echo "SwiftUI, AVFoundation, AppKit require macOS"

status:
	@echo "Git Status:"
	@git status --short
	@echo ""
	@echo "Latest Commit:"
	@git log -1 --oneline
	@echo ""
	@echo "GitHub Actions:"
	@gh run list --limit 5

watch:
	@echo "Watching GitHub Actions..."
	@gh run watch

generate-project:
	@echo "🚀 Generating Xcode project with xcodegen (FREE)..."
	@echo ""
	@echo "This will:"
	@echo "  1. Push project.yml to GitHub"
	@echo "  2. Trigger GitHub Actions on macOS runner"
	@echo "  3. Generate PowerCut.xcodeproj automatically"
	@echo "  4. Create a Pull Request with the project"
	@echo ""
	@echo "Cost: $0.00 (completely free!)"
	@echo "Time: 2-3 minutes"
	@echo ""
	@read -p "Press Enter to continue..." dummy
	@echo ""
	@echo "Committing xcodegen configuration..."
	@git add project.yml .github/workflows/generate-xcode-project.yml XCODEGEN_SOLUTION.md FREE_MACOS_OPTIONS.md
	@git commit -m "Add xcodegen configuration for automatic Xcode project generation" || echo "Already committed"
	@echo ""
	@echo "Pushing to GitHub..."
	@git push
	@echo ""
	@echo "✅ Pushed! GitHub Actions is generating the Xcode project..."
	@echo ""
	@echo "Check progress:"
	@echo "  https://github.com/$(shell gh repo view --json owner -q .owner.login)/PowerCut/actions"
	@echo ""
	@echo "In 2-3 minutes, you'll see a Pull Request with the generated project."
	@echo "Merge it, then you can build the app!"
	@echo ""
	@echo "To watch progress: make watch"
