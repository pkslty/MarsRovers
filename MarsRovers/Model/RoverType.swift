//
//  RoverType.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 11.02.2022.
//

import Foundation

enum RoverType {
    case curiosity
    case spirit
    case opportunity
    case perseverance
    
    init?(number: Int) {
        switch number {
        case 0: self = .curiosity
        case 1: self = .spirit
        case 2: self = .opportunity
        case 3: self = .perseverance
        default: return nil
        }
    }
    
    init?(name: String) {
        switch name {
        case "Curiosity": self = .curiosity
        case "Spirit": self = .spirit
        case "Opportunity": self = .opportunity
        case "Perseverance": self = .perseverance
        default: return nil
        }
    }
    
    func roverName() -> String {
        switch self {
        case .curiosity: return "Curiosity"
        case .spirit: return "Spirit"
        case .opportunity: return "Opportunity"
        case .perseverance: return "Perseverance"
        }
    }
    
    func roverNumber() -> Int {
        switch self {
        case .curiosity: return 0
        case .spirit: return 1
        case .opportunity: return 2
        case .perseverance: return 3
        }
    }
}
