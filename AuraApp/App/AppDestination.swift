//
//  AppDestination.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import Foundation

enum AppDestination: Hashable {
  case list(category: String, imageURL: URL? = nil, imageData: Data? = nil, imageName: String? = nil, tripAdvisorCategory: String? = nil, latLong: String? = nil)
}
