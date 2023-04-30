//
//  ButtonCollectionViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/27/23.
//

import Foundation

class RoundedViewLabelCollectionViewCell: UICollectionViewCell, LoadableCell {
    
    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var label: UILabel!
    
    private let DEFAULT_LABEL_FONT_SIZE: CGFloat = 17.0
    
    func loadWithSource(_ source: CellSource) {
        if let buttonSource = source as? ButtonCollectionViewCellSource {
            // Set button title
            label.text = buttonSource.buttonTitle
            label.text = buttonSource.buttonTitle
            
            if buttonSource.selected {
                // If selected, set dark as background and light as text
                roundedView.backgroundColor = buttonSource.darkColor
                label.textColor = buttonSource.lightColor
                label.font = UIFont(name: Constants.primaryFontNameBold, size: DEFAULT_LABEL_FONT_SIZE)
            } else {
                // If not selected, set light as background and dark as text
                roundedView.backgroundColor = buttonSource.lightColor
                label.textColor = buttonSource.darkColor
                label.font = UIFont(name: Constants.primaryFontName, size: DEFAULT_LABEL_FONT_SIZE)
            }
        }
    }
    
}
