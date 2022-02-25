//
//  RoverPhotosView.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 12.02.2022.
//

import SwiftUI
import Combine

struct RoverPhotosView: View {
    
    enum Field: Hashable {
        case solField
    }
    
    @ObservedObject var viewModel: RoverPhotosViewModel
    let photoColumns = [
            GridItem(.flexible(minimum: 0, maximum: .infinity)),
            GridItem(.flexible(minimum: 0, maximum: .infinity)),
        ]
    let buttonColumns = [GridItem(.adaptive(minimum: 50))]
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Martian sol:")
                    .font(.callout)
                TextField("1...\(viewModel.rover.maxSol)",
                          value: $viewModel.sol,
                          formatter: NumberFormatter())
                    .onTapGesture(perform: { self.focusedField = .solField })
                    .focused($focusedField, equals: .solField)
                    .textFieldStyle(.roundedBorder)
                    .font(.callout)
            }
            .padding(.horizontal)
            LoadingView(isShowing: $viewModel.isLoading) {
                
                VStack(alignment: .leading) {
                    VStack {
                        LazyVGrid(columns: buttonColumns, alignment: .center, spacing: 10) {
                            ForEach(viewModel.cameras, id: \.self) { camera in
                                CameraButton(currentlySelected: $viewModel.camera, text: camera) {
                                    viewModel.camera = camera
                                }
                            }
                        }
                    }
                        .padding(.horizontal)
                    Text(viewModel.photosTitle)
                        .padding(.horizontal)
                        .font(.callout)
                    GeometryReader { geometry in
                        ScrollView(.vertical) {
                            LazyVGrid(columns: photoColumns, alignment: .center, spacing: 16)  {
                                if viewModel.photos.count > 0 {
                                    ForEach(viewModel.photos) { photo in
                                        NavigationLink(destination: PhotoView(viewModel: photo)) {
                                            PhotosCollectionElementView(viewModel: photo)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.rover.roverType.roverName())
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture(perform: { self.focusedField = nil })
        .alert(item: self.$viewModel.error) { error in
            Alert(
                title: Text("Network error"),
                message: Text(error.errorDescription),
                dismissButton: .default(
                    Text("Try again later")
                )
            )
        }
    }
}

