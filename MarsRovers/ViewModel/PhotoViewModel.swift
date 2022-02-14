//
//  PhotoViewModel.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 14.02.2022.
//

import SwiftUI

class PhotoViewModel: ObservableObject, Identifiable {
    let id: Int
    @Published var image: UIImage?
    @Published var isLoading: Bool = true
    let sol: Int
    let earthDate: String
    let cameraName: String
    let cameraFullName: String
    
    init(from model: Photo) {
        self.id = model.id
        self.sol = model.sol
        self.earthDate = model.earthDate
        self.cameraName = model.camera.name
        self.cameraFullName = model.camera.fullName
        getImage(from: model.imageUrlString)
    }
    
    private func getImage(from urlString: String) {
        ImageLoader.getImage(from: urlString, completion: {
            self.image = $0
            self.isLoading = false
        })
    }
}

extension PhotoViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension PhotoViewModel: Equatable {
    static func == (lhs: PhotoViewModel, rhs: PhotoViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
