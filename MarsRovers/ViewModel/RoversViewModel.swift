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
    @Published var error: ApiError? = nil
    private var subscriptions = Set<AnyCancellable>()
    private let api: API
    private let roverTypes: [RoverType] = [.curiosity, .spirit, .opportunity, .perseverance]
    let timer: AnyPublisher<Date, Never>
    
    init(api: API) {
        self.api = api
        timer = Timer.publish(every: 0.5,on: RunLoop.main, in: .common)
            .autoconnect()
            .share()
            .eraseToAnyPublisher()
    }
    
    func fetchRovers() {
        isLoading = true
        api
            .manifests(rovers: roverTypes)
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<[Rover], ApiError> in
                self.error = error
                return Just([Rover]())
                    .setFailureType(to: ApiError.self)
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: {
                self.isLoading = false
            },
                  receiveValue: { self.rovers = $0 })
            .store(in: &subscriptions)
    }
}
