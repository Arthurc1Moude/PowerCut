//
//  FileManager+Extensions.swift
//  PowerCut
//
//  File management utilities
//

import Foundation

extension FileManager {
    static func createProjectDirectory() -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let projectsURL = documentsURL.appendingPathComponent("PowerCut Projects", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: projectsURL.path) {
            try? FileManager.default.createDirectory(at: projectsURL, withIntermediateDirectories: true)
        }
        
        return projectsURL
    }
    
    static func createCacheDirectory() -> URL? {
        guard let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let powerCutCacheURL = cachesURL.appendingPathComponent("PowerCut", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: powerCutCacheURL.path) {
            try? FileManager.default.createDirectory(at: powerCutCacheURL, withIntermediateDirectories: true)
        }
        
        return powerCutCacheURL
    }
    
    static func clearCache() {
        guard let cacheURL = createCacheDirectory() else { return }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            for fileURL in contents {
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            // Silently fail cache clear
        }
    }
}
