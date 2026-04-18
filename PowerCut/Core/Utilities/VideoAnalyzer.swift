//
//  VideoAnalyzer.swift
//  PowerCut
//
//  Video analysis utilities
//

import Foundation
import AVFoundation

class VideoAnalyzer {
    static let shared = VideoAnalyzer()
    
    private init() {}
    
    func analyzeVideo(_ asset: AVAsset) async -> VideoAnalysis {
        var analysis = VideoAnalysis()
        
        do {
            let duration = try await asset.load(.duration)
            analysis.duration = CMTimeGetSeconds(duration)
            
            let tracks = try await asset.load(.tracks)
            
            // Analyze video tracks
            for track in tracks {
                let mediaType = track.mediaType
                
                if mediaType == .video {
                    let size = try await track.load(.naturalSize)
                    let frameRate = try await track.load(.nominalFrameRate)
                    let transform = try await track.load(.preferredTransform)
                    
                    analysis.videoTracks.append(VideoTrackInfo(
                        resolution: size,
                        frameRate: Double(frameRate),
                        transform: transform
                    ))
                } else if mediaType == .audio {
                    analysis.audioTracks.append(AudioTrackInfo(
                        sampleRate: 48000,
                        channels: 2
                    ))
                }
            }
            
            analysis.sceneChanges = await SceneDetector.shared.detectScenes(in: asset)
            
        } catch {
            // Return partial analysis on error
        }
        
        return analysis
    }
    
    func extractMetadata(_ asset: AVAsset) async -> [String: Any] {
        var metadata: [String: Any] = [:]
        
        do {
            let commonMetadata = try await asset.load(.commonMetadata)
            
            for item in commonMetadata {
                if let key = item.commonKey?.rawValue,
                   let value = try await item.load(.value) {
                    metadata[key] = value
                }
            }
        } catch {
            // Return empty metadata on error
        }
        
        return metadata
    }
}

struct VideoAnalysis {
    var duration: Double = 0
    var videoTracks: [VideoTrackInfo] = []
    var audioTracks: [AudioTrackInfo] = []
    var sceneChanges: [Double] = []
}

struct VideoTrackInfo {
    let resolution: CGSize
    let frameRate: Double
    let transform: CGAffineTransform
}

struct AudioTrackInfo {
    let sampleRate: Int
    let channels: Int
}
