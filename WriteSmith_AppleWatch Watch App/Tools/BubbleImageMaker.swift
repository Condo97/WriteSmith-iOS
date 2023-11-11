//
//  BubbleImageMaker.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import Foundation
import SwiftUI

class BubbleImageMaker {
    static func makeBubbleImage(userSent: Bool) -> Image {
        let name: String
        if userSent {
            name = "chat_bubble_sent"
        } else {
            name = "chat_bubble_received"
        }
        
        let image = Image(name) // The names must be correct!
        return image
            .resizable(
                capInsets: EdgeInsets(top: 17, leading: 21, bottom: 17, trailing: 21),
                resizingMode: .stretch)
            .renderingMode(.template)
//            .resizableImage(withCapInsets:
//                                UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
//                            resizingMode: .stretch)
//            .withRenderingMode(.alwaysTemplate)
    }
}
