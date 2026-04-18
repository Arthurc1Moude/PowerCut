//
//  ThumbnailGenerator.swift
//  PowerCut
//
//  Generate thumbnails from video files
//

import Foundation
import AVFoundation
import AppKit

class ThumbnailGenerator {
    static let shared = ThumbnailGenerator()
    
    private init() {}
    
    func generateThumbnail(for asset: AVAsset, at time: CMTime = .zero) async -> NSImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 320, height: 180)
        
        do {
            let cgImage = try await imageGenerator.image(at: time).image
            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            return nsImage
        } catch {
            return nil
        }
    }
    
    func generateThumbnails(for asset: AVAsset, count: Int) async -> [NSImage] {
        var thumbnails: [NSImage] = []
        
        do {
            let duration = try await asset.load(.duration)
            let durationSeconds = CMTimeGetSeconds(duration)
            
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.maximumSize = CGSize(width: 160, height: 90)
            
            for i in 0..<count {
                let timeSeconds = (durationSeconds / Double(count)) * Double(i)
                let time = CMTime(seconds: timeSeconds, preferredTimescale: 600)
                
                if let thumbnail = try? await imageGenerator.image(at: time).image {
                    let nsImage = NSImage(cgImage: thumbnail, size: NSSize(width: thumbnail.width, height: thumbnail.height))
                    thumbnails.append(nsImage)
                }
            }
        } catch {
            // Return empty array on error
        }
        
        return thumbnails
    }
}
