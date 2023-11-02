//
//  View+TextFieldTickerTint.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/13/23.
//

import Foundation
import SwiftUI

extension View {
    
    func textFieldTickerTint(_ color: Color) -> some View {
        self
            .colorMultiply(color) // Added to change ticker color
    }
    
}
