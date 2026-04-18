# PowerCut Build Guide

## Overview

PowerCut is a professional AI-driven video editing application for macOS. This guide covers building, running, and understanding the codebase.

## System Requirements

### Development
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Apple Silicon (M1/M2/M3) or Intel Mac
- 8GB RAM minimum (16GB recommended)

### Runtime
- macOS 13.0 or later
- Metal-compatible GPU
- 8GB RAM minimum

## Building the Project

### 1. Open in Xcode

```bash
cd PowerCut
open PowerCut.xcodeproj
```

### 2. Configure Signing

1. Select the PowerCut target
2. Go to "Signing & Capabilities"
3. Select your development team
4. Xcode will automatically manage provisioning

### 3. Build and Run

- Press `⌘R` to build and run
- Or select Product > Run from menu

## Project Structure

```
PowerCut/
├── PowerCutApp.swift              # App entry point
├── AppDelegate.swift              # App lifecycle
├── Core/
│   ├── ProjectManager.swift       # Project & media management
│   ├── AIOrchestrator.swift       # AI service coordination
│   ├── MediaEngine/
│   │   └── MediaEngine.swift      # Video/audio processing
│   ├── Export/
│   │   └── ExportEngine.swift     # Video export pipeline
│   ├── Playback/
│   │   └── PlaybackEngine.swift   # Timeline playback
│   ├── Timeline/
│   │   └── TimelineEngine.swift   # Timeline operations
│   ├── Thumbnail/
│   │   └── ThumbnailGenerator.swift
│   ├── SceneDetection/
│   │   └── SceneDetector.swift    # Scene change detection
│   ├── Models/
│   │   ├── Models.swift           # Core data models
│   │   └── Project+Codable.swift  # Serialization
│   └── Utilities/
│       ├── VideoAnalyzer.swift
│       └── FileManager+Extensions.swift
├── UI/
│   ├── MainWindowView.swift       # Main interface
│   ├── MediaBrowser/
│   │   └── MediaBrowserView.swift
│   ├── Timeline/
│   │   └── TimelineEditorView.swift
│   ├── Preview/
│   │   └── PreviewMonitorsView.swift
│   ├── Inspector/
│   │   └── InspectorPanelView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Commands/
│       └── PowerCutCommands.swift
└── Utilities/
    ├── TimeFormatter.swift
    └── Extensions.swift
```

## Key Features Implemented

### ✅ Core Editing
- Multi-track timeline (video, audio, subtitle)
- Clip operations (add, remove, split, trim, move)
- Ripple delete
- Frame-accurate snapping
- Real-time preview
- Dual monitor setup (Source/Program)

### ✅ Media Management
- Import video/audio/image files
- Automatic metadata extraction
- Thumbnail generation
- Waveform visualization
- Media library organization

### ✅ Export System
- Multiple export presets (YouTube, Instagram, TikTok, etc.)
- Custom resolution support
- Hardware-accelerated rendering
- Progress tracking
- Vertical video support

### ✅ Audio Processing
- Real waveform generation from audio buffers
- Silence detection
- Volume control
- Audio normalization
- Noise gate/removal

### ✅ Video Analysis
- Scene detection (frame difference)
- Metadata extraction
- Thumbnail generation
- Video track analysis

### ✅ Project Management
- Save/load projects (.pcproj format)
- JSON-based serialization
- Project directory management
- Cache management

## What's NOT Implemented (Stubs)

### AI Services
All AI functions currently print to console only:
- Transcription (needs Whisper API)
- Speaker identification
- Highlight extraction
- Smart crop/reframe
- AI subtitle generation
- Title suggestions
- AI thumbnail generation
- AI audio cleanup
- AI color correction

### Video Effects
Metal infrastructure exists but effects are pass-through:
- Blur (needs Metal shader)
- Sharpen (needs Metal shader)
- Advanced color grading (needs Metal pipeline)

## Adding AI Services

### Example: Transcription Service

```swift
class TranscriptionService {
    func transcribe(audioURL: URL) async -> String? {
        // 1. Extract audio from video
        // 2. Call Whisper API
        let apiKey = "your-api-key"
        let endpoint = "https://api.openai.com/v1/audio/transcriptions"
        
        // 3. Return transcript
        return transcript
    }
}
```

### Example: Scene Detection AI

```swift
class SceneDetectionService {
    func detectScenes() async {
        // 1. Extract frames
        // 2. Call GPT-4 Vision API
        // 3. Analyze scene changes
        // 4. Return timestamps
    }
}
```

## Testing the App

### Basic Workflow

1. **Launch App**
   ```
   ⌘R in Xcode
   ```

2. **Import Media**
   - Click "Import" button
   - Select video/audio files
   - Thumbnails generate automatically

3. **Add to Timeline**
   - Drag media from browser to timeline
   - Or use context menu

4. **Edit**
   - Click clip to select
   - Press `S` to split at playhead
   - Drag to move clips
   - Delete key to remove

5. **Export**
   - Click "Export" button
   - Choose preset
   - Select destination
   - Monitor progress

### Keyboard Shortcuts

- `Space` - Play/Pause
- `⌘N` - New Project
- `⌘O` - Open Project
- `⌘S` - Save Project
- `⌘E` - Export
- `S` - Split Clip
- `Delete` - Delete Clip

## Performance Optimization

### Metal Acceleration
- Video processing uses Metal when available
- GPU-accelerated effects (when implemented)
- Hardware-accelerated export

### Memory Management
- Lazy thumbnail loading
- Proxy workflow support (planned)
- Efficient waveform caching

### Background Processing
- Non-blocking export
- Async media import
- Background thumbnail generation

## Debugging

### Enable Verbose Logging

```swift
// In AppDelegate.swift
func applicationDidFinishLaunching(_ notification: Notification) {
    #if DEBUG
    print("Debug mode enabled")
    #endif
}
```

### Common Issues

**Issue**: Export fails
- Check disk space
- Verify media files exist
- Check console for AVFoundation errors

**Issue**: Thumbnails not generating
- Verify video codec support
- Check file permissions
- Look for AVAssetImageGenerator errors

**Issue**: Playback stuttering
- Reduce preview quality
- Enable proxy workflow
- Check CPU/GPU usage

## Distribution

### Creating Release Build

1. Select "Any Mac" as destination
2. Product > Archive
3. Distribute App
4. Choose distribution method:
   - Direct Distribution (DMG)
   - Mac App Store
   - Developer ID

### Code Signing

Required for distribution outside Mac App Store:
1. Get Developer ID certificate
2. Configure in Xcode
3. Enable Hardened Runtime
4. Notarize with Apple

### Creating DMG

```bash
# Install create-dmg
brew install create-dmg

# Create DMG
create-dmg \
  --volname "PowerCut" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --app-drop-link 600 185 \
  "PowerCut.dmg" \
  "build/Release/PowerCut.app"
```

## Contributing

### Code Style
- Swift 5.9+ features
- SwiftUI for UI
- Async/await for concurrency
- Combine for reactive updates

### Architecture Principles
- Separation of concerns
- Single responsibility
- Dependency injection
- Protocol-oriented design

### Testing
- Unit tests for core logic
- Integration tests for export
- UI tests for workflows

## Resources

### Apple Documentation
- [AVFoundation](https://developer.apple.com/av-foundation/)
- [Metal](https://developer.apple.com/metal/)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)

### Third-Party APIs
- [OpenAI Whisper](https://platform.openai.com/docs/guides/speech-to-text)
- [GPT-4 Vision](https://platform.openai.com/docs/guides/vision)

## Support

For issues and questions:
- Check IMPLEMENTATION_STATUS.md for feature status
- Review ARCHITECTURE.md for design decisions
- See README.md for overview

## License

Copyright © 2024. All rights reserved.
