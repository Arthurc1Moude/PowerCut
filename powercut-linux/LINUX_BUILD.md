# Building PowerCut for Linux

## Overview

PowerCut for Linux is a Python/Qt port of the macOS version, providing cross-platform video editing capabilities.

## Architecture

- **UI**: PySide6 (Qt for Python)
- **Video Processing**: OpenCV + FFmpeg
- **Language**: Python 3.8+
- **Platform**: Linux (Debian, Ubuntu, Fedora, Arch, etc.)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/Arthurc1Moude/PowerCut
cd PowerCut/powercut-linux

# Install
./install.sh

# Run
./run.sh
```

## Manual Installation

### 1. Install System Dependencies

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
sudo apt install libxcb-xinerama0 libxcb-cursor0  # Qt dependencies
```

**Fedora:**
```bash
sudo dnf install python3 python3-pip
sudo dnf install qt6-qtbase-gui
```

**Arch:**
```bash
sudo pacman -S python python-pip
sudo pacman -S qt6-base
```

### 2. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 4. Run PowerCut

```bash
python3 powercut.py
```

## Creating a Desktop Launcher

```bash
# Copy desktop file to applications
mkdir -p ~/.local/share/applications
cp powercut.desktop ~/.local/share/applications/

# Update desktop database
update-desktop-database ~/.local/share/applications/
```

## Packaging

### AppImage (Recommended)

```bash
# Install pyinstaller
pip install pyinstaller

# Create standalone executable
pyinstaller --onefile --windowed \
  --name PowerCut \
  --add-data "README.md:." \
  powercut.py

# The executable will be in dist/PowerCut
```

### Debian Package

```bash
# Install packaging tools
sudo apt install debhelper dh-python

# Create package structure
mkdir -p powercut-deb/DEBIAN
mkdir -p powercut-deb/usr/bin
mkdir -p powercut-deb/usr/share/applications

# Copy files
cp powercut.py powercut-deb/usr/bin/powercut
cp powercut.desktop powercut-deb/usr/share/applications/

# Create control file
cat > powercut-deb/DEBIAN/control << EOF
Package: powercut
Version: 1.0.0
Section: video
Priority: optional
Architecture: all
Depends: python3, python3-pyside6, python3-opencv, python3-numpy
Maintainer: Your Name <your@email.com>
Description: AI-Driven Video Editor
 PowerCut is a professional video editing application
 with AI-powered automation tools.
EOF

# Build package
dpkg-deb --build powercut-deb
```

### Flatpak

```bash
# Install flatpak-builder
sudo apt install flatpak-builder

# Create manifest (com.powercut.PowerCut.yml)
# Build flatpak
flatpak-builder --force-clean build-dir com.powercut.PowerCut.yml
```

## Development

### Running in Development Mode

```bash
source venv/bin/activate
python3 powercut.py
```

### Adding Features

The codebase is organized as:
- `powercut.py` - Main application
- UI components in `PowerCutMainWindow` class
- AI tools as methods (e.g., `detect_scenes()`)

### Testing

```bash
# Install test dependencies
pip install pytest pytest-qt

# Run tests
pytest tests/
```

## Distribution

### Binary Release

1. Build with PyInstaller
2. Create tarball:
```bash
tar -czf powercut-linux-v1.0.0.tar.gz dist/PowerCut
```

### Source Release

```bash
tar -czf powercut-linux-v1.0.0-source.tar.gz \
  powercut.py requirements.txt README.md install.sh run.sh
```

## Troubleshooting

### Qt Platform Plugin Error

```bash
export QT_QPA_PLATFORM=xcb
# or
export QT_QPA_PLATFORM=wayland
```

### Missing Dependencies

```bash
# Check what's missing
ldd venv/lib/python3.*/site-packages/PySide6/Qt/lib/libQt6Core.so.6
```

### Permission Issues

```bash
chmod +x powercut.py run.sh install.sh
```

## Performance Optimization

### Use PyPy (faster Python)

```bash
pypy3 -m venv venv-pypy
source venv-pypy/bin/activate
pip install -r requirements.txt
pypy3 powercut.py
```

### Compile with Nuitka

```bash
pip install nuitka
python3 -m nuitka --standalone --onefile powercut.py
```

## Cross-Platform Notes

PowerCut Linux should work on:
- ✅ Debian/Ubuntu
- ✅ Fedora/RHEL
- ✅ Arch Linux
- ✅ openSUSE
- ⚠️ WSL2 (with X server)
- ❌ macOS (use native version)
- ❌ Windows (port needed)

## Contributing

See the main PowerCut repository for contribution guidelines.
