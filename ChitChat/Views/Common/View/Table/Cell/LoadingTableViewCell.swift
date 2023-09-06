//
//  EssayLoadingTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/24/23.
//

import CoreData
import UIKit

class LoadingTableViewCell: UITableViewCell, PulsatingDotsCell {

    @IBOutlet weak var loadingView: UIView!
    
    var pulsatingDotsAnimation: PulsatingDotsAnimation? {
        didSet {
            // Remove loadingView subviews and add dotsView if it can be unwrapped TODO: Is this a good way to do this?
            loadingView.subviews.forEach({$0.removeFromSuperview()})
            
            if let dotsView = pulsatingDotsAnimation?.dotsView {
                loadingView.addSubview(dotsView)
            }
        }
    }
    var pulsatingDotsBounds: CGRect {
        get {
            loadingView.bounds
        }
        set {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
//    func configure(managedObject: NSManagedObject) {
//        // Setup loadingSource pulsatingDotsAnimation if necessary
//        if loadingSource.pulsatingDotsAnimation == nil {
//            loadingSource.setPulsatingDotsAnimation(PulsatingDotsAnimation.createAnimation(frame: self.loadingView.bounds, amount: 4, duration: 1, color: loadingSource.dotColor))
//        }
//
//        loadingSource.pulsatingDotsAnimation?.start()
//        loadingView.addSubview(loadingSource.pulsatingDotsAnimation!.dotsView)
//    }

}
