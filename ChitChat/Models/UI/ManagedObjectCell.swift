//
//  ManagedObjectCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/28/23.
//

import CoreData
import Foundation

protocol ManagedObjectCell {
    
    func configure(managedObject: NSManagedObject)
    
}
