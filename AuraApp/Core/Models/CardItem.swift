//
//  CardItem.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import SwiftUI

protocol CardItem: Identifiable {
  var id: UUID { get }
  var title: String { get }
  var subtitle: String { get }
  var imageName: String { get }
  var imageURL: URL? { get }
  var imagePrompt: String? { get }
  var generatedImage: UIImage? { get }
}
