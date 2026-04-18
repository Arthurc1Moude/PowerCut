# PowerCut Installation Guide

## Download

Download the latest release from: https://github.com/Arthurc1Moude/PowerCut/releases

## macOS Security Warning (恶意应用 / Unidentified Developer)

Since PowerCut is not code-signed with an Apple Developer certificate, macOS will show a security warning saying the app is from an "unidentified developer" (恶意应用).

**This is normal for open-source apps without paid Apple Developer accounts.**

## How to Install

### Method 1: Right-Click to Open (Easiest)

1. Download `PowerCut.dmg`
2. Open the DMG file
3. **Right-click** (or Control+click) on PowerCut.app
4. Select **"Open"** from the menu
5. Click **"Open"** in the dialog that appears
6. The app will now run and be trusted

### Method 2: Remove Quarantine Flag (Terminal)

1. Download `PowerCut.dmg`
2. Open the DMG file
3. Drag PowerCut to Applications
4. Open Terminal and run:

```bash
xattr -cr /Applications/PowerCut.app
```

5. Launch PowerCut from Applications

### Method 3: System Settings

1. Download `PowerCut.dmg`
2. Try to open PowerCut (it will be blocked)
3. Go to **System Settings** > **Privacy & Security**
4. Scroll down to find "PowerCut was blocked"
5. Click **"Open Anyway"**
6. Confirm by clicking **"Open"**

## Why This Happens

macOS Gatekeeper blocks apps that aren't:
- Downloaded from the Mac App Store, OR
- Signed with an Apple Developer certificate ($99/year)

PowerCut is open-source and free, so it doesn't have a paid certificate.

## Is It Safe?

Yes! PowerCut is:
- ✅ Open source - all code is visible on GitHub
- ✅ Built automatically by GitHub Actions
- ✅ No malware, no tracking, no data collection
- ✅ Runs entirely on your Mac (no internet required)

You can verify the source code at: https://github.com/Arthurc1Moude/PowerCut

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel Mac
- ~50MB free disk space

## Troubleshooting

### "App is damaged and can't be opened"

This happens when the quarantine flag is set. Use Method 2 above:

```bash
xattr -cr /Applications/PowerCut.app
```

### App won't launch at all

1. Check macOS version (must be 13.0+)
2. Try removing and reinstalling
3. Check Console.app for error messages

### Still having issues?

Open an issue on GitHub: https://github.com/Arthurc1Moude/PowerCut/issues

---

## For Developers: Code Signing

To properly sign the app (requires Apple Developer account):

```bash
# Sign the app
codesign --deep --force --sign "Developer ID Application: Your Name" PowerCut.app

# Notarize with Apple
xcrun notarytool submit PowerCut.dmg --apple-id your@email.com --team-id TEAMID --wait

# Staple the notarization
xcrun stapler staple PowerCut.app
```

This costs $99/year for an Apple Developer account.
