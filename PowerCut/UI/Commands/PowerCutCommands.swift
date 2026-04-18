//
//  PowerCutCommands.swift
//  PowerCut
//
//  Menu commands
//

import SwiftUI

struct PowerCutCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Project...") {
                ProjectManager.shared.createNewProject(name: "Untitled Project")
            }
            .keyboardShortcut("n", modifiers: .command)
            
            Button("Open Project...") {
                // Open project
            }
            .keyboardShortcut("o", modifiers: .command)
        }
        
        CommandMenu("Edit") {
            Button("Cut") {}
                .keyboardShortcut("x", modifiers: .command)
            Button("Copy") {}
                .keyboardShortcut("c", modifiers: .command)
            Button("Paste") {}
                .keyboardShortcut("v", modifiers: .command)
            
            Divider()
            
            Button("Split Clip") {}
                .keyboardShortcut("s", modifiers: .command)
            Button("Delete") {}
                .keyboardShortcut(.delete, modifiers: [])
        }
        
        CommandMenu("AI") {
            Button("Auto-Edit Project") {
                AIOrchestrator.shared.autoEditProject()
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Detect Scenes") {
                AIOrchestrator.shared.detectScenes()
            }
            
            Button("Remove Silence") {
                AIOrchestrator.shared.removeSilence()
            }
            
            Button("Generate Subtitles") {
                AIOrchestrator.shared.generateSubtitles()
            }
        }
    }
}
