//
//  Image+Identifiable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/14/24.
//

import Foundation
import SwiftUI

struct IdentifiableImage: Identifiable {
    
    var id: UUID = UUID()
    var image: Image
    
}
