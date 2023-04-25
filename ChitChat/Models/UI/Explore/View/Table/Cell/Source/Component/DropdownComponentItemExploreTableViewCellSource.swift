//
//  DropdownComponentItemExploreTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/23/23.
//

import Foundation

class DropdownComponentItemExploreTableViewCellSource: ComponentItemTableViewCellSource {
    
    // Initialization variables
    var headerText: String
    var promptPrefix: String
    
    var detailTitle: String?
    var detailText: String?
    
    var dropdownItems: [ContextMenuItem]
    
    // View and accessor to value of it
    var view: UIView = UIView()
    var viewHeight: CGFloat = 48
    
    var value: String?
    
    convenience init(headerText: String, promptPrefix: String, dropdownItems: [ContextMenuItem]) {
        self.init(headerText: headerText, promptPrefix: promptPrefix, detailTitle: nil, detailText: nil, dropdownItems: dropdownItems)
    }
    
    init(headerText: String, promptPrefix: String, detailTitle: String?, detailText: String?, dropdownItems: [ContextMenuItem]) {
        self.headerText = headerText
        self.promptPrefix = promptPrefix
        self.detailTitle = detailTitle
        self.detailText = detailText
        self.dropdownItems = dropdownItems
        
        // Add gesture recognizer to view so that when it is tapped it can show the ContextMenu
        let tapViewGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(tappedView))
        self.view.gestureRecognizers?.append(tapViewGestureRecognizer)
        
    }
    
    @objc func tappedView(_ sender: UIView) {
        // Show ContextMenu
        let contextMenu = ContextMenu()
        contextMenu.items = dropdownItems
        
        contextMenu.showMenu(viewTargeted: sender, delegate: self)
    }
    
}

extension DropdownComponentItemExploreTableViewCellSource: ContextMenuDelegate {
    
    func contextMenuDidSelect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) -> Bool {
        value = item.title
        
        return true
    }
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) {
        
    }
    
}
