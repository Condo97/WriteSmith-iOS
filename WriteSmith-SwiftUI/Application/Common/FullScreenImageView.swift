//
//  FullScreenImageView.swift
//  SeeGPT
//
//  Created by Alex Coundouriotis on 3/8/24.
//

import Foundation
import SwiftUI
import UIKit

struct FullScreenImageView: View {
    
    @Binding var isPresented: Bool
    @Binding var image: Image?
    
    private let dismissOffset: CGFloat = 80.0
    
    
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    @State private var currentAngle: Angle = .zero
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 28.0))
                    .scaleEffect(currentZoom + totalZoom)
                    .rotationEffect(currentAngle)
                    .offset(dragOffset)
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged({scale in
                                currentZoom = scale - 1
                            })
                            .onEnded({scale in
                                totalZoom += currentZoom
                                currentZoom = 0
                                
                                if totalZoom < 1 {
                                    totalZoom = 1
                                }
                            })
                    )
                    .simultaneousGesture(
                        RotationGesture()
                            .onChanged({angle in
                                currentAngle = angle
                            })
                            .onEnded({angle in
                                currentAngle = .zero
                            })
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged({value in
                                dragOffset = value.translation
                            })
                            .onEnded({value in
                                if abs(dragOffset.height) > dismissOffset || abs(dragOffset.width) > dismissOffset {
                                    withAnimation {
                                        isPresented = false
                                    }
                                }
                                
                                dragOffset = .zero
                            })
                    )
                    .accessibilityZoomAction { action in
                        if action.direction == .zoomIn {
                            totalZoom += 1
                        } else {
                            totalZoom -= 1
                        }
                    }
                
                VStack {
                    
                    HStack(spacing: 16.0) {
                        Spacer()
                        
                        // Share button
                        ShareLink(
                            item: image,
                            preview: SharePreview("Save or share your image.", image: image)
                        ) {
                            Text(Image(systemName: "square.and.arrow.up"))
                                .font(.custom(Constants.FontName.body, size: 25.0))
                        }
                        
                        // Close button
                        Button(action: {
                            withAnimation {
                                isPresented = false
                            }
                        }) {
                            Text(Image(systemName: "xmark"))
                                .font(.custom(Constants.FontName.body, size: 25.0))
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
    
}

#Preview {
    
    FullScreenImageView(
        isPresented: .constant(true),
        image: .constant(Image(uiImage: UIImage(named: "AppIcon")!))
    )
    
}

