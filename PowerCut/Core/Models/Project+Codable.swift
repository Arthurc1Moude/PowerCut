//
//  Project+Codable.swift
//  PowerCut
//
//  Codable conformance for project serialization
//

import Foundation
import SwiftUI

// Make Timeline Codable
extension Timeline: Codable {
    enum CodingKeys: String, CodingKey {
        case id, duration, frameRate, tracks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.duration = try container.decode(Double.self, forKey: .duration)
        self.frameRate = try container.decode(Double.self, forKey: .frameRate)
        
        // Decode tracks - need special handling for ObservableObject
        let trackData = try container.decode([TimelineTrackData].self, forKey: .tracks)
        self.tracks = trackData.map { $0.toTimelineTrack() }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(duration, forKey: .duration)
        try container.encode(frameRate, forKey: .frameRate)
        
        let trackData = tracks.map { TimelineTrackData(from: $0) }
        try container.encode(trackData, forKey: .tracks)
    }
}

// Helper struct for encoding/decoding TimelineTrack
struct TimelineTrackData: Codable {
    let id: UUID
    let name: String
    let type: String
    let clips: [TimelineClip]
    let isMuted: Bool
    let isLocked: Bool
    let volume: Float
    
    init(from track: TimelineTrack) {
        self.id = track.id
        self.name = track.name
        self.type = track.type == .video ? "video" : (track.type == .audio ? "audio" : "subtitle")
        self.clips = track.clips
        self.isMuted = track.isMuted
        self.isLocked = track.isLocked
        self.volume = track.volume
    }
    
    func toTimelineTrack() -> TimelineTrack {
        let trackType: TimelineTrack.TrackType
        switch type {
        case "video": trackType = .video
        case "audio": trackType = .audio
        default: trackType = .subtitle
        }
        
        let track = TimelineTrack(name: name, type: trackType)
        track.clips = clips
        track.isMuted = isMuted
        track.isLocked = isLocked
        track.volume = volume
        return track
    }
}

// Make TimelineClip Codable
extension TimelineClip: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, type, mediaItem, startTime, duration, inPoint, outPoint, colorHex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        let typeString = try container.decode(String.self, forKey: .type)
        switch typeString {
        case "video": self.type = .video
        case "audio": self.type = .audio
        case "subtitle": self.type = .subtitle
        default: self.type = .effect
        }
        
        self.mediaItem = try container.decodeIfPresent(MediaItem.self, forKey: .mediaItem)
        self.startTime = try container.decode(Double.self, forKey: .startTime)
        self.duration = try container.decode(Double.self, forKey: .duration)
        self.inPoint = try container.decode(Double.self, forKey: .inPoint)
        self.outPoint = try container.decode(Double.self, forKey: .outPoint)
        
        let colorHex = try container.decode(String.self, forKey: .colorHex)
        self.color = Color(hex: colorHex) ?? .blue
        self.waveformData = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        let typeString: String
        switch type {
        case .video: typeString = "video"
        case .audio: typeString = "audio"
        case .subtitle: typeString = "subtitle"
        case .effect: typeString = "effect"
        }
        try container.encode(typeString, forKey: .type)
        
        try container.encodeIfPresent(mediaItem, forKey: .mediaItem)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(duration, forKey: .duration)
        try container.encode(inPoint, forKey: .inPoint)
        try container.encode(outPoint, forKey: .outPoint)
        try container.encode(color.toHex(), forKey: .colorHex)
    }
}

// Color hex conversion
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
    
    func toHex() -> String {
        guard let components = NSColor(self).cgColor.components else { return "#0000FF" }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
