//
//  RoverPhotosView.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 12.02.2022.
//

import SwiftUI
import Combine

struct RoverPhotosView: View {
    @ObservedObject var viewModel: RoverPhotosViewModel
    @State var currentlySelectedButton: String = "ALL"
    let columns = [
            GridItem(.flexible(minimum: 0, maximum: .infinity)),
            GridItem(.flexible(minimum: 0, maximum: .infinity)),
        ]

    
    var body: some View {
        LoadingView(isShowing: $viewModel.isLoading) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Martian sol number:")
                    TextField("1...\(viewModel.rover.maxSol)",
                              value: $viewModel.sol,
                              formatter: NumberFormatter())
                }
                .padding()
                HStack {
                    ForEach(["ALL"] + viewModel.rover.cameras, id: \.self) { camera in
                        CameraButton(currentlySelected: $currentlySelectedButton, text: camera) {
                            viewModel.camera = camera
                            currentlySelectedButton = camera
                        }
                    }
                }
                .padding()
                Text(viewModel.photosTitle)
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 16)  {
                            if viewModel.photos.count > 0 {
                                ForEach(viewModel.photos, id: \.self) { photo in
                                    if let image = photo.image {
                                        NavigationLink(destination: PhotoView(viewModel: photo)) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: geometry.size.width/2)
                                                //.background(NavigationLink("", destination: PhotoView(viewModel: photo))
                                                                //.opacity(0))
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            .navigationTitle(viewModel.title)
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

