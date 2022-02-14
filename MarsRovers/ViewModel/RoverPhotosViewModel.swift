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
    @Published var title = String()
    @Published var sol: Int = 1 {
        didSet {
            subject.send()
        }
    }
    @Published var photosTitle: String = String()
    @Published var camera: String = "ALL" {
        didSet {
            subject.send()
        }
    }
    @Published var page: Int = 1 {
        didSet {
            subject.send()
        }
    }
    @Published var photos = [PhotoViewModel]()
    private var subscriptions = Set<AnyCancellable>()
    private let api: API
    let rover: Rover
    let subject = PassthroughSubject<Void, Never>()
    
    init(api: API, rover: Rover) {
        self.api = api
        self.rover = rover
        self.title = "\(rover.roverType.roverName())"
        subscriptToSubject()
    }
    
    func onAppear() {
        guard photos.isEmpty else { return }
        subject.send()
    }
    
    private func fetchPhotos() -> AnyPublisher<Photos, API.Error> {
        
        return api
            .photos(rover: rover, camera: camera, sol: sol, page: 1)
    }
    
    private func subscriptToSubject() {
        subject
            .map { _ in self.fetchPhotos() }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { print($0) },
                  receiveValue: { [weak self] photos in
                guard let self = self else { return }
                if self.page == 1 {
                    self.photos = []
                    
                }
                self.photosTitle = "\(photos.photos.count) photos from \(self.camera == "ALL" ? "all cameras" : "\(self.camera) camera") on \(self.sol) martian sol:"
                photos.photos.forEach {
                    let photoViewModel = PhotoViewModel(from: $0)
                    self.photos.append(photoViewModel)
                }
                
            })
            .store(in: &subscriptions)
    }
}
