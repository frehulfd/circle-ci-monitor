//
//  SpinningView.swift
//  CircleCI Monitor
//
//  Created by Don Frehulfer on 1/6/22.
//

import SwiftUI

struct SpinningView<Content: View>: View {
    let secondsPerRotation: Double
    let content: () -> Content
    
    @State
    private var angle: CGFloat = 0
    
    var body: some View {
        content()
            .rotationEffect(.degrees(angle))
            .drawingGroup()
            .animation(.linear(duration: secondsPerRotation)
                .repeatForever(autoreverses: false),
                       value: angle)
            .onAppear {
                DispatchQueue.main.async {
                    angle = 360
                }
            }
    }
}

struct SpinningView_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .foregroundColor(.gray)
            .frame(width: 300, height: 400, alignment: .center)
            .overlay(
                VStack {
                    SpinningView(secondsPerRotation: 1) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    
                    SpinningView(secondsPerRotation: 1) {
                        Text("Hi")
                    }
                }
            )
    }
}
