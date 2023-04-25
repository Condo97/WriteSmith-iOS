//
//  BodyEssayTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/14/23.
//

import UIKit

class BodyEssayTableViewCellSource: CellSource, SelectableCellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Essay.View.Table.Cell.body.reuseID
    
    var delegate: EssayBodyTableViewCellDelegate
    var text: String
    var inputAccessoryView: UIView?
    
    var didSelect: ((UIView, IndexPath)->Void)?
    
    init(delegate: EssayBodyTableViewCellDelegate, text: String, inputAccessoryView: UIView?) {
        self.delegate = delegate
        self.text = text
        self.inputAccessoryView = inputAccessoryView
        
        // Set up select code, where if the cell is selected it will tell the delegate to run didPressShowMore.. kinda neat!
        didSelect = { view, indexPath in
            if let tableView = view as? UITableView {
                if let bodyCell = tableView.cellForRow(at: indexPath) as? EssayBodyTableViewCell {
                    delegate.didPressShowMore(cell: bodyCell)
                } else {
                    print("Tried to select cell but it wasn't an EssayBodyTableViewCell")
                }
            } else {
                fatalError("View in didSelect block not a UITableView!")
            }
        }
    }
    
}
