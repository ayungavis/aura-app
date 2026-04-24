//
//  LocationManager.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import Combine
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, LocationManagerProtocol {
  private let manager = CLLocationManager()

  @Published var location: CLLocation?
  @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

  var onLocationUpdate: ((CLLocation) -> Void)?
  var onAuthChange: ((CLAuthorizationStatus) -> Void)?

  override init() {
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyKilometer
  }

  func requestLocation() {
    manager.requestWhenInUseAuthorization()
    manager.requestLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    self.location = location
    AppLogger.locationUpdate("\(location.coordinate.latitude), \(location.coordinate.longitude)")
    onLocationUpdate?(location)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    AppLogger.locationError(error)
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
    AppLogger.locationAuthChange(String(describing: manager.authorizationStatus))
    onAuthChange?(manager.authorizationStatus)
    if manager.authorizationStatus == .authorizedWhenInUse {
      manager.requestLocation()
    }
  }
}
