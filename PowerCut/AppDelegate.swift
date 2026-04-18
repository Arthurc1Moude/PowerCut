//
//  AppDelegate.swift
//  PowerCut
//

import Cocoa
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request media library access
        requestMediaAccess()
        
        // Initialize core systems
        MediaEngine.shared.initialize()
        AIOrchestrator.shared.initialize()
        
        // Configure appearance
        NSApp.appearance = NSAppearance(named: .darkAqua)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func requestMediaAccess() {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
        AVCaptureDevice.requestAccess(for: .audio) { _ in }
    }
}
