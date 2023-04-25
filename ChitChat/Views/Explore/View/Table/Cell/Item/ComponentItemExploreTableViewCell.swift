//
//  HeadedItemExploreTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

class ComponentItemExploreTableViewCell: UITableViewCell, LoadableCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    var detailAlertController: UIAlertController?
    
    var componentSourceView: UIView?
    
    @IBAction func detailButtonPressed(_ sender: Any) {
        if detailAlertController != nil {
            UIApplication.shared.topmostViewController()?.present(detailAlertController!, animated: true)
        }
    }
    
    override func draw(_ rect: CGRect) {
        componentSourceView?.frame = view.bounds
    }
    
    func loadWithSource(_ source: CellSource) {
        if let componentSource = source as? ComponentItemTableViewCellSource {
            // Set header text
            headerLabel.text = componentSource.headerText
            
            // If detailTitle or detialText are nil, hide the detailButton, otherwise show it and load the alertController
            if componentSource.detailTitle == nil || componentSource.detailText == nil {
                detailButton.isHidden = true
            } else {
                detailButton.isHidden = false
                
                detailAlertController = UIAlertController(
                    title: componentSource.detailTitle,
                    message: componentSource.detailText,
                    preferredStyle: .actionSheet)
                detailAlertController?.addAction(UIAlertAction(
                    title: "Close", style: .cancel))
            }
            
            componentSourceView = componentSource.view
            view.addSubview(componentSourceView!)
            
            viewHeightConstraint.constant = componentSource.viewHeight
            
        }
    }
    
}
