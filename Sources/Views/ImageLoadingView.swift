//
//  ImageLoadingView.swift
//  ZoomImageView
//
//  Created by amolonus on 26/03/2025.
//
import SwiftUI

public struct ImageLoadingView: View {
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var loadError = false
    @State private var viewID = UUID()
    
    private let imageURL: URL?
    private let initialImage: UIImage?
    public var onDismiss: (() -> Void)?
    
    
    // Initializer for URL-based image loading
    public init(imageURL: URL, onDismiss: (() -> Void)? = nil) {
        self.imageURL = imageURL
        self.initialImage = nil
        self.onDismiss = onDismiss
    }
    
    // Initializer for direct UIImage
    public init(image: UIImage, onDismiss: (() -> Void)? = nil) {
        self.imageURL = nil
        self.initialImage = image
        self.onDismiss = onDismiss
    }
    
    private func loadImageFromURL(url: URL?) async -> UIImage? {
        guard let url else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.isLoading = false
                }
                return image
            } else {
                await MainActor.run {
                    self.loadError = true
                    self.isLoading = false
                }
                return nil
            }
        } catch {
            await MainActor.run {
                self.loadError = true
                self.isLoading = false
            }
            return nil
        }
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if loadError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("Failed to load image")
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
            } else if let image = image {
                ZoomImageView(image: image)
                    .onDragEnd { drag in
                        onDismiss?()
                    }
            }
            
            Button {
                onDismiss?()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            viewID = UUID()
            
            // Handle different initialization cases
            if let initialImage = initialImage {
                // Direct image was provided
                self.image = initialImage
                self.isLoading = false
            } else if let imageURL = imageURL {
                // URL was provided, load asynchronously
                isLoading = true
                Task {
                    self.image = await loadImageFromURL(url: imageURL)
                }
            } else {
                // Neither URL nor image was provided
                self.loadError = true
                self.isLoading = false
            }
        }
        .onDisappear {
            self.image = nil
        }
    }
}

