//
//  PlacesService.swift
//  AuraApp
//
//  Nearby place search backed by Apple Maps (MapKit). No API key, no quota,
//  and the only party that sees the user's location is Apple.
//

import MapKit

protocol PlacesServiceProtocol {
  func searchPlaces(query: String, kind: PlaceKind, near center: SearchCenter?) async throws -> [Place]
}

final class MapKitPlacesService: PlacesServiceProtocol {
  /// Wide enough to reach across a city or a small island region.
  private let searchRadius: CLLocationDistance = 30_000

  func searchPlaces(query: String, kind: PlaceKind, near center: SearchCenter?) async throws -> [Place] {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.resultTypes = .pointOfInterest
    request.pointOfInterestFilter = kind.pointOfInterestFilter

    if let center {
      request.region = MKCoordinateRegion(
        center: center.location.coordinate,
        latitudinalMeters: searchRadius * 2,
        longitudinalMeters: searchRadius * 2
      )
      // Without this MapKit happily returns famous matches on other continents.
      request.regionPriority = .required
    }

    AppLogger.networkRequest("mapKitSearch: \(query)")

    let mapItems: [MKMapItem]
    do {
      mapItems = try await MKLocalSearch(request: request).start().mapItems
    } catch let error as MKError where error.code == .placemarkNotFound {
      // MapKit reports "no results" as an error; it is simply an empty list.
      mapItems = []
    }

    let origin = center?.location
    return mapItems
      .map { Place(mapItem: $0, distance: origin.map($0.location.distance(from:))) }
      .sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
  }
}
