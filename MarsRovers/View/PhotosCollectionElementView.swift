//
//  PhotosCollectionElementView.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 14.02.2022.
//

import SwiftUI

struct PhotosCollectionElementView: View {
    
    @ObservedObject var viewModel: PhotoViewModel
    
    var body: some View {
        VStack(alignment: .trailing) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ActivityIndicator(isAnimating: $viewModel.isLoading, style: .large)
            }
            Text(viewModel.cameraName)
                .font(.system(size: 10))
                .background(Color.orange)
                .foregroundColor(Color.primary)
                .padding(.horizontal)
        }
    }
}

