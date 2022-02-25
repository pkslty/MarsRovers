//
//  Rover.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 11.02.2022.
//

import Foundation
import UIKit
import Combine

struct Rover: Codable, Identifiable {
    let roverType: RoverType
    let photo: UIImage?
    let name: String
    let landingDate: String
    let launchDate: String
    let status: String
    let maxSol: Int
    let maxDate: String
    let totalPhotos: Int
    let photos: [SolRoverPhotosSummary]
    var cameras: [String] {
        switch self.roverType {
        case .curiosity:
            return ["FHAZ", "RHAZ", "MAST", "CHEMCAM", "MAHLI", "MARDI", "NAVCAM"]
        case .spirit, .opportunity:
            return ["FHAZ", "RHAZ", "NAVCAM", "PANCAM", "MINITES"]
        case .perseverance:
            return ["EDL_DDCAM", "EDL_PUCAM2", "EDL_RDCAM", "EDL_RUCAM", "FRONT_HAZCAM_LEFT_A",
                    "FRONT_HAZCAM_RIGHT_A", "MCZ_LEFT", "MCZ_RIGHT", "NAVCAM_LEFT", "NAVCAM_RIGHT",
                    "REAR_HAZCAM_LEFT", "REAR_HAZCAM_RIGHT", "SKYCAM"]
        }
    }
    var id: Int { roverType.roverNumber() }
    
    enum PhotoManifestCodingKeys: String, CodingKey {
        case photomanifest = "photo_manifest"
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case landingDate = "landing_date"
        case launchDate = "launch_date"
        case status
        case maxSol = "max_sol"
        case maxDate = "max_date"
        case totalPhotos = "total_photos"
        case photos
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PhotoManifestCodingKeys.self)
        let nestedContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .photomanifest)
        self.name = try nestedContainer.decode(String.self, forKey: .name)
        self.landingDate = try nestedContainer.decode(String.self, forKey: .landingDate)
        self.launchDate = try nestedContainer.decode(String.self, forKey: .launchDate)
        self.status = try nestedContainer.decode(String.self, forKey: .status)
        self.maxSol = try nestedContainer.decode(Int.self, forKey: .maxSol)
        self.maxDate = try nestedContainer.decode(String.self, forKey: .maxDate)
        self.totalPhotos = try nestedContainer.decode(Int.self, forKey: .totalPhotos)
        self.photos = try nestedContainer.decode([SolRoverPhotosSummary].self, forKey: .photos)
        let photoName = self.name + ".jpg"
        self.photo = UIImage(named: photoName)
        self.roverType = RoverType(name: self.name) ?? .curiosity
    }
}

struct SolRoverPhotosSummary: Codable {
    let sol: Int
    let earthDate: String
    let totalPhotos: Int
    let cameras: [String]
    
    enum CodingKeys: String, CodingKey {
        case sol
        case earthDate = "earth_date"
        case totalPhotos = "total_photos"
        case cameras
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sol = try container.decode(Int.self, forKey: .sol)
        self.earthDate =  try container.decode(String.self, forKey: .earthDate)
        self.totalPhotos = try container.decode(Int.self, forKey: .totalPhotos)
        self.cameras = try container.decode([String].self, forKey: .cameras)
    }
}
