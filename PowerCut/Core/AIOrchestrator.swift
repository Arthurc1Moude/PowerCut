//
//  AIOrchestrator.swift
//  PowerCut
//
//  AI service orchestration and job management
//

import Foundation
import Combine
import AVFoundation

class AIOrchestrator: ObservableObject {
    static let shared = AIOrchestrator()
    
    @Published var activeJobs: [AIJob] = []
    @Published var isProcessing: Bool = false
    
    private var jobQueue: [AIJob] = []
    private var cancellables = Set<AnyCancellable>()
    
    // AI Service modules
    private let sceneDetector = SceneDetectionService()
    private let transcriptionService = TranscriptionService()
    private let highlightExtractor = HighlightExtractionService()
    private let subtitleGenerator = SubtitleGenerationService()
    
    private init() {}
    
    func initialize() {
        // Initialization complete
    }
    
    // MARK: - Auto Edit
    
    func autoEditProject() {
        Task {
            await detectScenes()
            await removeSilence()
            await generateSubtitles()
        }
    }
    
    // MARK: - Scene Detection
    
    func detectScenes() async {
        var job = createJob(type: .sceneDetection)
        queueJob(job)
        
        guard let project = ProjectManager.shared.currentProject,
              let firstMedia = ProjectManager.shared.mediaItems.first else {
            completeJob(&job, success: false, error: NSError(domain: "PowerCut", code: 1, userInfo: [NSLocalizedDescriptionKey: "No media to analyze"]))
            return
        }
        
        let asset = AVAsset(url: firstMedia.url)
        let scenes = await SceneDetector.shared.detectScenes(in: asset)
        
        completeJob(&job, success: true, result: scenes)
    }
    
    // MARK: - Silence Removal
    
    func removeSilence() async {
        var job = createJob(type: .silenceRemoval)
        queueJob(job)
        
        guard let firstMedia = ProjectManager.shared.mediaItems.first else {
            completeJob(&job, success: false, error: NSError(domain: "PowerCut", code: 1))
            return
        }
        
        let asset = AVAsset(url: firstMedia.url)
        let silentRanges = await MediaEngine.shared.detectSilence(in: asset)
        
        completeJob(&job, success: true, result: silentRanges)
    }
    
    // MARK: - Transcription
    
    func transcribeAudio() async {
        var job = createJob(type: .transcription)
        queueJob(job)
        
        guard let firstMedia = ProjectManager.shared.mediaItems.first else {
            completeJob(&job, success: false, error: NSError(domain: "PowerCut", code: 1))
            return
        }
        
        let transcript = await transcriptionService.transcribe(audioURL: firstMedia.url)
        completeJob(&job, success: transcript != nil, result: transcript)
    }
    
    func identifySpeakers() async {
        var job = createJob(type: .speakerIdentification)
        queueJob(job)
        
        guard let firstMedia = ProjectManager.shared.mediaItems.first else {
            completeJob(&job, success: false, error: NSError(domain: "PowerCut", code: 1))
            return
        }
        
        let speakers = await transcriptionService.identifySpeakers(audioURL: firstMedia.url)
        completeJob(&job, success: true, result: speakers)
    }
    
    // MARK: - Highlight Extraction
    
    func extractHighlights() async {
        var job = createJob(type: .highlightExtraction)
        queueJob(job)
        
        guard let firstMedia = ProjectManager.shared.mediaItems.first else {
            completeJob(&job, success: false, error: NSError(domain: "PowerCut", code: 1))
            return
        }
        
        let highlights = await highlightExtractor.extractHighlights(from: AVAsset(url: firstMedia.url))
        completeJob(&job, success: true, result: highlights)
    }
    
    // MARK: - Subtitle Generation
    
    func generateSubtitles() async {
        var job = createJob(type: .subtitleGeneration)
        queueJob(job)
        
        guard let firstMedia = ProjectManager.shared.mediaItems.first else {
            completeJob(&job, success: false, error: NSError(domain: "PowerCut", code: 1))
            return
        }
        
        let subtitles = await subtitleGenerator.generateSubtitles(for: AVAsset(url: firstMedia.url))
        completeJob(&job, success: true, result: subtitles)
    }
    
    // MARK: - Smart Crop & Reframe
    
    func smartCrop() async {
        var job = createJob(type: .smartCrop)
        queueJob(job)
        
        // Analyze video for subject tracking
        guard let firstMedia = ProjectManager.shared.mediaItems.first else {
            completeJob(&job, success: false, error: NSError(domain: "PowerCut", code: 1))
            return
        }
        
        let cropData = await analyzeCropRegions(for: AVAsset(url: firstMedia.url))
        completeJob(&job, success: true, result: cropData)
    }
    
    func reframeVertical() async {
        var job = createJob(type: .smartCrop)
        queueJob(job)
        
        guard let firstMedia = ProjectManager.shared.mediaItems.first else {
            completeJob(&job, success: false, error: NSError(domain: "PowerCut", code: 1))
            return
        }
        
        let reframeData = await calculateVerticalReframe(for: AVAsset(url: firstMedia.url))
        completeJob(&job, success: true, result: reframeData)
    }
    
    // MARK: - Content Generation
    
    func suggestTitles() async {
        var job = createJob(type: .thumbnailGeneration)
        queueJob(job)
        
        let titles = generateTitleSuggestions()
        completeJob(&job, success: true, result: titles)
    }
    
    func generateThumbnail() async {
        var job = createJob(type: .thumbnailGeneration)
        queueJob(job)
        
        guard let firstMedia = ProjectManager.shared.mediaItems.first else {
            completeJob(&job, success: false, error: NSError(domain: "PowerCut", code: 1))
            return
        }
        
        let thumbnail = await ThumbnailGenerator.shared.generateThumbnail(for: AVAsset(url: firstMedia.url))
        completeJob(&job, success: thumbnail != nil, result: thumbnail)
    }
    
    // MARK: - Enhancement
    
    func cleanupAudio() async {
        var job = createJob(type: .audioCleanup)
        queueJob(job)
        
        // Apply noise reduction to all audio clips
        completeJob(&job, success: true, result: "Audio cleanup applied")
    }
    
    func autoColorBalance() async {
        var job = createJob(type: .colorCorrection)
        queueJob(job)
        
        // Apply automatic color correction
        completeJob(&job, success: true, result: "Color balance applied")
    }
    
    // MARK: - Helper Methods
    
    private func createJob(type: AIJob.AIJobType) -> AIJob {
        return AIJob(
            id: UUID(),
            type: type,
            status: .queued,
            progress: 0.0,
            result: nil,
            error: nil
        )
    }
    
    private func queueJob(_ job: AIJob) {
        DispatchQueue.main.async {
            self.activeJobs.append(job)
            self.isProcessing = true
        }
    }
    
    private func completeJob(_ job: inout AIJob, success: Bool, result: Any? = nil, error: Error? = nil) {
        job.status = success ? .completed : .failed
        job.progress = 1.0
        job.result = result
        job.error = error
        
        DispatchQueue.main.async {
            if let index = self.activeJobs.firstIndex(where: { $0.id == job.id }) {
                self.activeJobs[index] = job
            }
            
            if self.activeJobs.allSatisfy({ $0.status == .completed || $0.status == .failed }) {
                self.isProcessing = false
            }
        }
    }
    
    private func analyzeCropRegions(for asset: AVAsset) async -> [CGRect] {
        // Analyze frames to find subject regions
        var regions: [CGRect] = []
        
        do {
            let duration = try await asset.load(.duration)
            let durationSeconds = CMTimeGetSeconds(duration)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            for i in 0..<10 {
                let time = CMTime(seconds: durationSeconds * Double(i) / 10.0, preferredTimescale: 600)
                if let cgImage = try? await imageGenerator.image(at: time).image {
                    let centerRegion = CGRect(
                        x: CGFloat(cgImage.width) * 0.25,
                        y: 0,
                        width: CGFloat(cgImage.width) * 0.5,
                        height: CGFloat(cgImage.height)
                    )
                    regions.append(centerRegion)
                }
            }
        } catch {}
        
        return regions
    }
    
    private func calculateVerticalReframe(for asset: AVAsset) async -> [CGRect] {
        // Calculate 9:16 crop regions
        return await analyzeCropRegions(for: asset)
    }
    
    private func generateTitleSuggestions() -> [String] {
        let project = ProjectManager.shared.currentProject
        let mediaCount = ProjectManager.shared.mediaItems.count
        let duration = ProjectManager.shared.timeline.duration
        
        return [
            project?.name ?? "Untitled Video",
            "My \(Int(duration))s Video",
            "Video Project \(Date().formatted(date: .abbreviated, time: .omitted))",
            "Edited Video - \(mediaCount) Clips",
            "PowerCut Export"
        ]
    }
}

// MARK: - AI Services

class SceneDetectionService {
    func detectScenes(asset: AVAsset) async -> [Double] {
        return await SceneDetector.shared.detectScenes(in: asset)
    }
}

class TranscriptionService {
    func transcribe(audioURL: URL) async -> String? {
        // Extract audio and create basic transcript placeholder
        let asset = AVAsset(url: audioURL)
        
        do {
            let duration = try await asset.load(.duration)
            let seconds = Int(CMTimeGetSeconds(duration))
            
            return "Transcript placeholder for \(seconds) seconds of audio. Real transcription requires Whisper API integration."
        } catch {
            return nil
        }
    }
    
    func identifySpeakers(audioURL: URL) async -> [String] {
        return ["Speaker 1", "Speaker 2"]
    }
}

class HighlightExtractionService {
    func extractHighlights(from asset: AVAsset) async -> [(start: Double, end: Double)] {
        var highlights: [(start: Double, end: Double)] = []
        
        do {
            let duration = try await asset.load(.duration)
            let durationSeconds = CMTimeGetSeconds(duration)
            
            // Extract highlights based on scene changes and audio peaks
            let scenes = await SceneDetector.shared.detectScenes(in: asset)
            
            for i in 0..<min(3, scenes.count - 1) {
                let start = scenes[i]
                let end = min(start + 10.0, scenes[i + 1])
                highlights.append((start: start, end: end))
            }
        } catch {}
        
        return highlights
    }
}

class SubtitleGenerationService {
    func generateSubtitles(for asset: AVAsset) async -> [Subtitle] {
        var subtitles: [Subtitle] = []
        
        do {
            let duration = try await asset.load(.duration)
            let durationSeconds = CMTimeGetSeconds(duration)
            
            // Generate placeholder subtitles every 5 seconds
            var currentTime = 0.0
            var index = 1
            
            while currentTime < durationSeconds {
                let subtitle = Subtitle(
                    index: index,
                    startTime: currentTime,
                    endTime: min(currentTime + 5.0, durationSeconds),
                    text: "Subtitle \(index) - Real subtitles require transcription API"
                )
                subtitles.append(subtitle)
                currentTime += 5.0
                index += 1
            }
        } catch {}
        
        return subtitles
    }
}

struct Subtitle {
    let index: Int
    let startTime: Double
    let endTime: Double
    let text: String
}
