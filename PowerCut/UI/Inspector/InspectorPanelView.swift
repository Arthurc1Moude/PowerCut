//
//  InspectorPanelView.swift
//  PowerCut
//
//  Properties and effects inspector panel
//

import SwiftUI

struct InspectorPanelView: View {
    @Binding var selectedItem: MediaItem?
    @State private var selectedTab: InspectorTab = .properties
    
    enum InspectorTab: String, CaseIterable {
        case properties = "Properties"
        case effects = "Effects"
        case ai = "AI Tools"
        case export = "Export"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("", selection: $selectedTab) {
                ForEach(InspectorTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            // Content
            ScrollView {
                switch selectedTab {
                case .properties:
                    PropertiesInspectorView(item: selectedItem)
                case .effects:
                    EffectsInspectorView(item: selectedItem)
                case .ai:
                    AIToolsInspectorView(item: selectedItem)
                case .export:
                    ExportInspectorView()
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct PropertiesInspectorView: View {
    let item: MediaItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let item = item {
                InspectorSection(title: "Basic Info") {
                    InfoRow(label: "Name", value: item.name)
                    InfoRow(label: "Duration", value: TimeFormatter.format(seconds: item.duration))
                    InfoRow(label: "Type", value: item.type.rawValue)
                    InfoRow(label: "Size", value: ByteCountFormatter.string(fromByteCount: item.fileSize, countStyle: .file))
                }
                
                if item.type == .video {
                    InspectorSection(title: "Video") {
                        InfoRow(label: "Resolution", value: "\(item.resolution.width)×\(item.resolution.height)")
                        InfoRow(label: "Frame Rate", value: String(format: "%.2f fps", item.frameRate))
                        InfoRow(label: "Codec", value: item.codec)
                    }
                }
                
                if item.type == .audio || item.hasAudio {
                    InspectorSection(title: "Audio") {
                        InfoRow(label: "Sample Rate", value: "\(item.sampleRate) Hz")
                        InfoRow(label: "Channels", value: "\(item.audioChannels)")
                        InfoRow(label: "Bit Rate", value: "\(item.audioBitRate) kbps")
                    }
                }
                
                InspectorSection(title: "Transform") {
                    SliderControl(label: "Position X", value: .constant(0), range: -1000...1000)
                    SliderControl(label: "Position Y", value: .constant(0), range: -1000...1000)
                    SliderControl(label: "Scale", value: .constant(100), range: 0...200, unit: "%")
                    SliderControl(label: "Rotation", value: .constant(0), range: -180...180, unit: "°")
                    SliderControl(label: "Opacity", value: .constant(100), range: 0...100, unit: "%")
                }
            } else {
                Text("No item selected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
    }
}

struct EffectsInspectorView: View {
    let item: MediaItem?
    @State private var effects: [Effect] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InspectorSection(title: "Applied Effects") {
                if effects.isEmpty {
                    Text("No effects applied")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(effects) { effect in
                        EffectRowView(effect: effect)
                    }
                }
            }
            
            InspectorSection(title: "Add Effect") {
                EffectCategoryView(category: "Color", effects: [
                    "Color Correction", "Brightness/Contrast", "Saturation", "Color Grading"
                ])
                
                EffectCategoryView(category: "Blur & Sharpen", effects: [
                    "Gaussian Blur", "Motion Blur", "Sharpen", "Unsharp Mask"
                ])
                
                EffectCategoryView(category: "Distortion", effects: [
                    "Lens Distortion", "Perspective", "Transform", "Warp"
                ])
                
                EffectCategoryView(category: "Time", effects: [
                    "Speed/Duration", "Time Remap", "Freeze Frame", "Reverse"
                ])
            }
        }
        .padding()
    }
}

struct AIToolsInspectorView: View {
    let item: MediaItem?
    @EnvironmentObject var aiOrchestrator: AIOrchestrator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InspectorSection(title: "Content Analysis") {
                AIToolButton(
                    title: "Detect Scenes",
                    icon: "film",
                    description: "Automatically identify scene changes"
                ) {
                    aiOrchestrator.detectScenes()
                }
                
                AIToolButton(
                    title: "Transcribe Audio",
                    icon: "waveform",
                    description: "Generate text transcript from speech"
                ) {
                    aiOrchestrator.transcribeAudio()
                }
                
                AIToolButton(
                    title: "Identify Speakers",
                    icon: "person.2",
                    description: "Detect and label different speakers"
                ) {
                    aiOrchestrator.identifySpeakers()
                }
            }
            
            InspectorSection(title: "Editing Automation") {
                AIToolButton(
                    title: "Remove Silence",
                    icon: "speaker.slash",
                    description: "Cut out silent portions automatically"
                ) {
                    aiOrchestrator.removeSilence()
                }
                
                AIToolButton(
                    title: "Extract Highlights",
                    icon: "star",
                    description: "Find and extract best moments"
                ) {
                    aiOrchestrator.extractHighlights()
                }
                
                AIToolButton(
                    title: "Smart Crop",
                    icon: "crop",
                    description: "Reframe for different aspect ratios"
                ) {
                    aiOrchestrator.smartCrop()
                }
            }
            
            InspectorSection(title: "Content Generation") {
                AIToolButton(
                    title: "Generate Subtitles",
                    icon: "captions.bubble",
                    description: "Create accurate subtitles with timing"
                ) {
                    aiOrchestrator.generateSubtitles()
                }
                
                AIToolButton(
                    title: "Suggest Titles",
                    icon: "textformat",
                    description: "AI-generated title suggestions"
                ) {
                    aiOrchestrator.suggestTitles()
                }
                
                AIToolButton(
                    title: "Generate Thumbnail",
                    icon: "photo",
                    description: "Create engaging thumbnail images"
                ) {
                    aiOrchestrator.generateThumbnail()
                }
            }
            
            InspectorSection(title: "Enhancement") {
                AIToolButton(
                    title: "Audio Cleanup",
                    icon: "waveform.badge.magnifyingglass",
                    description: "Remove noise and enhance clarity"
                ) {
                    aiOrchestrator.cleanupAudio()
                }
                
                AIToolButton(
                    title: "Color Balance",
                    icon: "paintpalette",
                    description: "Automatic color correction"
                ) {
                    aiOrchestrator.autoColorBalance()
                }
            }
        }
        .padding()
    }
}

struct ExportInspectorView: View {
    @State private var selectedPreset: ExportPreset = .youtube1080p
    @State private var customSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InspectorSection(title: "Export Presets") {
                ForEach(ExportPreset.allCases, id: \.self) { preset in
                    Button(action: { selectedPreset = preset }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(preset.name)
                                    .font(.body)
                                Text(preset.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedPreset == preset {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(8)
                        .background(selectedPreset == preset ? Color.accentColor.opacity(0.1) : Color.clear)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Toggle("Custom Settings", isOn: $customSettings)
                .padding(.horizontal)
            
            if customSettings {
                InspectorSection(title: "Video Settings") {
                    Picker("Codec", selection: .constant("H.264")) {
                        Text("H.264").tag("H.264")
                        Text("H.265/HEVC").tag("H.265")
                        Text("ProRes").tag("ProRes")
                    }
                    
                    Picker("Quality", selection: .constant("High")) {
                        Text("Low").tag("Low")
                        Text("Medium").tag("Medium")
                        Text("High").tag("High")
                        Text("Maximum").tag("Maximum")
                    }
                }
                
                InspectorSection(title: "Audio Settings") {
                    Picker("Format", selection: .constant("AAC")) {
                        Text("AAC").tag("AAC")
                        Text("MP3").tag("MP3")
                        Text("PCM").tag("PCM")
                    }
                    
                    Picker("Bitrate", selection: .constant("256")) {
                        Text("128 kbps").tag("128")
                        Text("192 kbps").tag("192")
                        Text("256 kbps").tag("256")
                        Text("320 kbps").tag("320")
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Helper Views

struct InspectorSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
        .font(.caption)
    }
}

struct SliderControl: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var unit: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                Spacer()
                Text("\(Int(value))\(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Slider(value: $value, in: range)
        }
    }
}

struct AIToolButton: View {
    let title: String
    let icon: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 32)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct EffectRowView: View {
    let effect: Effect
    
    var body: some View {
        HStack {
            Image(systemName: "wand.and.stars")
            Text(effect.name)
            Spacer()
            Button(action: {}) {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
        .cornerRadius(6)
    }
}

struct EffectCategoryView: View {
    let category: String
    let effects: [String]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                    Text(category)
                        .font(.subheadline)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                ForEach(effects, id: \.self) { effect in
                    Button(action: {}) {
                        Text(effect)
                            .font(.caption)
                            .padding(.leading, 20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
