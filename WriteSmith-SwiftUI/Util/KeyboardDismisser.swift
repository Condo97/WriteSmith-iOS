//
//  KeyboardDismisser.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/20/23.
//

import Foundation
import SwiftUI

class KeyboardDismisser {
    
    static func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
