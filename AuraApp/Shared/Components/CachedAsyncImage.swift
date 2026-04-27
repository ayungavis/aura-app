//
//  CachedAsyncImage.swift
//  AuraApp
//
//  A custom AsyncImage replacement that supports synchronous cache lookups
//  to prevent flickering during navigation transitions.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @State private var loadedImage: UIImage?
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        
        // Synchronous check during init to prevent even a single frame of flickering
        if let url = url {
            let request = URLRequest(url: url)
            if let cachedResponse = URLCache.shared.cachedResponse(for: request),
               let uiImage = UIImage(data: cachedResponse.data) {
                _loadedImage = State(initialValue: uiImage)
            }
        }
    }
    
    var body: some View {
        Group {
            if let uiImage = loadedImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        // 1. Check if it's a local file URL
        if url.isFileURL {
            if let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                self.loadedImage = uiImage
                return
            }
        }
        
        // 2. Check URLCache (Disk/Memory) synchronously for remote URLs
        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let uiImage = UIImage(data: cachedResponse.data) {
            self.loadedImage = uiImage
            return
        }
        
        // 3. If not cached and not local, fetch from network
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response, let uiImage = UIImage(data: data) else { return }
            
            // Store in cache
            let cachedData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedData, for: request)
            
            // Update UI
            DispatchQueue.main.async {
                self.loadedImage = uiImage
            }
        }.resume()
    }
}
