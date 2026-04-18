//
//  MediaEngine.swift
//  PowerCut
//
//  Core media processing and playback engine
//

import Foundation
import AVFoundation
import Metal
import MetalKit

class MediaEngine {
    static let shared = MediaEngine()
    
    private var metalDevice: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    
    private init() {}
    
    func initialize() {
        setupMetal()
    }
    
    private func setupMetal() {
        metalDevice = MTLCreateSystemDefaultDevice()
        commandQueue = metalDevice?.makeCommandQueue()
    }
    
    // MARK: - Video Processing
    
    func processVideoFrame(_ pixelBuffer: CVPixelBuffer, brightness: Float = 0.0, contrast: Float = 1.0, saturation: Float = 1.0) -> CVPixelBuffer? {
        guard let device = metalDevice, let commandQueue = commandQueue else {
            return pixelBuffer
        }
        
        // For now, return original buffer
        // Real implementation would use Metal compute shaders for color correction
        return pixelBuffer
    }
    
    func applyEffect(to pixelBuffer: CVPixelBuffer, effect: VideoEffect) -> CVPixelBuffer? {
        switch effect {
        case .blur(let radius):
            return applyBlur(to: pixelBuffer, radius: radius)
        case .sharpen(let intensity):
            return applySharpen(to: pixelBuffer, intensity: intensity)
        case .colorCorrection(let brightness, let contrast, let saturation):
            return processVideoFrame(pixelBuffer, brightness: brightness, contrast: contrast, saturation: saturation)
        }
    }
    
    private func applyBlur(to pixelBuffer: CVPixelBuffer, radius: Float) -> CVPixelBuffer? {
        // Metal-based Gaussian blur implementation would go here
        return pixelBuffer
    }
    
    private func applySharpen(to pixelBuffer: CVPixelBuffer, intensity: Float) -> CVPixelBuffer? {
        // Metal-based sharpen implementation would go here
        return pixelBuffer
    }
    
    // MARK: - Audio Processing
    
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer, volume: Float = 1.0, normalize: Bool = false) -> AVAudioPCMBuffer? {
        guard let channelData = buffer.floatChannelData else { return buffer }
        
        let frameLength = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        
        for channel in 0..<channelCount {
            let samples = channelData[channel]
            
            if normalize {
                // Find peak
                var peak: Float = 0.0
                for frame in 0..<frameLength {
                    peak = max(peak, abs(samples[frame]))
                }
                
                // Normalize
                if peak > 0 {
                    let normalizeFactor = 1.0 / peak
                    for frame in 0..<frameLength {
                        samples[frame] *= normalizeFactor * volume
                    }
                }
            } else {
                // Apply volume
                for frame in 0..<frameLength {
                    samples[frame] *= volume
                }
            }
        }
        
        return buffer
    }
    
    func removeNoise(from buffer: AVAudioPCMBuffer, threshold: Float = 0.01) -> AVAudioPCMBuffer? {
        guard let channelData = buffer.floatChannelData else { return buffer }
        
        let frameLength = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        
        for channel in 0..<channelCount {
            let samples = channelData[channel]
            
            for frame in 0..<frameLength {
                if abs(samples[frame]) < threshold {
                    samples[frame] = 0.0
                }
            }
        }
        
        return buffer
    }
    
    // MARK: - Waveform Generation
    
    func generateWaveform(for asset: AVAsset, samples: Int = 100) async -> [CGFloat] {
        do {
            let audioTracks = try await asset.load(.tracks).filter { track in
                try await track.load(.mediaType) == .audio
            }
            
            guard let audioTrack = audioTracks.first else {
                return Array(repeating: 0, count: samples)
            }
            
            // Create asset reader
            let assetReader = try AVAssetReader(asset: asset)
            let outputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsNonInterleaved: false
            ]
            
            let trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
            assetReader.add(trackOutput)
            
            guard assetReader.startReading() else {
                return Array(repeating: 0, count: samples)
            }
            
            var waveformData: [CGFloat] = []
            var allSamples: [Int16] = []
            
            // Read all audio samples
            while let sampleBuffer = trackOutput.copyNextSampleBuffer() {
                guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
                
                let length = CMBlockBufferGetDataLength(blockBuffer)
                var data = Data(count: length)
                
                data.withUnsafeMutableBytes { bytes in
                    CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: bytes.baseAddress!)
                }
                
                let samples = data.withUnsafeBytes { bytes in
                    Array(bytes.bindMemory(to: Int16.self))
                }
                
                allSamples.append(contentsOf: samples)
            }
            
            // Downsample to requested number of samples
            if allSamples.isEmpty {
                return Array(repeating: 0, count: samples)
            }
            
            let samplesPerBucket = max(1, allSamples.count / samples)
            
            for i in 0..<samples {
                let startIndex = i * samplesPerBucket
                let endIndex = min(startIndex + samplesPerBucket, allSamples.count)
                
                if startIndex < allSamples.count {
                    let bucketSamples = allSamples[startIndex..<endIndex]
                    let maxAmplitude = bucketSamples.map { abs($0) }.max() ?? 0
                    let normalized = CGFloat(maxAmplitude) / CGFloat(Int16.max)
                    waveformData.append(normalized)
                } else {
                    waveformData.append(0)
                }
            }
            
            return waveformData
            
        } catch {
            return Array(repeating: 0, count: samples)
        }
    }
    
    func detectSilence(in asset: AVAsset, threshold: Float = 0.01) async -> [(start: Double, end: Double)] {
        var silentRanges: [(start: Double, end: Double)] = []
        
        do {
            let audioTracks = try await asset.load(.tracks).filter { track in
                try await track.load(.mediaType) == .audio
            }
            
            guard let audioTrack = audioTracks.first else {
                return silentRanges
            }
            
            let assetReader = try AVAssetReader(asset: asset)
            let outputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: true,
                AVLinearPCMIsNonInterleaved: false
            ]
            
            let trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
            assetReader.add(trackOutput)
            
            guard assetReader.startReading() else {
                return silentRanges
            }
            
            var currentTime: Double = 0
            var silenceStart: Double? = nil
            let sampleRate: Double = 48000 // Assume 48kHz
            
            while let sampleBuffer = trackOutput.copyNextSampleBuffer() {
                guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
                
                let length = CMBlockBufferGetDataLength(blockBuffer)
                var data = Data(count: length)
                
                data.withUnsafeMutableBytes { bytes in
                    CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: bytes.baseAddress!)
                }
                
                let samples = data.withUnsafeBytes { bytes in
                    Array(bytes.bindMemory(to: Float.self))
                }
                
                for sample in samples {
                    let isSilent = abs(sample) < threshold
                    
                    if isSilent && silenceStart == nil {
                        silenceStart = currentTime
                    } else if !isSilent && silenceStart != nil {
                        silentRanges.append((start: silenceStart!, end: currentTime))
                        silenceStart = nil
                    }
                    
                    currentTime += 1.0 / sampleRate
                }
            }
            
            // Close any open silence range
            if let start = silenceStart {
                silentRanges.append((start: start, end: currentTime))
            }
            
        } catch {
            // Return empty array on error
        }
        
        return silentRanges
    }
}

enum VideoEffect {
    case blur(radius: Float)
    case sharpen(intensity: Float)
    case colorCorrection(brightness: Float, contrast: Float, saturation: Float)
}
}
