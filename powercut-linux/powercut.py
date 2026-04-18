#!/usr/bin/env python3
"""
PowerCut - AI-Driven Video Editor for Linux
A lightweight version of the macOS PowerCut app
"""

import sys
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QSplitter, QLabel, QPushButton, QListWidget, QSlider, QMenuBar,
    QMenu, QStatusBar, QFileDialog, QMessageBox
)
from PySide6.QtCore import Qt, QTimer
from PySide6.QtGui import QAction, QIcon
import cv2
import numpy as np
from pathlib import Path


class PowerCutMainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("PowerCut - AI Video Editor")
        self.setGeometry(100, 100, 1400, 900)
        
        # Dark theme
        self.setStyleSheet("""
            QMainWindow {
                background-color: #1e1e1e;
                color: #ffffff;
            }
            QWidget {
                background-color: #1e1e1e;
                color: #ffffff;
            }
            QPushButton {
                background-color: #2d2d2d;
                border: 1px solid #3d3d3d;
                padding: 8px 16px;
                border-radius: 4px;
                color: #ffffff;
            }
            QPushButton:hover {
                background-color: #3d3d3d;
            }
            QListWidget {
                background-color: #252525;
                border: 1px solid #3d3d3d;
                border-radius: 4px;
            }
            QLabel {
                color: #ffffff;
            }
            QMenuBar {
                background-color: #2d2d2d;
                color: #ffffff;
            }
            QMenuBar::item:selected {
                background-color: #3d3d3d;
            }
            QMenu {
                background-color: #2d2d2d;
                color: #ffffff;
                border: 1px solid #3d3d3d;
            }
            QMenu::item:selected {
                background-color: #3d3d3d;
            }
        """)
        
        self.media_files = []
        self.current_video = None
        
        self.setup_ui()
        self.create_menus()
        
    def setup_ui(self):
        # Central widget
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # Main layout
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)
        
        # Top section - Preview and Media Browser
        top_splitter = QSplitter(Qt.Horizontal)
        
        # Media Browser (left)
        media_browser = self.create_media_browser()
        top_splitter.addWidget(media_browser)
        
        # Preview Monitor (center)
        preview = self.create_preview_monitor()
        top_splitter.addWidget(preview)
        
        # Inspector Panel (right)
        inspector = self.create_inspector_panel()
        top_splitter.addWidget(inspector)
        
        top_splitter.setSizes([250, 800, 350])
        
        # Bottom section - Timeline
        timeline = self.create_timeline()
        
        # Add to main layout
        main_layout.addWidget(top_splitter, stretch=7)
        main_layout.addWidget(timeline, stretch=3)
        
        # Status bar
        self.statusBar().showMessage("Ready")
        
    def create_media_browser(self):
        widget = QWidget()
        layout = QVBoxLayout(widget)
        
        # Header
        header = QLabel("Media Browser")
        header.setStyleSheet("font-size: 14px; font-weight: bold; padding: 10px;")
        layout.addWidget(header)
        
        # Import button
        import_btn = QPushButton("Import Media")
        import_btn.clicked.connect(self.import_media)
        layout.addWidget(import_btn)
        
        # Media list
        self.media_list = QListWidget()
        layout.addWidget(self.media_list)
        
        return widget
        
    def create_preview_monitor(self):
        widget = QWidget()
        layout = QVBoxLayout(widget)
        
        # Header
        header = QLabel("Preview Monitor")
        header.setStyleSheet("font-size: 14px; font-weight: bold; padding: 10px;")
        layout.addWidget(header)
        
        # Video preview area
        self.preview_label = QLabel("No media loaded")
        self.preview_label.setAlignment(Qt.AlignCenter)
        self.preview_label.setStyleSheet("""
            background-color: #000000;
            border: 2px solid #3d3d3d;
            min-height: 400px;
        """)
        layout.addWidget(self.preview_label)
        
        # Playback controls
        controls = QHBoxLayout()
        
        self.play_btn = QPushButton("▶ Play")
        self.play_btn.clicked.connect(self.toggle_playback)
        controls.addWidget(self.play_btn)
        
        self.stop_btn = QPushButton("⏹ Stop")
        controls.addWidget(self.stop_btn)
        
        controls.addStretch()
        
        layout.addLayout(controls)
        
        # Timeline scrubber
        self.scrubber = QSlider(Qt.Horizontal)
        self.scrubber.setStyleSheet("""
            QSlider::groove:horizontal {
                background: #3d3d3d;
                height: 8px;
                border-radius: 4px;
            }
            QSlider::handle:horizontal {
                background: #0078d4;
                width: 16px;
                margin: -4px 0;
                border-radius: 8px;
            }
        """)
        layout.addWidget(self.scrubber)
        
        return widget
        
    def create_inspector_panel(self):
        widget = QWidget()
        layout = QVBoxLayout(widget)
        
        # Header
        header = QLabel("AI Tools")
        header.setStyleSheet("font-size: 14px; font-weight: bold; padding: 10px;")
        layout.addWidget(header)
        
        # AI Tools
        ai_tools = [
            ("🎬 Detect Scenes", self.detect_scenes),
            ("🔇 Remove Silence", self.remove_silence),
            ("📝 Transcribe Audio", self.transcribe_audio),
            ("👥 Identify Speakers", self.identify_speakers),
            ("⭐ Extract Highlights", self.extract_highlights),
            ("✂️ Smart Crop", self.smart_crop),
            ("📄 Generate Subtitles", self.generate_subtitles),
        ]
        
        for tool_name, tool_func in ai_tools:
            btn = QPushButton(tool_name)
            btn.clicked.connect(tool_func)
            layout.addWidget(btn)
        
        layout.addStretch()
        
        return widget
        
    def create_timeline(self):
        widget = QWidget()
        layout = QVBoxLayout(widget)
        
        # Header
        header = QLabel("Timeline Editor")
        header.setStyleSheet("font-size: 14px; font-weight: bold; padding: 10px;")
        layout.addWidget(header)
        
        # Timeline tracks
        timeline_area = QLabel("Timeline tracks will appear here")
        timeline_area.setStyleSheet("""
            background-color: #252525;
            border: 2px solid #3d3d3d;
            min-height: 200px;
        """)
        timeline_area.setAlignment(Qt.AlignCenter)
        layout.addWidget(timeline_area)
        
        return widget
        
    def create_menus(self):
        menubar = self.menuBar()
        
        # File menu
        file_menu = menubar.addMenu("File")
        
        new_action = QAction("New Project", self)
        new_action.setShortcut("Ctrl+N")
        file_menu.addAction(new_action)
        
        open_action = QAction("Open Project", self)
        open_action.setShortcut("Ctrl+O")
        file_menu.addAction(open_action)
        
        file_menu.addSeparator()
        
        import_action = QAction("Import Media", self)
        import_action.setShortcut("Ctrl+I")
        import_action.triggered.connect(self.import_media)
        file_menu.addAction(import_action)
        
        file_menu.addSeparator()
        
        exit_action = QAction("Exit", self)
        exit_action.setShortcut("Ctrl+Q")
        exit_action.triggered.connect(self.close)
        file_menu.addAction(exit_action)
        
        # Edit menu
        edit_menu = menubar.addMenu("Edit")
        edit_menu.addAction("Undo")
        edit_menu.addAction("Redo")
        
        # AI menu
        ai_menu = menubar.addMenu("AI Tools")
        ai_menu.addAction("Auto-Edit Project")
        ai_menu.addAction("Detect Scenes")
        ai_menu.addAction("Remove Silence")
        ai_menu.addAction("Generate Subtitles")
        
        # Help menu
        help_menu = menubar.addMenu("Help")
        
        about_action = QAction("About PowerCut", self)
        about_action.triggered.connect(self.show_about)
        help_menu.addAction(about_action)
        
    def import_media(self):
        files, _ = QFileDialog.getOpenFileNames(
            self,
            "Import Media Files",
            "",
            "Video Files (*.mp4 *.avi *.mov *.mkv);;Audio Files (*.mp3 *.wav *.aac);;All Files (*.*)"
        )
        
        if files:
            for file_path in files:
                self.media_files.append(file_path)
                self.media_list.addItem(Path(file_path).name)
            
            self.statusBar().showMessage(f"Imported {len(files)} file(s)")
            
    def toggle_playback(self):
        if self.play_btn.text() == "▶ Play":
            self.play_btn.setText("⏸ Pause")
            self.statusBar().showMessage("Playing...")
        else:
            self.play_btn.setText("▶ Play")
            self.statusBar().showMessage("Paused")
            
    def detect_scenes(self):
        QMessageBox.information(self, "AI Tool", "Scene detection will analyze your video and identify scene changes automatically.")
        self.statusBar().showMessage("Scene detection started...")
        
    def remove_silence(self):
        QMessageBox.information(self, "AI Tool", "Silence removal will cut out quiet portions of your audio automatically.")
        self.statusBar().showMessage("Removing silence...")
        
    def transcribe_audio(self):
        QMessageBox.information(self, "AI Tool", "Audio transcription will generate text from speech in your video.")
        self.statusBar().showMessage("Transcribing audio...")
        
    def identify_speakers(self):
        QMessageBox.information(self, "AI Tool", "Speaker identification will detect and label different speakers.")
        self.statusBar().showMessage("Identifying speakers...")
        
    def extract_highlights(self):
        QMessageBox.information(self, "AI Tool", "Highlight extraction will find the best moments in your video.")
        self.statusBar().showMessage("Extracting highlights...")
        
    def smart_crop(self):
        QMessageBox.information(self, "AI Tool", "Smart crop will reframe your video for different aspect ratios.")
        self.statusBar().showMessage("Smart cropping...")
        
    def generate_subtitles(self):
        QMessageBox.information(self, "AI Tool", "Subtitle generation will create accurate subtitles with timing.")
        self.statusBar().showMessage("Generating subtitles...")
        
    def show_about(self):
        QMessageBox.about(
            self,
            "About PowerCut",
            "<h2>PowerCut v1.0.0</h2>"
            "<p>AI-Driven Video Editor for Linux</p>"
            "<p>Built with Python, PySide6, and OpenCV</p>"
            "<p><a href='https://github.com/Arthurc1Moude/PowerCut'>GitHub Repository</a></p>"
        )


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("PowerCut")
    
    window = PowerCutMainWindow()
    window.show()
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
