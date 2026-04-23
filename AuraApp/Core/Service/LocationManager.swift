//
//  LocationManager.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import Combine
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()

  @Published var location: CLLocation?
  @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

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
    location = locations.last
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to get location: \(error.localizedDescription)")
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
    if manager.authorizationStatus == .authorizedWhenInUse {
      manager.requestLocation()
    }
  }
}
