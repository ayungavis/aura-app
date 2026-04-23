//
//  Forecast.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import Foundation

struct Forecast: Identifiable {
    let id = UUID()
    let time: String
    let systemImage: String
    let temperature: String
    let caption: String?
}
