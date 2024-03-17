//
//  KeyboardDismissingButton.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/20/23.
//

import Foundation
import SwiftUI

struct KeyboardDismissingButton<Label: View>: View {

    var action: () -> Void
    let content: Label
    
    init(action: @escaping ()->Void, @ViewBuilder label: ()->Label) {
        self.action = action
        self.content = label()
    }
    
    var body: some View {
        Button(action: {
            #if DEBUG
            
            #else
            KeyboardDismisser.dismiss()
            #endif
            
            action()
        }) {
            content
        }
    }
    
}
