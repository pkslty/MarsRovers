//
//  MarsRoversTests.swift
//  MarsRoversTests
//
//  Created by Denis Kuzmin on 11.02.2022.
//

import XCTest
@testable import MarsRovers
import SwiftUI
import Combine

class MarsRoversTests: XCTestCase {
    @ObservedObject var roversViewModel: RoversViewModel = .init(api: API())
    var subscriptions = Set<AnyCancellable>()
    
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        subscriptions = []
    }

    func testSuccesfullyLoadRoversManifests() throws {
        
        let expectation = expectation(description: "Succesfully load rovers manifests")
        
        
        let publisher = roversViewModel.$rovers
            .combineLatest(roversViewModel.$isLoading, roversViewModel.$error)
        
        roversViewModel.fetchRovers()
        
        publisher
            .dropFirst()
            .prefix(while: { $0.1 != false })
            .last()
            .sink(receiveCompletion: {
                expectation.fulfill()
                XCTAssertEqual($0, .finished)
                print($0)
            }, receiveValue: { value in
                XCTAssertEqual(value.1, true)
                XCTAssertEqual(value.0.count, 4)
                XCTAssertNil(value.2)
            })
            .store(in: &subscriptions)
        
        
        
        
        wait(for: [expectation], timeout: 20.0)
    }
    


}
