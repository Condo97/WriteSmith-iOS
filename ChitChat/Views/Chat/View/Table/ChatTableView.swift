//
//  ChatTableView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/15/23.
//

import UIKit

/***
 Easy append, insert, and delete, synchronizing with chatRowSources
 - Delegate and DataSource should be ChatTableViewManagerProtocol to enable UITableViewCellSource appending
 */
class ChatTableView: UITableView {
    
    var shouldBounce: Bool = true
    var touchDelegate: TableViewTouchDelegate?
    
    func bounceAt(indexPath: IndexPath) {
        // Get the Bounceable cell if it is and unbounce
        if let cell = self.cellForRow(at: indexPath) as? Bounceable {
            cell.beginBounce() {}
        }
    }
    
    func unbounceAt(indexPath: IndexPath) {
        // Get the Bounceable cell if it is and unbounce
        if let cell = self.cellForRow(at: indexPath) as? Bounceable {
            cell.endBounce() {}
        }
    }
}

/***
 Touchy code
 */
extension ChatTableView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    // Send touchesBegan to subviews
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Bounce ChatTableView if bounce enabled
        if shouldBounce {
            if let touch = touches.first {
                let indexPath = getIndexPath(from: touch)
                
                if indexPath != nil {
                    // Only bounceable cells can be bounced!
                    guard let cell = self.cellForRow(at: indexPath!) as? Bounceable else {
                        return
                    }
                    
                    cell.beginBounce() {}
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let touch = touches.first {
            // BounceRelease if bounce enabled, send "tappedCell"
            let indexPath = getIndexPath(from: touch)
            if indexPath != nil {
                // Unbounce
                unbounceAt(indexPath: indexPath!)
                
                // Get the UITableViewCell and send through the touchDelegate
                touchDelegate?.tappedIndexPath(indexPath!, tableView: self, touch: touch)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if let touch = touches.first {
            let indexPath = getIndexPath(from: touch)
            if indexPath != nil {
                unbounceAt(indexPath: indexPath!)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch = touches.first {
            let indexPath = getIndexPath(from: touch)
            if indexPath != nil {
                unbounceAt(indexPath: indexPath!)
            }
        }
    }
    
    private func getIndexPath(from touch: UITouch) -> IndexPath? {
        let location = touch.location(in: self)
        return self.indexPathForRow(at: location)
    }
    
}
