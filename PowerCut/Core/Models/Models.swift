//
//  Models.swift
//  PowerCut
//
//  Core data models
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - Media Item

struct MediaItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let url: URL
    let type: MediaType
    let duration: Double
    let fileSize: Int64
    let dateAdded: Date
    
    // Video properties
    let resolution: CGSize
    let frameRate: Double
    let codec: String
    
    // Audio properties
    let hasAudio: Bool
    let sampleRate: Int
    let audioChannels: Int
    let audioBitRate: Int
    
    var thumbnail: NSImage?
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, type, duration, fileSize, dateAdded
        case resolution, frameRate, codec
        case hasAudio, sampleRate, audioChannels, audioBitRate
    }
    
    init(id: UUID, name: String, url: URL, type: MediaType, duration: Double, fileSize: Int64, dateAdded: Date, resolution: CGSize, frameRate: Double, codec: String, hasAudio: Bool, sampleRate: Int, audioChannels: Int, audioBitRate: Int) {
        self.id = id
        self.name = name
        self.url = url
        self.type = type
        self.duration = duration
        self.fileSize = fileSize
        self.dateAdded = dateAdded
        self.resolution = resolution
        self.frameRate = frameRate
        self.codec = codec
        self.hasAudio = hasAudio
        self.sampleRate = sampleRate
        self.audioChannels = audioChannels
        self.audioBitRate = audioBitRate
        self.thumbnail = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(URL.self, forKey: .url)
        type = try container.decode(MediaType.self, forKey: .type)
        duration = try container.decode(Double.self, forKey: .duration)
        fileSize = try container.decode(Int64.self, forKey: .fileSize)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        resolution = try container.decode(CGSize.self, forKey: .resolution)
        frameRate = try container.decode(Double.self, forKey: .frameRate)
        codec = try container.decode(String.self, forKey: .codec)
        hasAudio = try container.decode(Bool.self, forKey: .hasAudio)
        sampleRate = try container.decode(Int.self, forKey: .sampleRate)
        audioChannels = try container.decode(Int.self, forKey: .audioChannels)
        audioBitRate = try container.decode(Int.self, forKey: .audioBitRate)
        thumbnail = nil // Thumbnails regenerated on load
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(type, forKey: .type)
        try container.encode(duration, forKey: .duration)
        try container.encode(fileSize, forKey: .fileSize)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(resolution, forKey: .resolution)
        try container.encode(frameRate, forKey: .frameRate)
        try container.encode(codec, forKey: .codec)
        try container.encode(hasAudio, forKey: .hasAudio)
        try container.encode(sampleRate, forKey: .sampleRate)
        try container.encode(audioChannels, forKey: .audioChannels)
        try container.encode(audioBitRate, forKey: .audioBitRate)
    }
    
    enum MediaType: String, Codable {
        case video, audio, image
        
        var icon: String {
            switch self {
            case .video: return "film"
            case .audio: return "waveform"
            case .image: return "photo"
            }
        }
    }
}

// MARK: - Timeline Models

struct Timeline: Identifiable {
    let id: UUID
    var tracks: [TimelineTrack]
    var duration: Double
    var frameRate: Double
    
    init() {
        self.id = UUID()
        self.tracks = [
            TimelineTrack(name: "Video 1", type: .video),
            TimelineTrack(name: "Audio 1", type: .audio),
            TimelineTrack(name: "Subtitles", type: .subtitle)
        ]
        self.duration = 0
        self.frameRate = 30.0
    }
}

class TimelineTrack: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    let type: TrackType
    @Published var clips: [TimelineClip]
    @Published var isMuted: Bool
    @Published var isLocked: Bool
    @Published var volume: Float
    
    enum TrackType {
        case video, audio, subtitle
        
        var icon: String {
            switch self {
            case .video: return "film"
            case .audio: return "waveform"
            case .subtitle: return "captions.bubble"
            }
        }
    }
    
    init(name: String, type: TrackType) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.clips = []
        self.isMuted = false
        self.isLocked = false
        self.volume = 1.0
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    func toggleLock() {
        isLocked.toggle()
    }
}

struct TimelineClip: Identifiable {
    let id: UUID
    let name: String
    let type: ClipType
    let mediaItem: MediaItem?
    var startTime: Double
    var duration: Double
    var inPoint: Double
    var outPoint: Double
    var color: Color
    var waveformData: [CGFloat]?
    
    enum ClipType {
        case video, audio, subtitle, effect
    }
    
    init(name: String, type: ClipType, mediaItem: MediaItem?, startTime: Double, duration: Double) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.mediaItem = mediaItem
        self.startTime = startTime
        self.duration = duration
        self.inPoint = 0
        self.outPoint = duration
        
        switch type {
        case .video:
            self.color = .blue
        case .audio:
            self.color = .green
        case .subtitle:
            self.color = .purple
        case .effect:
            self.color = .orange
        }
    }
}

// MARK: - Effect

struct Effect: Identifiable {
    let id: UUID
    let name: String
    let category: String
    var parameters: [String: Any]
    var isEnabled: Bool
    
    init(name: String, category: String) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.parameters = [:]
        self.isEnabled = true
    }
}

// MARK: - Export Preset

enum ExportPreset: CaseIterable {
    case youtube1080p
    case youtube4k
    case instagram
    case tiktok
    case twitter
    case podcast
    case custom
    
    var name: String {
        switch self {
        case .youtube1080p: return "YouTube 1080p"
        case .youtube4k: return "YouTube 4K"
        case .instagram: return "Instagram Reel"
        case .tiktok: return "TikTok"
        case .twitter: return "Twitter"
        case .podcast: return "Podcast Audio"
        case .custom: return "Custom"
        }
    }
    
    var description: String {
        switch self {
        case .youtube1080p: return "1920×1080, H.264, 60fps"
        case .youtube4k: return "3840×2160, H.265, 60fps"
        case .instagram: return "1080×1920, H.264, 30fps"
        case .tiktok: return "1080×1920, H.264, 30fps"
        case .twitter: return "1280×720, H.264, 30fps"
        case .podcast: return "Audio only, AAC, 256kbps"
        case .custom: return "Configure manually"
        }
    }
}

// MARK: - AI Job

struct AIJob: Identifiable {
    let id: UUID
    let type: AIJobType
    var status: JobStatus
    var progress: Double
    var result: Any?
    var error: Error?
    
    enum AIJobType {
        case sceneDetection
        case silenceRemoval
        case transcription
        case speakerIdentification
        case highlightExtraction
        case subtitleGeneration
        case smartCrop
        case thumbnailGeneration
        case audioCleanup
        case colorCorrection
    }
    
    enum JobStatus {
        case queued, processing, completed, failed
    }
}

// MARK: - Project

struct Project: Codable {
    let id: UUID
    var name: String
    var timeline: Timeline
    var mediaItems: [MediaItem]
    var createdDate: Date
    var modifiedDate: Date
    var frameRate: Double
    var resolution: CGSize
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.timeline = Timeline()
        self.mediaItems = []
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.frameRate = 30.0
        self.resolution = CGSize(width: 1920, height: 1080)
    }
}
