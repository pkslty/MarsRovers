//
//  PhotoView.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 13.02.2022.
//

import SwiftUI

struct PhotoView: View {
    @ObservedObject var viewModel: PhotoViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("Martian sol: \(viewModel.sol)")
                    .font(.title)
                    .padding(.horizontal)
                Text("Earth date: \(viewModel.earthDate)")
                    .font(.title)
                    .padding(.horizontal)
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    ActivityIndicator(isAnimating: $viewModel.isLoading, style: .large)
                }
                Text("Photo from \(viewModel.cameraFullName)")
                    //.font(.system(size: 14))
                    .padding(.horizontal)
                Spacer()
            }
            .navigationBarTitle("\(viewModel.cameraName) camera photo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

