//
//  TimelineEngine.swift
//  PowerCut
//
//  Timeline editing operations and logic
//

import Foundation
import AVFoundation

class TimelineEngine {
    static let shared = TimelineEngine()
    
    private init() {}
    
    // MARK: - Clip Operations
    
    func trimClip(_ clip: inout TimelineClip, newInPoint: Double, newOutPoint: Double) {
        guard let mediaItem = clip.mediaItem else { return }
        
        let clampedInPoint = max(0, min(newInPoint, mediaItem.duration))
        let clampedOutPoint = max(clampedInPoint, min(newOutPoint, mediaItem.duration))
        
        clip.inPoint = clampedInPoint
        clip.outPoint = clampedOutPoint
        clip.duration = clampedOutPoint - clampedInPoint
    }
    
    func rippleDelete(clip: TimelineClip, from track: inout TimelineTrack) {
        guard let clipIndex = track.clips.firstIndex(where: { $0.id == clip.id }) else { return }
        
        let deletedClipEnd = clip.startTime + clip.duration
        track.clips.remove(at: clipIndex)
        
        // Shift all clips after the deleted clip
        for i in clipIndex..<track.clips.count {
            track.clips[i].startTime -= clip.duration
        }
    }
    
    func snapToNearestFrame(_ time: Double, frameRate: Double) -> Double {
        let frameDuration = 1.0 / frameRate
        return round(time / frameDuration) * frameDuration
    }
    
    func findNearestSnapPoint(_ time: Double, in timeline: Timeline, threshold: Double = 0.1) -> Double? {
        var snapPoints: [Double] = [0] // Start of timeline
        
        // Collect all clip boundaries
        for track in timeline.tracks {
            for clip in track.clips {
                snapPoints.append(clip.startTime)
                snapPoints.append(clip.startTime + clip.duration)
            }
        }
        
        // Find closest snap point within threshold
        let sortedPoints = snapPoints.sorted()
        for point in sortedPoints {
            if abs(point - time) < threshold {
                return point
            }
        }
        
        return nil
    }
    
    // MARK: - Track Operations
    
    func addTrack(to timeline: inout Timeline, type: TimelineTrack.TrackType, name: String) {
        let newTrack = TimelineTrack(name: name, type: type)
        timeline.tracks.append(newTrack)
    }
    
    func removeTrack(at index: Int, from timeline: inout Timeline) {
        guard index < timeline.tracks.count else { return }
        timeline.tracks.remove(at: index)
    }
    
    func reorderTrack(from sourceIndex: Int, to destIndex: Int, in timeline: inout Timeline) {
        guard sourceIndex < timeline.tracks.count && destIndex < timeline.tracks.count else { return }
        let track = timeline.tracks.remove(at: sourceIndex)
        timeline.tracks.insert(track, at: destIndex)
    }
}
