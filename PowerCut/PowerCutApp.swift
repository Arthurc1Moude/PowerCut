//
//  PowerCutApp.swift
//  PowerCut - AI-Driven Video Editing Studio
//
//  Professional macOS video editing application with AI automation
//

import SwiftUI
import AVFoundation

@main
struct PowerCutApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var projectManager = ProjectManager.shared
    @StateObject private var aiOrchestrator = AIOrchestrator.shared
    
    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(projectManager)
                .environmentObject(aiOrchestrator)
                .frame(minWidth: 1400, minHeight: 900)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            PowerCutCommands()
        }
        
        Settings {
            SettingsView()
        }
    }
}
