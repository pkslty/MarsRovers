//
//  MarsRoversApp.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 11.02.2022.
//

import SwiftUI
import Combine

@main
struct MarsRoversApp: App {
    
    let viewModel = RoversViewModel(api: API())
    
    var body: some Scene {
        WindowGroup {
            RoversView(viewModel: viewModel)
                .onAppear(perform: viewModel.fetchRovers)
        }
    }
}
