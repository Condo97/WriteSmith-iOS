//
//  PulsatingDotsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/25/23.
//

import SwiftUI

struct PulsatingDotsView: View {
    
    @State var count: Int = 4
    @State var cycleDuration: Float = 0.4
    @State var size: CGFloat = 20
    @State var cycleOffset: CGFloat = 1.0
    
    
    private let minScale: CGFloat = 0.2
    private let maxScale: CGFloat = 1.0
    
//    @State private var loadingTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var isAnimating: Bool = false
    
    var body: some View {
        HStack(spacing: 0.0) {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .frame(width: size)
                    .scaleEffect(isAnimating ? maxScale : minScale)
                    .animation(
                        .linear(duration: TimeInterval(cycleDuration))
                        .repeatForever(autoreverses: true)
                        .delay(2.0 * CGFloat(i) * CGFloat(cycleDuration) / CGFloat(count) / cycleOffset),
                        value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
}

#Preview {
    PulsatingDotsView()
}
