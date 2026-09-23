//
//  Place.swift
//  AuraApp
//
//  A nearby place returned by Apple Maps search.
//

import CoreLocation
import MapKit

/// Which kind of recommendation the user tapped. Drives the Apple Maps search
/// filter so "Satay" finds restaurants rather than, say, a street of that name.
enum PlaceKind: Hashable {
  case activity
  case food

  var pointOfInterestFilter: MKPointOfInterestFilter? {
    switch self {
    case .activity:
      nil
    case .food:
      MKPointOfInterestFilter(including: [
        .restaurant, .cafe, .bakery, .foodMarket, .brewery, .winery, .distillery,
      ])
    }
  }
}

/// A plain, hashable coordinate so it can travel through `AppDestination`.
struct SearchCenter: Hashable {
  let latitude: Double
  let longitude: Double

  var location: CLLocation { CLLocation(latitude: latitude, longitude: longitude) }
}

struct Place: Identifiable {
  let id = UUID()
  let mapItem: MKMapItem

  /// Metres from the search centre, when one was known.
  let distance: CLLocationDistance?

  var name: String { mapItem.name ?? "Unknown place" }

  /// e.g. "Jalan Poppies I No. 88, Kabupaten Badung". The street tells nearby
  /// results apart; the city alone is identical for most of them.
  var locality: String? {
    mapItem.address?.shortAddress ?? mapItem.addressRepresentations?.cityWithContext
  }

  var symbolName: String {
    mapItem.pointOfInterestCategory.map(Self.symbolName(for:)) ?? "mappin"
  }

  private static func symbolName(for category: MKPointOfInterestCategory) -> String {
    switch category {
    case .restaurant, .foodMarket: "fork.knife"
    case .cafe: "cup.and.saucer.fill"
    case .bakery: "birthday.cake.fill"
    case .brewery, .winery, .distillery, .nightlife: "wineglass.fill"
    case .beach: "beach.umbrella.fill"
    case .park, .nationalPark: "tree.fill"
    case .fitnessCenter: "figure.strengthtraining.traditional"
    case .spa: "leaf.fill"
    case .museum: "building.columns.fill"
    case .theater, .movieTheater: "theatermasks.fill"
    case .store: "bag.fill"
    case .surfing: "figure.surfing"
    case .hiking: "figure.hiking"
    case .golf: "figure.golf"
    case .swimming: "figure.pool.swim"
    case .marina: "sailboat.fill"
    case .zoo, .aquarium: "pawprint.fill"
    case .landmark, .castle, .fortress: "building.2.fill"
    default: "mappin"
    }
  }
}
