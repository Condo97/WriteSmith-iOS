//
//  ItemExploreView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

protocol ItemExploreViewDelegate {
    func generateButtonPressed(_ sender: Any)
}

class ItemExploreView: UIView {
    
    @IBOutlet weak var tableView: ManagedTableView!
    @IBOutlet weak var generateButton: RoundedButton!
    
    var delegate: ItemExploreViewDelegate?
    
    @IBAction func generateButtonPressed(_ sender: Any) {
        delegate?.generateButtonPressed(sender)
    }
    
}
