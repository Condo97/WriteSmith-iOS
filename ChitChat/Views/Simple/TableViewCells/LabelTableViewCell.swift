//
//  LabelTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/25/23.
//

import Foundation
import UIKit

class LabelTableViewCell: UITableViewCell, LoadableTableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    func loadWithSource(_ source: UITableViewCellSource) {
        if let labelSource = source as? LabelTableViewCellSource {
            // Setup label text, font, and color
            label.text = labelSource.text
            label.font = labelSource.font
            label.textColor = labelSource.color
            
            // Setup height constriant conditional
            if labelSource.heightConstraintConstant == nil {
                heightConstraint.isActive = false
            } else {
                heightConstraint.isActive = true
                heightConstraint.constant = labelSource.heightConstraintConstant!
            }
            
            // Setup top and bottom constraints
            topSpaceConstraint.constant = labelSource.topSpaceConstraintConstant
            bottomSpaceConstraint.constant = labelSource.bottomSpaceConstraintConstant
        }
    }
    
}
