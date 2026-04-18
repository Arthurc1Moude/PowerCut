//
//  MediaBrowserView.swift
//  PowerCut
//
//  Media library and asset management
//

import SwiftUI
import AVFoundation

struct MediaBrowserView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @Binding var selectedItem: MediaItem?
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .grid
    
    enum ViewMode {
        case list, grid
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Media Browser")
                    .font(.headline)
                Spacer()
                Picker("", selection: $viewMode) {
                    Image(systemName: "list.bullet").tag(ViewMode.list)
                    Image(systemName: "square.grid.2x2").tag(ViewMode.grid)
                }
                .pickerStyle(.segmented)
                .frame(width: 80)
            }
            .padding()
            
            // Search
            TextField("Search media...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Divider()
            
            // Media Grid/List
            ScrollView {
                if viewMode == .grid {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                        ForEach(filteredMedia) { item in
                            MediaThumbnailView(item: item, isSelected: selectedItem?.id == item.id)
                                .onTapGesture {
                                    selectedItem = item
                                }
                                .onDrag {
                                    NSItemProvider(object: item.url as NSURL)
                                }
                        }
                    }
                    .padding()
                } else {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredMedia) { item in
                            MediaListRowView(item: item, isSelected: selectedItem?.id == item.id)
                                .onTapGesture {
                                    selectedItem = item
                                }
                        }
                    }
                }
            }
            
            Divider()
            
            // Footer Stats
            HStack {
                Text("\(projectManager.mediaItems.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(totalDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
    
    private var filteredMedia: [MediaItem] {
        if searchText.isEmpty {
            return projectManager.mediaItems
        }
        return projectManager.mediaItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var totalDuration: String {
        let total = projectManager.mediaItems.reduce(0.0) { $0 + $1.duration }
        return TimeFormatter.format(seconds: total)
    }
}

struct MediaThumbnailView: View {
    let item: MediaItem
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                if let thumbnail = item.thumbnail {
                    Image(nsImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: item.type.icon)
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        )
                }
            }
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            
            Text(item.name)
                .font(.caption)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(TimeFormatter.format(seconds: item.duration))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct MediaListRowView: View {
    let item: MediaItem
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: item.type.icon)
                .frame(width: 20)
            
            Text(item.name)
                .lineLimit(1)
            
            Spacer()
            
            Text(TimeFormatter.format(seconds: item.duration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(4)
    }
}
