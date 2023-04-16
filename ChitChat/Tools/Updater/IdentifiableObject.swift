//
//  PremiumStructureUpdaterObserver.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/13/23.
//

import Foundation

class IdentifiableObject<T> {
    
    var id: Int
    var t: T
    
    init(id: Int, t: T) {
        self.id = id
        self.t = t
    }
    
}
