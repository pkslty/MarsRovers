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
    
    init?(number: Int) {
        switch number {
        case 0: self = .curiosity
        case 1: self = .spirit
        case 2: self = .opportunity
        default: return nil
        }
    }
    
    init?(name: String) {
        switch name {
        case "Curiosity": self = .curiosity
        case "Spirit": self = .spirit
        case "Opportunity": self = .opportunity
        default: return nil
        }
    }
    
    func roverName() -> String {
        switch self {
        case .curiosity: return "Curiosity"
        case .spirit: return "Spirit"
        case .opportunity: return "Opportunity"
        }
    }
    
    func roverNumber() -> Int {
        switch self {
        case .curiosity: return 0
        case .spirit: return 1
        case .opportunity: return 2
        }
    }
}
