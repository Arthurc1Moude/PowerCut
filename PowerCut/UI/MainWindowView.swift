//
//  MainWindowView.swift
//  PowerCut
//
//  Main editing interface with professional layout
//

import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @State private var selectedMediaItem: MediaItem?
    @State private var timelineZoom: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                // Left: Media Browser
                MediaBrowserView(selectedItem: $selectedMediaItem)
                    .frame(minWidth: 280, idealWidth: 320, maxWidth: 400)
                
                // Center: Preview and Timeline
                VStack(spacing: 0) {
                    // Top: Source/Program Monitors
                    PreviewMonitorsView()
                        .frame(height: geometry.size.height * 0.5)
                    
                    Divider()
                    
                    // Bottom: Timeline Editor
                    TimelineEditorView(zoom: $timelineZoom)
                        .frame(minHeight: 300)
                }
                
                // Right: Inspector Panel
                InspectorPanelView(selectedItem: $selectedMediaItem)
                    .frame(minWidth: 280, idealWidth: 320, maxWidth: 400)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .toolbar {
            ToolbarView()
        }
    }
}

struct ToolbarView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @EnvironmentObject var aiOrchestrator: AIOrchestrator
    
    var body: some View {
        HStack(spacing: 16) {
            // Import Media
            Button(action: { projectManager.importMedia() }) {
                Label("Import", systemImage: "square.and.arrow.down")
            }
            
            Divider()
            
            // AI Actions
            Menu {
                Button("Auto-Edit Project") { Task { await aiOrchestrator.autoEditProject() } }
                Button("Remove Silence") { Task { await aiOrchestrator.removeSilence() } }
                Button("Detect Scenes") { Task { await aiOrchestrator.detectScenes() } }
                Button("Generate Subtitles") { Task { await aiOrchestrator.generateSubtitles() } }
                Button("Extract Highlights") { Task { await aiOrchestrator.extractHighlights() } }
                Button("Reframe for Vertical") { Task { await aiOrchestrator.reframeVertical() } }
            } label: {
                Label("AI Tools", systemImage: "wand.and.stars")
            }
            .menuStyle(.borderlessButton)
            
            Divider()
            
            // Playback Controls
            PlaybackControlsView()
            
            Spacer()
            
            // Export
            Button(action: { projectManager.exportProject() }) {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 12)
    }
}
