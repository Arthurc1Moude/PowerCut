//
//  ProjectManager.swift
//  PowerCut
//
//  Central project and media management
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

class ProjectManager: ObservableObject {
    static let shared = ProjectManager()
    
    @Published var currentProject: Project?
    @Published var mediaItems: [MediaItem] = []
    @Published var timeline: Timeline = Timeline()
    @Published var isPlaying: Bool = false
    
    let sourcePlayer = AVPlayer()
    let programPlayer = AVPlayer()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe playback state
        programPlayer.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                self?.isPlaying = (status == .playing)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Project Management
    
    func createNewProject(name: String) {
        currentProject = Project(name: name)
        timeline = currentProject!.timeline
        mediaItems = []
    }
    
    func saveProject() {
        guard var project = currentProject else { return }
        project.modifiedDate = Date()
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.init(filenameExtension: "pcproj")!]
        panel.nameFieldStringValue = project.name
        
        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.saveProjectToFile(project, at: url)
            }
        }
    }
    
    private func saveProjectToFile(_ project: Project, at url: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(project)
            try data.write(to: url)
        } catch {
            NSAlert.showError(title: "Save Failed", message: "Could not save project: \(error.localizedDescription)")
        }
    }
    
    func loadProject(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let project = try decoder.decode(Project.self, from: data)
            
            currentProject = project
            timeline = project.timeline
            mediaItems = project.mediaItems
        } catch {
            NSAlert.showError(title: "Load Failed", message: "Could not load project: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Media Import
    
    func importMedia() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.movie, .audio, .image]
        
        panel.begin { [weak self] response in
            if response == .OK {
                for url in panel.urls {
                    self?.processMediaFile(url)
                }
            }
        }
    }
    
    private func processMediaFile(_ url: URL) {
        let asset = AVAsset(url: url)
        
        Task {
            do {
                let duration = try await asset.load(.duration)
                let tracks = try await asset.load(.tracks)
                
                var detectedMediaType: MediaItem.MediaType = .video
                var resolution = CGSize.zero
                var frameRate: Double = 0
                var hasAudio = false
                
                for track in tracks {
                    let trackMediaType = track.mediaType
                    
                    if trackMediaType == .video {
                        let size = try await track.load(.naturalSize)
                        resolution = size
                        frameRate = Double(try await track.load(.nominalFrameRate))
                    } else if trackMediaType == .audio {
                        hasAudio = true
                    }
                }
                
                var mediaItem = MediaItem(
                    id: UUID(),
                    name: url.lastPathComponent,
                    url: url,
                    type: detectedMediaType,
                    duration: duration.seconds,
                    fileSize: try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? 0,
                    dateAdded: Date(),
                    resolution: resolution,
                    frameRate: frameRate,
                    codec: "H.264",
                    hasAudio: hasAudio,
                    sampleRate: 48000,
                    audioChannels: 2,
                    audioBitRate: 256
                )
                
                // Generate thumbnail if video
                if detectedMediaType == .video {
                    mediaItem.thumbnail = await ThumbnailGenerator.shared.generateThumbnail(for: asset)
                }
                
                // Capture the final value
                let finalItem = mediaItem
                
                await MainActor.run {
                    self.mediaItems.append(finalItem)
                }
            } catch {
                await MainActor.run {
                    NSAlert.showError(title: "Import Failed", message: "Could not import \(url.lastPathComponent): \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Playback Control
    
    func togglePlayback() {
        if isPlaying {
            programPlayer.pause()
        } else {
            programPlayer.play()
        }
    }
    
    func jumpToStart() {
        programPlayer.seek(to: .zero)
    }
    
    func jumpToEnd() {
        if let duration = programPlayer.currentItem?.duration {
            programPlayer.seek(to: duration)
        }
    }
    
    func stepForward() {
        let currentTime = programPlayer.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 1.0/30.0, preferredTimescale: 600))
        programPlayer.seek(to: newTime)
    }
    
    func stepBackward() {
        let currentTime = programPlayer.currentTime()
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 1.0/30.0, preferredTimescale: 600))
        programPlayer.seek(to: newTime)
    }
    
    // MARK: - Export
    
    func exportProject() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.mpeg4Movie]
        panel.nameFieldStringValue = currentProject?.name ?? "Untitled"
        
        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.performExport(to: url)
            }
        }
    }
    
    private func performExport(to url: URL) {
        guard let project = currentProject else { return }
        
        ExportEngine.shared.exportVideo(
            timeline: timeline,
            preset: .youtube1080p,
            outputURL: url,
            progressHandler: { progress in
                // Progress handled by UI
            },
            completion: { result in
                switch result {
                case .success(let outputURL):
                    NSWorkspace.shared.activateFileViewerSelecting([outputURL])
                case .failure(let error):
                    NSAlert.showError(title: "Export Failed", message: error.localizedDescription)
                }
            }
        )
    }
    
    // MARK: - Timeline Operations
    
    func addClipToTimeline(_ mediaItem: MediaItem, at trackIndex: Int, startTime: Double) {
        guard trackIndex < timeline.tracks.count else { return }
        
        let clip = TimelineClip(
            name: mediaItem.name,
            type: mediaItem.type == .video ? .video : .audio,
            mediaItem: mediaItem,
            startTime: startTime,
            duration: mediaItem.duration
        )
        
        timeline.tracks[trackIndex].clips.append(clip)
        timeline.duration = max(timeline.duration, startTime + mediaItem.duration)
    }
    
    func removeClip(_ clipId: UUID, from trackIndex: Int) {
        guard trackIndex < timeline.tracks.count else { return }
        timeline.tracks[trackIndex].clips.removeAll { $0.id == clipId }
        recalculateTimelineDuration()
    }
    
    func splitClip(_ clipId: UUID, at time: Double, in trackIndex: Int) {
        guard trackIndex < timeline.tracks.count else { return }
        guard let clipIndex = timeline.tracks[trackIndex].clips.firstIndex(where: { $0.id == clipId }) else { return }
        
        let originalClip = timeline.tracks[trackIndex].clips[clipIndex]
        let splitPoint = time - originalClip.startTime
        
        guard splitPoint > 0 && splitPoint < originalClip.duration else { return }
        
        // Create first part
        var firstPart = originalClip
        firstPart.duration = splitPoint
        firstPart.outPoint = originalClip.inPoint + splitPoint
        
        // Create second part
        var secondPart = TimelineClip(
            name: originalClip.name,
            type: originalClip.type,
            mediaItem: originalClip.mediaItem,
            startTime: originalClip.startTime + splitPoint,
            duration: originalClip.duration - splitPoint
        )
        secondPart.inPoint = originalClip.inPoint + splitPoint
        secondPart.outPoint = originalClip.outPoint
        
        // Replace original with split clips
        timeline.tracks[trackIndex].clips[clipIndex] = firstPart
        timeline.tracks[trackIndex].clips.insert(secondPart, at: clipIndex + 1)
    }
    
    func moveClip(_ clipId: UUID, from sourceTrack: Int, to destTrack: Int, newStartTime: Double) {
        guard sourceTrack < timeline.tracks.count && destTrack < timeline.tracks.count else { return }
        guard let clipIndex = timeline.tracks[sourceTrack].clips.firstIndex(where: { $0.id == clipId }) else { return }
        
        var clip = timeline.tracks[sourceTrack].clips.remove(at: clipIndex)
        clip.startTime = newStartTime
        timeline.tracks[destTrack].clips.append(clip)
        
        recalculateTimelineDuration()
    }
    
    private func recalculateTimelineDuration() {
        var maxDuration: Double = 0
        for track in timeline.tracks {
            for clip in track.clips {
                maxDuration = max(maxDuration, clip.startTime + clip.duration)
            }
        }
        timeline.duration = maxDuration
    }
}
