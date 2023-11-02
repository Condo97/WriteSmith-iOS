//
//  MoveUpTransition.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/25/23.
//

import Foundation
import SwiftUI

struct MoveUpTransition: ViewModifier {
    
    var isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(y: isActive ? -140 : 0)
            .opacity(isActive ? 0 : 1)
    }
    
//    func effectValue(size: CGSize) -> ProjectionTransform {
//        isActive
//        ?
//        ProjectionTransform(CGAffineTransform.identity.concatenating(CGAffineTransform(translationX: 0, y: 400)))
//        :
//        ProjectionTransform(CGAffineTransform(translationX: 0, y: 0))
//    }
}

extension AnyTransition {
    
    static var moveUp: AnyTransition {
        AnyTransition.modifier(
            active: MoveUpTransition(isActive: true),
            identity: MoveUpTransition(isActive: false))
    }
    
}
