//
//  DetailView.swift
//  AuraApp
//
//  Created by Muhammad Nurul Akbar on 16/04/26.
//
//  MVVM: View renders state from DetailViewModel. All business logic
//  (fetching, maps, retry) lives in the ViewModel.
//

import SwiftUI

struct DetailView: View {
  // MARK: - State

  @StateObject private var viewModel: DetailViewModel
  @State private var selectedPhotoIndex: Int? = nil
  let animation: Namespace.ID

  init(
    locationId: String,
    distance: String? = nil,
    initialImageUrl: String?,
    animation: Namespace.ID
  ) {
    _viewModel = StateObject(wrappedValue: DetailViewModel(
      locationId: locationId,
      distance: distance,
      initialImageUrl: initialImageUrl
    ))
    self.animation = animation
  }

  // MARK: - Body

  var body: some View {
    mainContent
      .task {
        viewModel.onAppear()
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          if !viewModel.isLoading {
            TopRightActions(detail: viewModel.detail)
          }
        }
      }
      .toolbarBackground(.hidden, for: .navigationBar)
      .fullScreenCover(item: photoIdentifierBinding) { _ in
        PhotoGalleryView(
          photos: viewModel.photos,
          locationName: viewModel.detail?.name,
          selectedPhotoIndex: $selectedPhotoIndex
        )
      }
      .navigationTransition(.zoom(sourceID: viewModel.locationId, in: animation))
  }

  private var mainContent: some View {
    ZStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          // Top Header Image - Always shown for smooth transition
          HeaderImage(
            photos: viewModel.photos,
            initialImageUrl: viewModel.initialImageUrl,
            locationId: viewModel.locationId,
            animation: animation
          ) {
            if !viewModel.photos.isEmpty {
              selectedPhotoIndex = 0
            }
          }

          // Content Section
          ZStack {
            if viewModel.isLoading && viewModel.detail == nil {
              VStack(alignment: .leading, spacing: 32) {
                // Title Skeleton
                VStack(alignment: .leading, spacing: 12) {
                    SkeletonView().frame(height: 32).frame(maxWidth: .infinity)
                    SkeletonView().frame(height: 18).frame(width: 120)
                }
                
                // Photos Skeleton
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<3) { _ in
                            SkeletonView().frame(width: 150, height: 200)
                        }
                    }
                }
                
                // Reviews Skeleton
                VStack(alignment: .leading, spacing: 12) {
                    SkeletonView().frame(height: 24).frame(width: 150)
                    SkeletonView().frame(height: 100).frame(maxWidth: .infinity)
                }
              }
              .padding(.horizontal, 20)
              .transition(.opacity)
            } else if let error = viewModel.error, viewModel.detail == nil {
              detailErrorView(error)
                .transition(.opacity)
            } else {
              VStack(alignment: .leading, spacing: 32) {
                TitleSection(detail: viewModel.detail, distance: viewModel.distance)
                PhotosSection(
                  photos: viewModel.photos,
                  photoCount: viewModel.detail?.photoCount,
                  webUrl: viewModel.detail?.webUrl,
                  onPhotoTap: { index in
                    selectedPhotoIndex = index
                  }
                )
                ReviewsSection(reviews: viewModel.reviews, numReviews: viewModel.detail?.numReviews, webUrl: viewModel.detail?.webUrl)
                DetailsSection(detail: viewModel.detail)
              }
              .padding(.vertical, 20)
              .padding(.bottom, 80)
              .transition(.opacity)
            }
          }
          .animation(.easeInOut(duration: 0.4), value: viewModel.isLoading)
        }
      }
      .edgesIgnoringSafeArea(.top)

      if !viewModel.isLoading && viewModel.detail != nil {
        stickyBottomButton
      }
    }
  }

  // MARK: - Error View

  private func detailErrorView(_ error: Error) -> some View {
    VStack(spacing: 16) {
      Spacer()
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 48))
        .foregroundStyle(.secondary)
      Text("Unable to load details")
        .font(.custom("InstrumentSans-Medium", size: 18))
      Text(error.localizedDescription)
        .font(.custom("InstrumentSans-Regular", size: 14))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
      Button("Try Again") {
        viewModel.retry()
      }
      .buttonStyle(.bordered)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }

  // MARK: - Sub-Views

  private var stickyBottomButton: some View {
    VStack {
      Spacer()
      Button(action: viewModel.openMaps) {
        HStack {
          Image(systemName: "location.fill")
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
