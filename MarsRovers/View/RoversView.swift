//
//  ContentView.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 11.02.2022.
//

import SwiftUI

struct RoversView: View {
    @ObservedObject var viewModel: RoversViewModel
    @State var cameraDescription: String = ""
    
    var body: some View {
        NavigationView {
            LoadingView(isShowing: $viewModel.isLoading) {
                List {
                    ForEach(viewModel.rovers) { rover in
                        VStack(alignment: .leading) {
                            Text(rover.name)
                                .font(.largeTitle)
                                .multilineTextAlignment(.leading)
                            Image(uiImage: rover.photo!)
                                .resizable()
                                .scaledToFit()
                            Text("Launch Date: \(rover.launchDate)")
                            Text("Landing Date: \(rover.landingDate)")
                            Text("Status: \(rover.status)")
                            Text("Max Sol: \(rover.maxSol)")
                            Text("Last photo date: \(rover.maxDate)")
                            Text("Total photos: \(rover.totalPhotos)")
                            Text("Cameras:")
                            HStack {
                                ForEach(rover.cameras, id: \.self) { camera in
                                    Text(camera)
                                        .font(.system(size: 12, weight: .light, design: .default))
                                        .background(Color.orange)
                                }
                            }
                        }
                        .background(NavigationLink("",
                                                   destination: RoverPhotosView(viewModel: RoverPhotosViewModel(api: API(), rover: rover)))
                                        .opacity(0))
                    }
                }
                .navigationTitle("Choose your rover")
                .listStyle(.plain)
            }
        }
    }
}
