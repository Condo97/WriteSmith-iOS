//
//  EditableSource.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/10/23.
//

import Foundation
import UIKit

protocol EditableCellSource: CellSource {
    
    var canEdit: Bool { get set }
    
    var commit: ((UIView, IndexPath, UITableViewCell.EditingStyle)->Void)? { get set }
    
}
