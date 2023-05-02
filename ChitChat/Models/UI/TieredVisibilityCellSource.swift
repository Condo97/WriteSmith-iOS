//
//  TieredVisibilityCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 5/2/23.
//

import Foundation

protocol TieredVisibilityCellSource {
    
    var shouldShowOnPremium: Bool { get set }
    var shouldShowOnFree: Bool { get set }
    
}
