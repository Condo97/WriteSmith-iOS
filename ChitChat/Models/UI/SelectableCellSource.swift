//
//  SelectableTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/13/23.
//

import Foundation

protocol SelectableCellSource: CellSource {
    
    var didSelect: ((UIView, IndexPath)->Void)? { get set }
    
}
