//
//  PlaceThumbnail.swift
//  AuraApp
//
//  MapKit exposes no place photos, so each row gets the closest thing it does
//  offer: a Look Around (street-level) image where Apple has coverage, or else
//  a small map of the spot. Either one tells rows apart at a glance, which a
//  repeated category icon doesn't.
//

import MapKit
import SwiftUI

struct PlaceThumbnail: View {
  let place: Place
  var size: CGFloat = 80

  @State private var thumbnail: PlaceThumbnailLoader.Thumbnail?
  @Environment(\.displayScale) private var displayScale

  var body: some View {
    ZStack {
      Rectangle().fill(Color(UIColor.systemGray6))

      if let thumbnail {
        Image(uiImage: thumbnail.image)
          .resizable()
          .scaledToFill()
          .transition(.opacity)

        if thumbnail.kind == .map {
          // The place sits at the centre of the snapshot.
          Image(systemName: place.symbolName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(.red, in: Circle())
            .overlay(Circle().stroke(.white, lineWidth: 1.5))
            .shadow(radius: 2)
        }
      } else {
        Image(systemName: place.symbolName)
          .font(.system(size: 26, weight: .light))
          .foregroundStyle(.secondary)
      }
    }
    .frame(width: size, height: size)
    .clipped()
    .animation(.easeIn(duration: 0.25), value: thumbnail?.image)
    .task(id: place.id) {
      thumbnail = await PlaceThumbnailLoader.shared.thumbnail(
        for: place.mapItem,
        size: CGSize(width: size, height: size),
        scale: displayScale
      )
    }
  }
}

/// Renders and memoises thumbnails, so scrolling back up doesn't re-render them.
@MainActor
final class PlaceThumbnailLoader {
  static let shared = PlaceThumbnailLoader()

  struct Thumbnail {
    enum Kind { case lookAround, map }
    let image: UIImage
    let kind: Kind
  }

  private var cache: [String: Thumbnail] = [:]

  func thumbnail(for item: MKMapItem, size: CGSize, scale: CGFloat) async -> Thumbnail? {
    let coordinate = item.location.coordinate
    let key = "\(coordinate.latitude),\(coordinate.longitude)"
    if let cached = cache[key] { return cached }

    var result = await lookAround(for: item, size: size)
    if result == nil {
      result = await mapSnapshot(of: coordinate, size: size, scale: scale)
    }
    if let result { cache[key] = result }
    return result
  }

  private func lookAround(for item: MKMapItem, size: CGSize) async -> Thumbnail? {
    // No scene simply means no Look Around coverage here (most of Bali, for one).
    guard let scene = try? await MKLookAroundSceneRequest(mapItem: item).scene else { return nil }

    let options = MKLookAroundSnapshotter.Options()
    options.size = size
    guard let snapshot = try? await MKLookAroundSnapshotter(scene: scene, options: options).snapshot else {
      return nil
    }
    return Thumbnail(image: snapshot.image, kind: .lookAround)
  }

  private func mapSnapshot(of coordinate: CLLocationCoordinate2D, size: CGSize, scale: CGFloat) async -> Thumbnail? {
    let options = MKMapSnapshotter.Options()
    options.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
    options.size = size
    options.scale = scale
    options.pointOfInterestFilter = .excludingAll
    // The app forces light mode; match it rather than the system appearance.
    options.traitCollection = UITraitCollection(userInterfaceStyle: .light)

    guard let snapshot = try? await MKMapSnapshotter(options: options).start() else { return nil }
    return Thumbnail(image: snapshot.image, kind: .map)
  }
}
