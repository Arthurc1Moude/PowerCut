//
//  SettingsView.swift
//  PowerCut
//
//  Application settings
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general
    
    enum SettingsTab: String, CaseIterable {
        case general = "General"
        case playback = "Playback"
        case ai = "AI Services"
        case export = "Export"
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(SettingsTab.general)
            
            PlaybackSettingsView()
                .tabItem {
                    Label("Playback", systemImage: "play.circle")
                }
                .tag(SettingsTab.playback)
            
            AISettingsView()
                .tabItem {
                    Label("AI Services", systemImage: "wand.and.stars")
                }
                .tag(SettingsTab.ai)
            
            ExportSettingsView()
                .tabItem {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .tag(SettingsTab.export)
        }
        .frame(width: 600, height: 400)
    }
}

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Text("General Settings")
        }
        .padding()
    }
}

struct PlaybackSettingsView: View {
    var body: some View {
        Form {
            Text("Playback Settings")
        }
        .padding()
    }
}

struct AISettingsView: View {
    @State private var apiKey = ""
    
    var body: some View {
        Form {
            Section("API Configuration") {
                TextField("OpenAI API Key", text: $apiKey)
                Text("Configure AI service providers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct ExportSettingsView: View {
    var body: some View {
        Form {
            Text("Export Settings")
        }
        .padding()
    }
}
