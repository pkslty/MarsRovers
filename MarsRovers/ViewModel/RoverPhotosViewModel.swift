//
//  RoverPhotosViewModel.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 12.02.2022.
//

import SwiftUI
import Combine

class RoverPhotosViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var sol: Int = 1
    @Published var photosTitle: String = String()
    @Published var camera: String = "ALL"
    @Published var cameras: [String] = ["ALL"]
    @Published var photos = [PhotoViewModel]()
    @Published var error: ApiError? = nil
    private var subscriptions = Set<AnyCancellable>()
    private let api: API
    let rover: Rover
    
    init(api: API, rover: Rover) {
        self.api = api
        self.rover = rover
        
        subscriptToState()
    }
    
    private func fetchPhotos(camera: String, sol: Int) -> AnyPublisher<Photos, Error> {
        if !isLoading { isLoading = true }
        return api
            .photos(roverType: rover.roverType, camera: camera, sol: sol)
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<Photos, Error> in
                self.error = error
                return Just(Photos(photos: []))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func subscriptToState() {
        
        let publisher = $sol
            .compactMap { [weak self] sol in
                self?.fetchPhotos(camera: "ALL", sol: sol)
            }
            .switchToLatest()
            .share(replay: 1)
        
        publisher
            .receive(on: DispatchQueue.main)
            .map { response in
                return response.photos.reduce(["ALL"]) { accumulator, photo in
                    accumulator.contains(photo.camera.name) ? accumulator : accumulator + [photo.camera.name]
                }
            }
            .replaceError(with: rover.cameras)
            .assign(to: \.cameras, on: self)
            .store(in: &subscriptions)
        
        publisher
            .receive(on: DispatchQueue.main)
            .map { response -> String in
                let cameras = response.photos.map { $0.camera.name }
                return cameras.contains(self.camera) ? self.camera : "ALL"
            }
            .replaceError(with: "ALL")
            .assign(to: \.camera, on: self)
            .store(in: &subscriptions)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                print("Complete \(self.rover.roverType.roverName())")
            },
                  receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false
                })
            .store(in: &subscriptions)
        
        $camera
            .flatMap { _ in publisher }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                print("Complete \(self.rover.roverType.roverName())")
            },
                  receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false
                self.photos = []
                let filteredPhotos = response.photos.filter { $0.camera.name == self.camera || self.camera == "ALL" }
                self.photosTitle = "\(filteredPhotos.count) photos from \(self.camera == "ALL" ? "all cameras" : "\(self.camera) camera") on \(self.sol) martian sol:"
                filteredPhotos.forEach {
                    let photoViewModel = PhotoViewModel(from: $0)
                    self.photos.append(photoViewModel)
                }

            })
            .store(in: &subscriptions)
        
    }
}
