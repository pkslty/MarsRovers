//
//  CameraButton.swift
//  MarsRovers
//
//  Created by Denis Kuzmin on 12.02.2022.
//

import SwiftUI

struct CameraButton: View {
    
    @Binding var currentlySelected: String
    
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            self.currentlySelected = text
            self.action()
        }) {
            
            Text(text)
                .font(.system(size: 11))
        }
        .foregroundColor(.black)
        .frame(minWidth: 0, maxWidth: 50)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(currentlySelected == text ? .orange : .white)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
        )
                
    }
}
