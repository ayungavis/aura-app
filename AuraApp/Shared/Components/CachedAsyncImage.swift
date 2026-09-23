//
//  CachedAsyncImage.swift
//  AuraApp
//
//  AsyncImage replacement that avoids the one-frame flash AsyncImage shows when
//  a view is re-created mid-transition.
//
//  The trick is a synchronous lookup during `init` — but that lookup has to be
//  genuinely cheap, because SwiftUI re-runs `init` on every re-render. So it hits
//  an in-memory NSCache of already-decoded images only. Disk and network work
//  happens in a cancellable `.task`, and decoding stays off the main thread.
//

import SwiftUI

/// Process-wide store of decoded images, keyed by URL.
///
/// `URLCache` holds bytes, not images, so reading from it still costs a disk read
/// plus a JPEG/PNG decode — far too expensive to do synchronously during view
/// construction. This caches the finished `UIImage`.
private nonisolated final class DecodedImageCache: @unchecked Sendable {
  static let shared = DecodedImageCache()

  private let cache: NSCache<NSURL, UIImage> = {
    let cache = NSCache<NSURL, UIImage>()
    cache.countLimit = 150
    // ~64MB of decoded pixels before the cache starts evicting.
    cache.totalCostLimit = 64 * 1024 * 1024
    return cache
  }()

  func image(for url: URL) -> UIImage? {
    cache.object(forKey: url as NSURL)
  }

  func insert(_ image: UIImage, for url: URL) {
    // Approximate decoded byte cost so the limit means something.
    let cost = Int(image.size.width * image.size.height * image.scale * image.scale * 4)
    cache.setObject(image, forKey: url as NSURL, cost: cost)
  }
}

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

    // Memory-only hit: no disk IO, no decode. Safe to do during init.
    if let url, let cached = DecodedImageCache.shared.image(for: url) {
      _loadedImage = State(initialValue: cached)
    }
  }

  var body: some View {
    Group {
      if let loadedImage {
        content(Image(uiImage: loadedImage))
      } else {
        placeholder()
      }
    }
    // `.task(id:)` cancels automatically when the view goes away or the URL
    // changes — the old `dataTask` had no cancellation and could deliver into a
    // recycled cell.
    .task(id: url) {
      await loadImage()
    }
  }

  private func loadImage() async {
    guard let url, loadedImage == nil else { return }

    if let image = await Self.fetch(url) {
      guard !Task.isCancelled else { return }
      DecodedImageCache.shared.insert(image, for: url)
      loadedImage = image
    }
  }

  /// Runs entirely off the main actor: file read, network fetch and decode.
  private static func fetch(_ url: URL) async -> UIImage? {
    if url.isFileURL {
      return await Task.detached(priority: .userInitiated) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)?.preparingForDisplay()
      }.value
    }

    let request = URLRequest(url: url)

    if let cached = URLCache.shared.cachedResponse(for: request) {
      let data = cached.data
      return await Task.detached(priority: .userInitiated) {
        UIImage(data: data)?.preparingForDisplay()
      }.value
    }

    guard let (data, response) = try? await URLSession.shared.data(for: request) else {
      return nil
    }

    URLCache.shared.storeCachedResponse(
      CachedURLResponse(response: response, data: data),
      for: request
    )

    return await Task.detached(priority: .userInitiated) {
      UIImage(data: data)?.preparingForDisplay()
    }.value
  }
}
