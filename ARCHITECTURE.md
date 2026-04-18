# PowerCut Architecture

## Overview

PowerCut is built as a native macOS application using Swift and SwiftUI, with a modular architecture that separates concerns between UI, media processing, AI orchestration, and export.

## Core Components

### 1. ProjectManager
Central coordinator for project state, media library, and timeline management.

**Responsibilities:**
- Project lifecycle (create, save, load)
- Media import and organization
- Timeline state management
- Playback control coordination

### 2. AIOrchestrator
Manages AI service integration and job scheduling.

**Responsibilities:**
- AI job queue management
- Service module coordination
- Progress tracking
- Error handling

**AI Services:**
- SceneDetectionService
- TranscriptionService
- HighlightExtractionService
- SubtitleGenerationService
- AudioCleanupService
- ColorCorrectionService

### 3. MediaEngine
Low-level media processing using AVFoundation and Metal.

**Responsibilities:**
- Video frame processing (Metal-accelerated)
- Audio buffer processing
- Waveform generation
- Hardware acceleration

### 4. Timeline System
Professional multi-track editing engine.

**Components:**
- Timeline: Container for all tracks
- TimelineTrack: Individual video/audio/subtitle tracks
- TimelineClip: Media segments with in/out points
- Playhead management
- Snapping and ripple edit logic

### 5. ExportEngine
Rendering and export pipeline using AVFoundation.

**Responsibilities:**
- Composition building from timeline
- Export preset management
- Hardware-accelerated rendering
- Progress reporting

## UI Architecture

### Main Window Layout
```
┌─────────────────────────────────────────────────────┐
│  Toolbar (Import, AI Tools, Playback, Export)       │
├──────────┬──────────────────────────┬───────────────┤
│          │  Source    │   Program   │               │
│  Media   │  Monitor   │   Monitor   │   Inspector   │
│  Browser │            │             │   Panel       │
│          ├──────────────────────────┤               │
│          │                          │               │
│          │   Timeline Editor        │               │
│          │   (Multi-track)          │               │
└──────────┴──────────────────────────┴───────────────┘
```

### View Hierarchy
- MainWindowView
  - MediaBrowserView
  - PreviewMonitorsView
    - VideoMonitorView (Source)
    - VideoMonitorView (Program)
  - TimelineEditorView
    - TimelineRulerView
    - TimelineTrackView (multiple)
    - TimelineControlsView
  - InspectorPanelView
    - PropertiesInspectorView
    - EffectsInspectorView
    - AIToolsInspectorView
    - ExportInspectorView

## Data Flow

### Media Import Flow
```
User selects files
  → ProjectManager.importMedia()
  → Process with AVAsset
  → Extract metadata
  → Generate thumbnail
  → Add to mediaItems array
  → Update UI
```

### AI Processing Flow
```
User triggers AI action
  → AIOrchestrator creates job
  → Job added to queue
  → Service module processes
  → Progress updates
  → Result applied to timeline
  → UI updates
```

### Export Flow
```
User selects export preset
  → ExportEngine.exportVideo()
  → Build AVComposition from timeline
  → Configure AVAssetExportSession
  → Render with hardware acceleration
  → Save to disk
  → Completion callback
```

## Technology Stack

- **UI Framework**: SwiftUI
- **Media Processing**: AVFoundation
- **GPU Acceleration**: Metal
- **Async Operations**: Swift Concurrency (async/await)
- **State Management**: Combine + @Published
- **File I/O**: FileManager, URL

## Performance Considerations

1. **Metal Acceleration**: Video processing uses Metal for GPU acceleration
2. **Proxy Workflows**: Support for lower-resolution proxies during editing
3. **Background Rendering**: Non-blocking export operations
4. **Lazy Loading**: Media thumbnails generated on-demand
5. **Efficient Timeline**: Optimized clip rendering and waveform display

## Extension Points

### Plugin System (Future)
- Custom AI rules
- Effect plugins
- Export templates
- Workflow automation

### API Integration
- Cloud transcription services
- LLM APIs for content analysis
- Cloud storage sync
- Team collaboration

## Security & Privacy

- Sandboxed application
- User-selected file access only
- Camera/microphone permissions
- No telemetry without consent
- Local processing preferred over cloud

## Build & Deployment

### Requirements
- Xcode 15+
- macOS 13.0+ SDK
- Swift 5.9+

### Build Configuration
- Debug: Full symbols, no optimization
- Release: Optimized, stripped symbols
- Code signing required for distribution

### Distribution
- Direct download (.dmg)
- Mac App Store (future)
- TestFlight for beta testing
