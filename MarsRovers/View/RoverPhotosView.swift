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
    @State var currentlySelectedButton: String = "ALL"
    let columns = [
            GridItem(.flexible(minimum: 0, maximum: .infinity)),
            GridItem(.flexible(minimum: 0, maximum: .infinity)),
        ]
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Martian sol:")
                    .font(.title2)
                TextField("1...\(viewModel.rover.maxSol)",
                          value: $viewModel.sol,
                          formatter: NumberFormatter())
                    .onTapGesture(perform: { self.focusedField = .solField })
                    .focused($focusedField, equals: .solField)
                    .textFieldStyle(.roundedBorder)
                    .font(.title2)
            }
            .padding(.horizontal)
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
                .padding(.horizontal)
                .font(.title2)
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 16)  {
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
        .navigationTitle(viewModel.title)
        .onAppear(perform: viewModel.onAppear)
        .onTapGesture(perform: { self.focusedField = nil })
    }
}

