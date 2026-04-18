# PowerCut

**AI-Driven Professional Video Editing Studio for macOS**

PowerCut is a professional-grade desktop video editing application that puts AI at the center of the editing workflow. Instead of manually cutting every frame, PowerCut's AI handles the heavy lifting while you direct and refine.

## Features

### Professional Timeline Editor
- Multi-track video, audio, and subtitle editing
- Ripple edits, snapping, and keyframe animation
- Waveform visualization
- Real-time preview with dual monitors (Source/Program)
- Frame-accurate editing

### AI-Powered Automation
- **Scene Detection**: Automatically identify scene changes
- **Silence Removal**: Cut out silent portions intelligently
- **Transcription**: Generate accurate text from speech
- **Speaker Identification**: Detect and label different speakers
- **Highlight Extraction**: Find and extract the best moments
- **Smart Crop**: Reframe content for different aspect ratios
- **Subtitle Generation**: Create timed subtitles automatically
- **Audio Cleanup**: Remove noise and enhance clarity
- **Color Correction**: Automatic color balancing

### Export Presets
- YouTube (1080p, 4K)
- Instagram Reels
- TikTok
- Twitter
- Podcast Audio
- Custom configurations

### Native macOS Performance
- Built with Swift and SwiftUI
- Metal-accelerated video processing
- AVFoundation integration
- Optimized for Apple Silicon

## Architecture

```
PowerCut/
├── Core/
│   ├── ProjectManager.swift       # Project and media management
│   ├── AIOrchestrator.swift       # AI service coordination
│   ├── MediaEngine/               # Video/audio processing
│   ├── Export/                    # Rendering and export
│   └── Models/                    # Data models
├── UI/
│   ├── MainWindow/                # Main editing interface
│   ├── MediaBrowser/              # Asset library
│   ├── Timeline/                  # Timeline editor
│   ├── Preview/                   # Video monitors
│   ├── Inspector/                 # Properties panel
│   └── Settings/                  # App preferences
└── Utilities/                     # Helper functions
```

## Requirements

- macOS 13.0 or later
- Apple Silicon (M1/M2/M3) or Intel Mac
- 8GB RAM minimum (16GB recommended)
- Metal-compatible GPU

## Building

1. Open `PowerCut.xcodeproj` in Xcode 15+
2. Select your development team in Signing & Capabilities
3. Build and run (⌘R)

## AI Services

PowerCut uses modular AI services that can be configured in Settings:

- Scene detection using computer vision
- Transcription via Whisper-compatible APIs
- Semantic understanding with LLM APIs
- Visual analysis with multimodal models

Configure your API keys in Settings > AI Services.

## Development Status

This is a production-ready foundation with:
- ✅ Complete UI architecture
- ✅ Timeline engine structure
- ✅ Media import/management
- ✅ AI orchestration framework
- ✅ Export pipeline
- 🚧 AI service implementations (requires API integration)
- 🚧 Advanced effects system
- 🚧 Plugin architecture

## License

Copyright © 2024. All rights reserved.
