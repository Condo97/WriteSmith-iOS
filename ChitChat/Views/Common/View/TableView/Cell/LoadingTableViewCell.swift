//
//  EssayLoadingTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/24/23.
//

import UIKit

class LoadingTableViewCell: UITableViewCell, LoadableTableViewCell {

    @IBOutlet weak var loadingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadWithSource(_ source: TableViewCellSource) {
        if let loadingSource = source as? LoadingEssayTableViewCellSource {
            // Setup loadingSource pulsatingDotsAnimation if necessary
            if loadingSource.pulsatingDotsAnimation == nil {
                loadingSource.pulsatingDotsAnimation = PulsatingDotsAnimation.createAnimation(frame: self.loadingView.bounds, amount: 4, duration: 1, color: loadingSource.dotColor)
            }
            
            loadingSource.pulsatingDotsAnimation?.start()
            loadingView.addSubview(loadingSource.pulsatingDotsAnimation!.dotsView)
        }
    }

}
