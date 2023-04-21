//
//  IdentifiableManagedObject.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import CoreData
import Foundation

protocol IdentifiableManagedObject: NSManagedObject {
    
    var id: Int64 { get set }
    
}
