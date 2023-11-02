//
//  ComponentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

protocol ComponentView: View {
    
    var finalizedPrompt: String? { get set }
    
}
