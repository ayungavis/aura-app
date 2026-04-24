//
//  LocationManagerProtocol.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import CoreLocation

@MainActor
protocol LocationManagerProtocol: AnyObject {
  var location: CLLocation? { get }
  var authorizationStatus: CLAuthorizationStatus { get }
  var onLocationUpdate: ((CLLocation) -> Void)? { get set }
  var onAuthChange: ((CLAuthorizationStatus) -> Void)? { get set }

  func requestLocation()
}
