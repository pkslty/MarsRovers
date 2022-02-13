//
//  PhotoView.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 13.02.2022.
//

import SwiftUI

struct PhotoView: View {
    let viewModel: PhotoViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("Martian sol: \(viewModel.sol)")
                Text("Earth date: \(viewModel.earthDate)")
                Text("Photo from \(viewModel.cameraFullName) (\(viewModel.cameraName))")
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                Spacer()
            }
        }
    }
}

