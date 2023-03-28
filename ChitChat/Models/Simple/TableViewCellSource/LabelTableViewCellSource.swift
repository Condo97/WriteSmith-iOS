//
//  LabelTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/25/23.
//

import Foundation

class LabelTableViewCellSource: UITableViewCellSource {
    
    var reuseIdentifier: String = Registry.View.TableView.Simple.Cells.label.reuseID
    var text: String
    var font: UIFont
    var color: UIColor
    
    var heightConstraintConstant: CGFloat?
    var topSpaceConstraintConstant: CGFloat
    var bottomSpaceConstraintConstant: CGFloat
    
    convenience init() {
        self.init(text: "", font: UIFont(name: Constants.primaryFontName, size: UIConstants.defaultLabelTableViewCellSourceFontSize)!)
    }
    
    convenience init(text: String, font: UIFont) {
        self.init(text: text, font: font, color: UIConstants.defaultLabelTableViewCellSourceColor)
    }
    
    convenience init(text: String, font: UIFont, color: UIColor) {
        self.init(text: text, font: font, color: color, heightConstraintConstant: nil)
    }
    
    convenience init(text: String, font: UIFont, color: UIColor, heightConstraintConstant: CGFloat?) {
        self.init(text: text, font: font, color: color, heightConstraintConstant: heightConstraintConstant, topSpaceConstraintConstant: UIConstants.defaultLabelTableViewCellSourceConstraintConstant, bottomSpaceConstraintConstant: UIConstants.defaultLabelTableViewCellSourceConstraintConstant)
    }
    
    init(text: String, font: UIFont, color: UIColor, heightConstraintConstant: CGFloat?, topSpaceConstraintConstant: CGFloat, bottomSpaceConstraintConstant: CGFloat) {
        self.text = text
        self.font = font
        self.color = color
        self.heightConstraintConstant = heightConstraintConstant
        self.topSpaceConstraintConstant = topSpaceConstraintConstant
        self.bottomSpaceConstraintConstant = bottomSpaceConstraintConstant
    }
    
}
