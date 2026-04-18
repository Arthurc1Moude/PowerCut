//
//  ExportEngine.swift
//  PowerCut
//
//  Video export and rendering engine
//

import Foundation
import AVFoundation

class ExportEngine {
    static let shared = ExportEngine()
    
    private init() {}
    
    func exportVideo(
        timeline: Timeline,
        preset: ExportPreset,
        outputURL: URL,
        progressHandler: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        Task {
            do {
                let composition = try await buildComposition(from: timeline)
                try await renderComposition(composition, to: outputURL, preset: preset, progressHandler: progressHandler)
                completion(.success(outputURL))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func buildComposition(from timeline: Timeline) async throws -> AVMutableComposition {
        let composition = AVMutableComposition()
        
        // Process video tracks
        for track in timeline.tracks where track.type == .video {
            guard let compositionTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
            ) else {
                throw ExportError.trackCreationFailed
            }
            
            // Sort clips by start time
            let sortedClips = track.clips.sorted { $0.startTime < $1.startTime }
            
            for clip in sortedClips {
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
                
                try compositionTrack.insertTimeRange(
                    timeRange,
                    of: assetTrack,
                    at: insertTime
                )
            }
        }
        
        // Process audio tracks
        for track in timeline.tracks where track.type == .audio {
            guard let compositionTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            ) else {
                throw ExportError.trackCreationFailed
            }
            
            let sortedClips = track.clips.sorted { $0.startTime < $1.startTime }
            
            for clip in sortedClips {
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
                
                try compositionTrack.insertTimeRange(
                    timeRange,
                    of: assetTrack,
                    at: insertTime
                )
                
                // Apply volume if track is not muted
                if !track.isMuted {
                    let audioMix = AVMutableAudioMix()
                    let audioMixParam = AVMutableAudioMixInputParameters(track: compositionTrack)
                    audioMixParam.setVolume(track.volume, at: insertTime)
                    audioMix.inputParameters = [audioMixParam]
                }
            }
        }
        
        return composition
    }
    
    private func renderComposition(
        _ composition: AVMutableComposition,
        to outputURL: URL,
        preset: ExportPreset,
        progressHandler: @escaping (Double) -> Void
    ) async throws {
        // Remove existing file if it exists
        try? FileManager.default.removeItem(at: outputURL)
        
        let presetName = getPresetName(for: preset)
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: presetName
        ) else {
            throw ExportError.sessionCreationFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        // Configure video composition for custom resolutions
        if let videoComposition = createVideoComposition(for: composition, preset: preset) {
            exportSession.videoComposition = videoComposition
        }
        
        // Monitor progress
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            progressHandler(Double(exportSession.progress))
        }
        
        await exportSession.export()
        
        timer.invalidate()
        
        switch exportSession.status {
        case .completed:
            progressHandler(1.0)
        case .failed:
            throw exportSession.error ?? ExportError.exportFailed
        case .cancelled:
            throw ExportError.exportCancelled
        default:
            throw ExportError.exportFailed
        }
    }
    
    private func getPresetName(for preset: ExportPreset) -> String {
        switch preset {
        case .youtube4k:
            return AVAssetExportPreset3840x2160
        case .youtube1080p:
            return AVAssetExportPreset1920x1080
        case .instagram, .tiktok:
            return AVAssetExportPreset1920x1080
        case .twitter:
            return AVAssetExportPreset1280x720
        case .podcast:
            return AVAssetExportPresetAppleM4A
        case .custom:
            return AVAssetExportPresetHighestQuality
        }
    }
    
    private func createVideoComposition(for composition: AVMutableComposition, preset: ExportPreset) -> AVMutableVideoComposition? {
        let videoComposition = AVMutableVideoComposition()
        
        // Set frame rate
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        // Set render size based on preset
        switch preset {
        case .youtube4k:
            videoComposition.renderSize = CGSize(width: 3840, height: 2160)
        case .youtube1080p:
            videoComposition.renderSize = CGSize(width: 1920, height: 1080)
        case .instagram, .tiktok:
            videoComposition.renderSize = CGSize(width: 1080, height: 1920) // Vertical
        case .twitter:
            videoComposition.renderSize = CGSize(width: 1280, height: 720)
        case .podcast:
            return nil // Audio only
        case .custom:
            videoComposition.renderSize = CGSize(width: 1920, height: 1080)
        }
        
        // Create instruction for each video track
        guard let videoTrack = composition.tracks(withMediaType: .video).first else {
            return nil
        }
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // Apply transform for vertical videos if needed
        if preset == .instagram || preset == .tiktok {
            let transform = CGAffineTransform(scaleX: 1080.0 / 1920.0, y: 1920.0 / 1080.0)
            layerInstruction.setTransform(transform, at: .zero)
        }
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        return videoComposition
    }
    
    enum ExportError: Error {
        case sessionCreationFailed
        case exportFailed
        case exportCancelled
        case trackCreationFailed
    }
}
