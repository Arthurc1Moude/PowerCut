//
//  PlaybackEngine.swift
//  PowerCut
//
//  Timeline playback engine
//

import Foundation
import AVFoundation

class PlaybackEngine {
    static let shared = PlaybackEngine()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    private init() {}
    
    func loadTimeline(_ timeline: Timeline) async throws {
        let composition = try await buildPlaybackComposition(from: timeline)
        
        playerItem = AVPlayerItem(asset: composition)
        player = AVPlayer(playerItem: playerItem)
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time)
    }
    
    func getCurrentTime() -> CMTime {
        return player?.currentTime() ?? .zero
    }
    
    private func buildPlaybackComposition(from timeline: Timeline) async throws -> AVMutableComposition {
        let composition = AVMutableComposition()
        
        // Add video tracks
        for track in timeline.tracks where track.type == .video {
            guard let compositionTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
            ) else {
                continue
            }
            
            for clip in track.clips.sorted(by: { $0.startTime < $1.startTime }) {
                guard let mediaItem = clip.mediaItem else { continue }
                
                let asset = AVAsset(url: mediaItem.url)
                let assetTracks = try await asset.load(.tracks)
                
                guard let assetTrack = assetTracks.first(where: { track in
                    track.mediaType == .video
                }) else {
                    continue
                }
                
                let timeRange = CMTimeRange(
                    start: CMTime(seconds: clip.inPoint, preferredTimescale: 600),
                    duration: CMTime(seconds: clip.duration, preferredTimescale: 600)
                )
                
                let insertTime = CMTime(seconds: clip.startTime, preferredTimescale: 600)
                
                try? compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: insertTime)
            }
        }
        
        // Add audio tracks
        for track in timeline.tracks where track.type == .audio && !track.isMuted {
            guard let compositionTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            ) else {
                continue
            }
            
            for clip in track.clips.sorted(by: { $0.startTime < $1.startTime }) {
                guard let mediaItem = clip.mediaItem else { continue }
                
                let asset = AVAsset(url: mediaItem.url)
                let assetTracks = try await asset.load(.tracks)
                
                guard let assetTrack = assetTracks.first(where: { track in
                    track.mediaType == .audio
                }) else {
                    continue
                }
                
                let timeRange = CMTimeRange(
                    start: CMTime(seconds: clip.inPoint, preferredTimescale: 600),
                    duration: CMTime(seconds: clip.duration, preferredTimescale: 600)
                )
                
                let insertTime = CMTime(seconds: clip.startTime, preferredTimescale: 600)
                
                try? compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: insertTime)
            }
        }
        
        return composition
    }
}
