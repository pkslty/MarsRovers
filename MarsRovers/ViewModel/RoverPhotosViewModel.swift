//
//  RoverPhotosViewModel.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 12.02.2022.
//

import SwiftUI
import Combine

struct PhotoViewModel: Hashable {
    let image: UIImage?
    let sol: Int
    let earthDate: String
    let cameraName: String
    let cameraFullName: String
    
}

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
        photosTitle = "Photos from \(camera == "ALL" ? "all cameras" : "\(camera) camera") on \(sol) martian sol"
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
                photos.photos.forEach { photo in
                    ImageLoader.getImage(from: photo.imageUrlString, completion: {
                        let photoViewModel = PhotoViewModel(image: $0,
                                                            sol: photo.sol,
                                                            earthDate: photo.earthDate,
                                                            cameraName: photo.camera.name,
                                                            cameraFullName: photo.camera.fullName)
                        self.photos.append(photoViewModel)} )}
                
            })
            .store(in: &subscriptions)
    }
}
