//
//  PhotoGalleryView.swift
//  AuraApp
//

import SwiftUI

enum GalleryMode {
    case detail
    case list
}

struct PhotoGalleryView: View {
    let photos: [LocationPhoto]
    let locationName: String?
    
    @Binding var selectedPhotoIndex: Int?
    @Environment(\.dismiss) var dismiss
    
    @State private var mode: GalleryMode = .detail
    @State private var currentIndex: Int = 0
    
    init(photos: [LocationPhoto], locationName: String?, selectedPhotoIndex: Binding<Int?>) {
        self.photos = photos
        self.locationName = locationName
        self._selectedPhotoIndex = selectedPhotoIndex
        // Initialize currentIndex from the binding
        self._currentIndex = State(initialValue: selectedPhotoIndex.wrappedValue ?? 0)
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if mode == .detail {
                PhotoDetailView(
                    photos: photos,
                    currentIndex: $currentIndex,
                    onClose: {
                        withAnimation(.spring()) {
                            mode = .list
                        }
                    }
                )
                .transition(.opacity)
            } else {
                PhotoListView(
                    photos: photos,
                    locationName: locationName,
                    onPhotoTap: { index in
                        currentIndex = index
                        withAnimation(.spring()) {
                            mode = .detail
                        }
                    },
                    onBack: {
                        dismiss()
                    }
                )
                .transition(.opacity)
            }
        }
    }
}
