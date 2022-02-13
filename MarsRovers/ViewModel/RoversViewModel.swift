//
//  RoversViewModel.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 11.02.2022.
//

import Foundation
import Combine

class RoversViewModel: ObservableObject {
    @Published var rovers: [Rover] = []
    @Published var isLoading = false
    private var subscriptions = Set<AnyCancellable>()
    private let api: API
    private let roverTypes: [RoverType] = [.curiosity, .spirit, .opportunity]
    
    init(api: API) {
        self.api = api
    }
    
    func fetchRovers() {
        isLoading = true
        api
            .manifests(rovers: roverTypes)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                print($0)
                self.isLoading = false
            },
                  receiveValue: { self.rovers = $0 })
            .store(in: &subscriptions)
    }
}
