//
//  API.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 11.02.2022.
//

import Foundation
import SwiftUI
import Combine
import CombineExt

enum ApiError: Error, Identifiable {
    var id: String { localizedDescription }
    
    case addressUnreachable(URL)
    case invalidResponse
    
    var errorDescription: String {
        switch self {
        case .invalidResponse: return "The server responded with garbage."
        case .addressUnreachable: return "Server is unreachable."
        }
    }
}

struct API {

    enum Method {
        
        case manifest(RoverType)
        case photos(RoverType, String, Int)
        
        var url: URL {
            var urlComponents = URLComponents(string: "https://api.nasa.gov/mars-photos/api/v1/")!
            var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
            switch self {
            case .manifest(let rover):
                urlComponents.path.append("manifests/\(rover.roverName().lowercased())")
                urlComponents.queryItems = queryItems
                return urlComponents.url!
            case .photos(let rover, let camera, let sol):
                urlComponents.path.append("rovers/\(rover.roverName().lowercased())/photos")
                if camera != "ALL" {
                    queryItems.append(URLQueryItem(name: "camera", value: camera))
                }
                queryItems.append(URLQueryItem(name: "sol", value: String(sol)))
                urlComponents.queryItems = queryItems
                return urlComponents.url!
            }
        }
    }
    
    private let decoder = JSONDecoder()
    private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
    
    func roverManifest(roverType: RoverType) -> AnyPublisher<Rover, ApiError> {
        URLSession.shared.dataTaskPublisher(for: Method.manifest(roverType).url)
            .subscribe(on: apiQueue)
            .map { $0.0 }
            .decode(type: Rover.self, decoder: decoder)
            .mapError { error -> ApiError in
                switch error {
                case is URLError:
                    return ApiError.addressUnreachable(Method.manifest(roverType).url)
                default: return ApiError.invalidResponse
                }
            }
            .eraseToAnyPublisher()
    }
    func manifests(rovers: [RoverType]) -> AnyPublisher<[Rover], ApiError> {
        
        let initialPublisher = roverManifest(roverType: rovers[0])
        let remainRovers = Array(rovers.dropFirst())
        
        let publisher = remainRovers.reduce(initialPublisher) { accumulator, value in
            return accumulator.merge(with: roverManifest(roverType: value))
                .eraseToAnyPublisher()
        }
        return publisher
            .scan([Rover]()) { rovers, rover in
                var accumulator = rovers
                accumulator.append(rover)
                return accumulator
            }
            .eraseToAnyPublisher()
    }
    
    func photos(roverType: RoverType, camera: String, sol: Int) -> AnyPublisher<Photos, ApiError> {
        return URLSession.shared.dataTaskPublisher(for: Method.photos(roverType, camera, sol).url)
            .print("photos:")
            .map { $0.0 }
            .decode(type: Photos.self, decoder: decoder)
            .subscribe(on: apiQueue)
            .mapError { error -> ApiError in
                switch error {
                case is URLError:
                    return ApiError.addressUnreachable(Method.manifest(roverType).url)
                default: return ApiError.invalidResponse
                }
            }
            .eraseToAnyPublisher()
    }
    
}
