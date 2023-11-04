//
//  SwipeAction.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/4/23.
//

import Foundation
import SwiftUI

struct SwipeAction<V: View>: ViewModifier {
    
    @State var canDrag: Bool = true
    @Binding var isDragged: Bool
    @ViewBuilder var behind: ()->V
//    var onDelete: (() -> Void)? = nil
    
    
    @State private var dragTranslation: CGFloat = .zero
    @State private var prevDragTranslation: CGFloat = .zero
    
    @State private var prevIsDragged: Bool = false
    
    @State private var hapticPlayed: Bool = false
    
    private let maxDragOffset: CGFloat = 200.0
    private let engageIsDraggedOffsetPercent = 0.2
    
    private var dragOffset: CGFloat {
        getDragOffset(currentTranslation: dragTranslation)
    }
    
    func body(content: Content) -> some View {
        ZStack {
            behind()
                .opacity(-Double(dragOffset) / 100)
            
            HStack(spacing: 0.0) {
                Spacer(minLength: 0)
                
                content
                
                Spacer(minLength: 0)
            }
            .offset(x: dragOffset)
            .scaleEffect(1 - pow(Double(dragOffset) / 40, 2) / 100)
            .opacity(1 - pow(Double(dragOffset) / 40, 2) / 100)
            .contentShape(Rectangle())
            .onTapGesture {
                if dragOffset != .zero {
                    withAnimation {
                        dragTranslation = .zero
                        prevDragTranslation = .zero
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // Ensure canDrag, otherwise return
                        guard canDrag else {
                            return
                        }
                        
                        // Ensure drag offset is less than or equal to 0, otherwise return so that rows can only be swiped left
                        guard getDragOffset(currentTranslation: gesture.translation.width) <= 0 else {
                            return
                        }
                        
                        // Set drag offset to gesture translation width
                        dragTranslation = gesture.translation.width
                        
                        // If haptic hasn't played and dragOffset is less than or equal to the left max drag offset do light haptic and set hapticPlayed to true
                        if !hapticPlayed && dragOffset <= -maxDragOffset * (prevIsDragged ? abs(1 - engageIsDraggedOffsetPercent) : engageIsDraggedOffsetPercent) {
                            HapticHelper.doLightHaptic()
                            hapticPlayed = true
                        }
                    }
                    .onEnded { value in
                        // Set the dragOffset to zero or left max drag offset depending on where the user released the row
                        withAnimation {
                            // Set prevDragTranslation and prevIsDragged based on where the view was released
                            if dragOffset <= -maxDragOffset * (prevIsDragged ? abs(1 - engageIsDraggedOffsetPercent) : engageIsDraggedOffsetPercent) {
                                prevDragTranslation = -maxDragOffset
                                prevIsDragged = true
                            } else {
                                prevDragTranslation = .zero
                                prevIsDragged = false
                            }
                            
                            // Reset dragTranslation to zero
                            dragTranslation = .zero
                            
                            // Reset hapticPlayed to false
                            hapticPlayed = false
                        }
                    })
        }
        .onChange(of: dragOffset) { dragOffset in
            if dragOffset == 0 {
                isDragged = false
            } else {
                isDragged = true
            }
        }
        .onChange(of: isDragged) { isDragged in
            if !isDragged {
                withAnimation {
                    dragTranslation = 0.0
                    prevDragTranslation = 0.0
                }
            }
        }
    }
    
    private func getDragOffset(currentTranslation: CGFloat) -> CGFloat {
        prevDragTranslation + currentTranslation
    }
    
}

#Preview {
    
    struct ContentView: View {
        
        @State var isDragged: Bool = false
        
        
        var body: some View {
            HStack {
                Spacer()
                
                Text("Swipe this")
            }
            .modifier(SwipeAction(
                isDragged: $isDragged,
                behind: {
                    ZStack {
                        
                    }
                }))
            .onChange(of: isDragged, perform: { value in
                print("isDragged: \(isDragged)")
            })
        }
        
    }
    
    return ContentView()
    
}
