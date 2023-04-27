//
//  DropdownComponentItemExploreTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/23/23.
//

import Foundation

class DropdownComponentItemExploreTableViewCellSource: ComponentItemTableViewCellSource {
    
    // Constants
    private let labelPlaceholder = "Tap to select..."
    
    // Instance variables
    var contextMenu: ContextMenu?
    
    // Initialization variables
    var headerText: String
    var promptPrefix: String
    
    var detailTitle: String?
    var detailText: String?
    
    var required: Bool
    
    var editingDelegate: ComponentItemTableViewCellSourceEditingDelegate?
    
    var dropdownItems: [ContextMenuItem]
    
    // View and accessor to value of it
    var view: UIView = {
        let label = UILabel()
        label.font = UIFont(name: Constants.primaryFontName, size: 15.0)
        label.isUserInteractionEnabled = true
        return label
    }()
    var viewHeight: CGFloat = 48
    
    var value: String?
    
    
    convenience init(headerText: String, promptPrefix: String, dropdownItems: [ContextMenuItem]) {
        self.init(headerText: headerText, promptPrefix: promptPrefix, required: false, dropdownItems: dropdownItems)
    }
    
    convenience init(headerText: String, promptPrefix: String, required: Bool, dropdownItems: [ContextMenuItem]) {
        self.init(headerText: headerText, promptPrefix: promptPrefix, detailTitle: nil, detailText: nil, required: required, dropdownItems: dropdownItems)
    }
    
    init(headerText: String, promptPrefix: String, detailTitle: String?, detailText: String?, required: Bool, dropdownItems: [ContextMenuItem]) {
        self.headerText = headerText
        self.promptPrefix = promptPrefix
        self.detailTitle = detailTitle
        self.detailText = detailText
        self.required = required
        self.dropdownItems = dropdownItems
        
        // Configure label with placeholder and lower opacity
        if let label = view as? UILabel {
            label.text = labelPlaceholder
            label.alpha = 0.8
        }
        
        // Add gesture recognizer to view so that when it is tapped it can show the ContextMenu
        let tapViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        view.addGestureRecognizer(tapViewGestureRecognizer)
        
    }
    
    @objc func tappedView(_ sender: UIView) {
        // Show ContextMenu
        contextMenu = ContextMenu()
        contextMenu!.items = dropdownItems
        
        // TODO: view.superview!.superview! is probably not the best way to do this lol
        contextMenu!.showMenu(viewTargeted: view.superview!.superview!, delegate: self)
    }
    
}

extension DropdownComponentItemExploreTableViewCellSource: ContextMenuDelegate {
    
    func contextMenuDidSelect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) -> Bool {
        // Set value to item title
        value = item.title
        
        // Set label text to value and alpha to 1.0
        if let label = view as? UILabel {
            label.text = value
            label.alpha = 1.0
        }
        
        // Call finished editing on editing delegate
        editingDelegate?.finishedEditing(source: self)
        
        return true
    }
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) {
        
    }
    
}
