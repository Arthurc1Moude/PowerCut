//
//  SceneDetector.swift
//  PowerCut
//
//  Basic scene detection using frame difference analysis
//

import Foundation
import AVFoundation
import CoreImage

class SceneDetector {
    static let shared = SceneDetector()
    
    private init() {}
    
    func detectScenes(in asset: AVAsset, threshold: Double = 0.3) async -> [Double] {
        var sceneChanges: [Double] = [0.0] // Always include start
        
        do {
            let duration = try await asset.load(.duration)
            let durationSeconds = CMTimeGetSeconds(duration)
            
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.maximumSize = CGSize(width: 320, height: 180)
            
            var previousImage: CGImage?
            let sampleInterval = 0.5 // Check every 0.5 seconds
            var currentTime = 0.0
            
            while currentTime < durationSeconds {
                let time = CMTime(seconds: currentTime, preferredTimescale: 600)
                
                if let cgImage = try? await imageGenerator.image(at: time).image {
                    if let prevImage = previousImage {
                        let difference = calculateImageDifference(prevImage, cgImage)
                        
                        if difference > threshold {
                            sceneChanges.append(currentTime)
                        }
                    }
                    previousImage = cgImage
                }
                
                currentTime += sampleInterval
            }
            
        } catch {
            // Return empty array on error
        }
        
        return sceneChanges
    }
    
    private func calculateImageDifference(_ image1: CGImage, _ image2: CGImage) -> Double {
        guard image1.width == image2.width && image1.height == image2.height else {
            return 1.0
        }
        
        let ciImage1 = CIImage(cgImage: image1)
        let ciImage2 = CIImage(cgImage: image2)
        
        // Simple pixel-by-pixel comparison
        // In production, use more sophisticated methods like histogram comparison
        let context = CIContext()
        
        guard let data1 = context.jpegRepresentation(of: ciImage1, colorSpace: CGColorSpaceCreateDeviceRGB()),
              let data2 = context.jpegRepresentation(of: ciImage2, colorSpace: CGColorSpaceCreateDeviceRGB()) else {
            return 0.0
        }
        
        // Simple byte difference
        let bytes1 = [UInt8](data1)
        let bytes2 = [UInt8](data2)
        
        var totalDiff = 0
        let count = min(bytes1.count, bytes2.count)
        
        for i in 0..<count {
            totalDiff += abs(Int(bytes1[i]) - Int(bytes2[i]))
        }
        
        return Double(totalDiff) / Double(count * 255)
    }
}
