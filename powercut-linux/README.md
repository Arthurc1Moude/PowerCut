# PowerCut for Linux

AI-Driven Video Editor built with Python and Qt.

## Features

- Professional dark UI matching the macOS version
- Media browser for importing video/audio files
- Preview monitor with playback controls
- Timeline editor (coming soon)
- AI Tools:
  - Scene detection
  - Silence removal
  - Audio transcription
  - Speaker identification
  - Highlight extraction
  - Smart cropping
  - Subtitle generation

## Requirements

- Python 3.8 or later
- Linux (tested on Debian/Ubuntu)

## Installation

### Quick Install

```bash
cd powercut-linux
pip install -r requirements.txt
python3 powercut.py
```

### System Dependencies (if needed)

```bash
# Debian/Ubuntu
sudo apt update
sudo apt install python3-pip python3-venv
sudo apt install libxcb-xinerama0 libxcb-cursor0  # Qt dependencies

# Fedora
sudo dnf install python3-pip
sudo dnf install qt6-qtbase-gui

# Arch
sudo pacman -S python-pip
sudo pacman -S qt6-base
```

## Usage

```bash
python3 powercut.py
```

Or make it executable:

```bash
chmod +x powercut.py
./powercut.py
```

## Development Status

This is a lightweight Linux port of PowerCut. Current status:

- ✅ UI Framework (PySide6/Qt)
- ✅ Dark theme matching macOS version
- ✅ Media browser
- ✅ Preview monitor
- ✅ AI tools menu
- ⏳ Video playback (OpenCV integration)
- ⏳ Timeline editing
- ⏳ AI features implementation
- ⏳ Export functionality

## Comparison with macOS Version

| Feature | macOS | Linux |
|---------|-------|-------|
| UI Framework | SwiftUI | PySide6/Qt |
| Media Engine | AVFoundation | OpenCV/FFmpeg |
| Performance | Native | Python |
| File Size | ~1MB | ~50MB (with deps) |
| Status | Complete | In Progress |

## Contributing

The Linux version is actively being developed. Contributions welcome!

## License

Same as the main PowerCut project.
