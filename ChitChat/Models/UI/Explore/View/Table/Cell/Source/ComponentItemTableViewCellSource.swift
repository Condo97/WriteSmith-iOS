//
//  ComponentItemExploreTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/23/23.
//

import Foundation

protocol ComponentItemTableViewCellSourceEditingDelegate {
    func finishedEditing(source: ComponentItemTableViewCellSource)
}

protocol ComponentItemTableViewCellSource: CellSource {
    
    // "What would you like to summarize?"
    // Summarize _____
    //
    // "Tone of Voice"
    // With the tone of voice _____
    //
    // Detail action shows alert with explanation
    
    // Initialization variables
    var headerText: String { get set } // For header in componentCell
    var promptPrefix: String { get set } // For prompt when generating
    
    var detailTitle: String? { get set } // Title for the detail view shown on button press
    var detailText: String? { get set } // Text for the detail view shown on button press
    
    var required: Bool { get set } // Indicates if the field should be filled before creating
    
    var editingDelegate: ComponentItemTableViewCellSourceEditingDelegate? { get set } // Delegate that communicates when the component view finishes editing
    
        
    // View and computed variable representing its value
    var view: UIView { get set } // View that represents the component the user interacts with
    var viewHeight: CGFloat { get set } // Height for that view which will be set via constraint
    var value: String? { get } // Computed value of the component the user interacts with, defined in source
    
}

extension ComponentItemTableViewCellSource {
    
    var collectionViewCellReuseIdentifier: String? {
        get {
            Registry.Explore.View.Collection.Cell.item.reuseID
        }
    }
    
    var tableViewCellReuseIdentifier: String? {
        get {
            Registry.Explore.View.Table.Cell.Item.component.reuseID
        }
    }
    
}
