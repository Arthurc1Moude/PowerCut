//
//  PreviewMonitorsView.swift
//  PowerCut
//
//  Source and Program preview monitors
//

import SwiftUI
import AVKit

struct PreviewMonitorsView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @State private var selectedMonitor: MonitorType = .program
    
    enum MonitorType {
        case source, program
    }
    
    var body: some View {
        HStack(spacing: 1) {
            // Source Monitor
            VideoMonitorView(
                title: "Source",
                player: projectManager.sourcePlayer,
                isActive: selectedMonitor == .source
            )
            .onTapGesture {
                selectedMonitor = .source
            }
            
            // Program Monitor
            VideoMonitorView(
                title: "Program",
                player: projectManager.programPlayer,
                isActive: selectedMonitor == .program
            )
            .onTapGesture {
                selectedMonitor = .program
            }
        }
        .background(Color.black)
    }
}

struct VideoMonitorView: View {
    let title: String
    let player: AVPlayer
    let isActive: Bool
    
    @State private var currentTime: CMTime = .zero
    @State private var duration: CMTime = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            // Monitor Header
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(isActive ? .accentColor : .secondary)
                Spacer()
                Text(timeDisplay)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            
            // Video Display
            ZStack {
                Color.black
                
                VideoPlayer(player: player)
                    .disabled(true)
                
                // Overlay Controls
                VStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: { seekBackward() }) {
                            Image(systemName: "gobackward.5")
                        }
                        
                        Button(action: { togglePlayback() }) {
                            Image(systemName: player.timeControlStatus == .playing ? "pause.fill" : "play.fill")
                        }
                        
                        Button(action: { seekForward() }) {
                            Image(systemName: "goforward.5")
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                    .opacity(isActive ? 1 : 0)
                }
                .padding()
            }
            
            // Scrubber
            VideoScrubberView(player: player, currentTime: $currentTime, duration: $duration)
                .frame(height: 32)
        }
        .border(isActive ? Color.accentColor : Color.clear, width: 2)
    }
    
    private var timeDisplay: String {
        let current = CMTimeGetSeconds(currentTime)
        let total = CMTimeGetSeconds(duration)
        return "\(TimeFormatter.format(seconds: current)) / \(TimeFormatter.format(seconds: total))"
    }
    
    private func togglePlayback() {
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    private func seekBackward() {
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 5, preferredTimescale: 600))
        player.seek(to: newTime)
    }
    
    private func seekForward() {
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 5, preferredTimescale: 600))
        player.seek(to: newTime)
    }
}

struct VideoScrubberView: View {
    let player: AVPlayer
    @Binding var currentTime: CMTime
    @Binding var duration: CMTime
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                
                // Progress
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: progressWidth(geometry.size.width))
                
                // Playhead
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(x: progressWidth(geometry.size.width) - 6)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let progress = max(0, min(1, value.location.x / geometry.size.width))
                                let newTime = CMTimeMultiplyByFloat64(duration, multiplier: progress)
                                player.seek(to: newTime)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
        .padding(.horizontal, 8)
        .onReceive(player.periodicTimePublisher()) { time in
            if !isDragging {
                currentTime = time
            }
        }
    }
    
    private func progressWidth(_ totalWidth: CGFloat) -> CGFloat {
        guard duration.seconds > 0 else { return 0 }
        return totalWidth * CGFloat(currentTime.seconds / duration.seconds)
    }
}

struct PlaybackControlsView: View {
    @EnvironmentObject var projectManager: ProjectManager
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { projectManager.jumpToStart() }) {
                Image(systemName: "backward.end.fill")
            }
            
            Button(action: { projectManager.stepBackward() }) {
                Image(systemName: "backward.frame.fill")
            }
            
            Button(action: { projectManager.togglePlayback() }) {
                Image(systemName: projectManager.isPlaying ? "pause.fill" : "play.fill")
            }
            .keyboardShortcut(.space, modifiers: [])
            
            Button(action: { projectManager.stepForward() }) {
                Image(systemName: "forward.frame.fill")
            }
            
            Button(action: { projectManager.jumpToEnd() }) {
                Image(systemName: "forward.end.fill")
            }
        }
        .buttonStyle(.plain)
    }
}
