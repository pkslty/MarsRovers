//
//  Photos.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 13.02.2022.
//

import Foundation

struct Photos: Codable {
    let photos: [Photo]
}

struct Photo: Codable {
    let imageUrlString: String
    let sol: Int
    let camera: Camera
    let earthDate: String
    
    enum CodingKeys: String, CodingKey {
        case sol
        case camera
        case imageUrlString = "img_src"
        case earthDate = "earth_date"
    }
}

struct Camera: Codable {
    let name: String
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
    }
}

/*
 {
             "id": 669,
             "sol": 100,
             "camera": {
                 "id": 20,
                 "name": "FHAZ",
                 "rover_id": 5,
                 "full_name": "Front Hazard Avoidance Camera"
             },
             "img_src": "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00100/opgs/edr/fcam/FRA_406374643EDR_F0050178FHAZ00301M_.JPG",
             "earth_date": "2012-11-16",
             "rover": {
                 "id": 5,
                 "name": "Curiosity",
                 "landing_date": "2012-08-06",
                 "launch_date": "2011-11-26",
                 "status": "active"
             }
         }
 */
