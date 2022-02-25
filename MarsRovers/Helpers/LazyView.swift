//
//  LazyView.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 15.02.2022.
//

import SwiftUI

public struct LazyView<Content: View>: View {
    private let build: () -> Content
    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    public var body: Content {
        build()
    }
}
