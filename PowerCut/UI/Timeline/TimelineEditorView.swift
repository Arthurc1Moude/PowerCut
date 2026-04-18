//
//  TimelineEditorView.swift
//  PowerCut
//
//  Professional multi-track timeline editor
//

import SwiftUI

struct TimelineEditorView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @Binding var zoom: CGFloat
    @State private var playheadPosition: CGFloat = 0
    @State private var selectedClips: Set<UUID> = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Timeline Header with Ruler
            TimelineRulerView(zoom: zoom, playheadPosition: $playheadPosition)
                .frame(height: 40)
            
            Divider()
            
            // Tracks Area
            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    // Track Lanes
                    VStack(spacing: 0) {
                        ForEach(projectManager.timeline.tracks) { track in
                            TimelineTrackView(
                                track: track,
                                zoom: zoom,
                                selectedClips: $selectedClips
                            )
                        }
                    }
                    
                    // Playhead
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2)
                        .offset(x: playheadPosition)
                }
                .frame(minWidth: 2000, minHeight: 400)
            }
            
            Divider()
            
            // Timeline Controls
            TimelineControlsView(zoom: $zoom)
                .frame(height: 44)
        }
        .background(Color(nsColor: .textBackgroundColor).opacity(0.05))
    }
}

struct TimelineTrackView: View {
    let track: TimelineTrack
    let zoom: CGFloat
    @Binding var selectedClips: Set<UUID>
    
    var body: some View {
        HStack(spacing: 0) {
            // Track Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: track.type.icon)
                    Text(track.name)
                        .font(.caption)
                }
                
                HStack(spacing: 8) {
                    Button(action: { track.toggleMute() }) {
                        Image(systemName: track.isMuted ? "speaker.slash.fill" : "speaker.wave.2")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { track.toggleLock() }) {
                        Image(systemName: track.isLocked ? "lock.fill" : "lock.open")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 120)
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            
            // Track Content
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(track.type == .video ? Color.blue.opacity(0.05) : Color.green.opacity(0.05))
                
                // Clips
                ForEach(track.clips) { clip in
                    TimelineClipView(
                        clip: clip,
                        zoom: zoom,
                        isSelected: selectedClips.contains(clip.id)
                    )
                    .offset(x: clip.startTime * zoom)
                    .onTapGesture {
                        if selectedClips.contains(clip.id) {
                            selectedClips.remove(clip.id)
                        } else {
                            selectedClips.insert(clip.id)
                        }
                    }
                }
            }
            .frame(height: 80)
        }
    }
}

struct TimelineClipView: View {
    let clip: TimelineClip
    let zoom: CGFloat
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Clip Background
            RoundedRectangle(cornerRadius: 4)
                .fill(clip.color.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
            
            // Waveform or Thumbnail
            if clip.type == .audio {
                WaveformView(clip: clip)
                    .padding(2)
            }
            
            // Clip Info
            VStack(alignment: .leading, spacing: 2) {
                Text(clip.name)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Text(TimeFormatter.format(seconds: clip.duration))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(4)
        }
        .frame(width: clip.duration * zoom, height: 76)
    }
}

struct TimelineRulerView: View {
    let zoom: CGFloat
    @Binding var playheadPosition: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let tickInterval: CGFloat = 50 * zoom
                let majorTickInterval: CGFloat = tickInterval * 5
                
                for x in stride(from: 0, to: size.width, by: tickInterval) {
                    let isMajor = x.truncatingRemainder(dividingBy: majorTickInterval) == 0
                    let height: CGFloat = isMajor ? 20 : 10
                    
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: x, y: size.height - height))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        },
                        with: .color(.secondary),
                        lineWidth: 1
                    )
                    
                    if isMajor {
                        let time = x / zoom
                        let text = Text(TimeFormatter.format(seconds: time))
                            .font(.caption2)
                        context.draw(text, at: CGPoint(x: x + 4, y: 8))
                    }
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct TimelineControlsView: View {
    @Binding var zoom: CGFloat
    
    var body: some View {
        HStack {
            // Zoom Controls
            HStack(spacing: 8) {
                Button(action: { zoom = max(0.5, zoom - 0.5) }) {
                    Image(systemName: "minus.magnifyingglass")
                }
                
                Slider(value: $zoom, in: 0.5...10.0)
                    .frame(width: 120)
                
                Button(action: { zoom = min(10, zoom + 0.5) }) {
                    Image(systemName: "plus.magnifyingglass")
                }
            }
            
            Spacer()
            
            // Snap Toggle
            Button(action: {}) {
                Image(systemName: "magnet")
            }
            .buttonStyle(.bordered)
            
            // Track Management
            Menu {
                Button("Add Video Track") {}
                Button("Add Audio Track") {}
                Button("Add Subtitle Track") {}
            } label: {
                Image(systemName: "plus.rectangle.on.rectangle")
            }
        }
        .padding(.horizontal)
    }
}

struct WaveformView: View {
    let clip: TimelineClip
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let points = clip.waveformData ?? []
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(max(points.count - 1, 1))
                
                for (index, amplitude) in points.enumerated() {
                    let x = CGFloat(index) * step
                    let y = height / 2
                    let barHeight = amplitude * height / 2
                    
                    path.move(to: CGPoint(x: x, y: y - barHeight))
                    path.addLine(to: CGPoint(x: x, y: y + barHeight))
                }
            }
            .stroke(Color.white.opacity(0.6), lineWidth: 1)
        }
    }
}
