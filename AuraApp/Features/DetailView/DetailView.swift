//
//  DetailView.swift
//  AuraApp
//
//  Created by Muhammad Nurul Akbar on 16/04/26.
//
//  UPDATED: Now receives a `locationId` and fetches real data
//  from TripAdvisor (details, photos, reviews) using async/await.
//

import SwiftUI

struct DetailView: View {
  // MARK: - Input

  let locationId: String
  var distance: String? = nil
  let initialImageUrl: String?
  let animation: Namespace.ID
  
  // MARK: - Service

  private let service = TripAdvisorService()
  
  // MARK: - State

  @State private var detail: LocationDetail?
  @State private var photos: [LocationPhoto] = []
  @State private var reviews: [LocationReview] = []
  @State private var isLoading = true
  @State private var selectedPhotoIndex: Int? = nil
  
  // MARK: - Body
  
  var body: some View {
    mainContent
      .task {
        await loadData()
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          if !isLoading {
            TopRightActions(detail: detail)
          }
        }
      }
      .toolbarBackground(.hidden, for: .navigationBar)
      .fullScreenCover(item: photoIdentifierBinding) { _ in
        PhotoGalleryView(
          photos: photos,
          locationName: detail?.name,
          selectedPhotoIndex: $selectedPhotoIndex
        )
      }
      .navigationTransition(.zoom(sourceID: locationId, in: animation))
  }
  
  private var mainContent: some View {
    ZStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          // Top Header Image - Always shown for smooth transition
          HeaderImage(
            photos: photos,
            initialImageUrl: initialImageUrl,
            locationId: locationId,
            animation: animation
          ) {
            if !photos.isEmpty {
              selectedPhotoIndex = 0
            }
          }
          
          // Content Section
          Group {
            if isLoading && detail == nil {
              VStack {
                Spacer(minLength: 100)
                ProgressView()
                  .scaleEffect(1.2)
                Spacer()
              }
              .frame(maxWidth: .infinity)
            } else {
              VStack(alignment: .leading, spacing: 32) {
                TitleSection(detail: detail, distance: distance)
                PhotosSection(
                  photos: photos,
                  photoCount: detail?.photoCount,
                  webUrl: detail?.webUrl,
                  onPhotoTap: { index in
                    selectedPhotoIndex = index
                  }
                )
                ReviewsSection(reviews: reviews, numReviews: detail?.numReviews, webUrl: detail?.webUrl)
                DetailsSection(detail: detail)
              }
              .padding(.vertical, 20)
              .padding(.bottom, 80)
              .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
          }
          .animation(.easeInOut(duration: 0.6), value: isLoading)
        }
      }
      .edgesIgnoringSafeArea(.top)
      
      if !isLoading {
        stickyBottomButton
      }
    }
  }
  
  private var stickyBottomButton: some View {
    VStack {
      Spacer()
      Button(action: openMaps) {
        HStack {
          Image(systemName: "location.fill") // Using location arrow for directions
          Text("Get directions")
            .font(.custom("InstrumentSans-SemiBold", size: 16))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black)
        .foregroundColor(.white)
        .cornerRadius(30)
      }
      .padding(.horizontal)
      .padding(.bottom, 16)
    }
  }
  
  private var photoIdentifierBinding: Binding<PhotoIdentifier?> {
    Binding(
      get: { selectedPhotoIndex.map { PhotoIdentifier(index: $0) } },
      set: { selectedPhotoIndex = $0?.index }
    )
  }
  
  struct PhotoIdentifier: Identifiable {
    let index: Int
    var id: Int {
      index
    }
  }
  
  // MARK: - Load Data
  
  private func loadData() async {
    isLoading = true
    
    do {
      detail = try await service.getLocationDetails(locationId: locationId)
    } catch {
      print("Error loading detail: \(error)")
    }
    
    do {
      photos = try await service.getLocationPhotos(locationId: locationId)
    } catch {
      print("Error loading photos: \(error)")
    }
    
    do {
      reviews = try await service.getLocationReviews(locationId: locationId)
    } catch {
      print("Error loading reviews: \(error)")
    }
    
    isLoading = false
  }
  
  private func openMaps() {
    let name = detail?.name ?? ""
    let address = detail?.addressObj?.addressString ?? ""
    let query = [name, address].filter { !$0.isEmpty }.joined(separator: ", ")
    
    if let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
       let url = URL(string: "http://maps.apple.com/?q=\(encoded)")
    {
      UIApplication.shared.open(url)
    }
  }
}

struct TopRightActions: View {
  let detail: LocationDetail?
  
  var body: some View {
    Menu {
      if let phone = detail?.phone, !phone.isEmpty {
        let cleanPhone = phone.filter { "0123456789+".contains($0) }
        if let url = URL(string: "tel://\(cleanPhone)") {
          Link(destination: url) {
            Label("Call", systemImage: "phone")
          }
        }
      }
      
      if let website = detail?.website, !website.isEmpty, let url = URL(string: website) {
        Link(destination: url) {
          Label("Open website", systemImage: "globe")
        }
      }
      
      if let webUrl = detail?.webUrl, !webUrl.isEmpty, let url = URL(string: webUrl) {
        ShareLink(item: url) {
          Label("Share", systemImage: "square.and.arrow.up")
        }
      }
    } label: {
      Image(systemName: "ellipsis")
        .font(.system(size: 18, weight: .medium))
        .foregroundColor(.black)
    }
  }
}

#Preview {
  @Previewable @Namespace var anim
  NavigationStack {
    DetailView(locationId: "3399541", initialImageUrl: nil, animation: anim)
  }
}
