//
//  EssayViewController+EssayEssayTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/4/23.
//

import Foundation

extension EssayViewController: EssayEssayTableViewCellDelegate {
    
    func didPressCopyText(cell: EssayEssayTableViewCell) {
        // Find and unwrap the cell's indexPath for looking up the current essay otherwise return
        guard let cellIndexPath = self.rootView.tableView.indexPath(for: cell) else {
            // TODO: Handle errors
            print("Could not find the indexPath for the cell in didPressCopyText in EssayEssayTableViewCellDelegate in EssayViewController!")
            return
        }
        
        // Get and unwrap the current essay from the cell indexPath
        guard let currentEssay = self.fetchedResultsTableViewDataSource?.object(for: cellIndexPath) else {
            // TODO: Handle errors
            print("Could not unwrap the essay for the cell in didPressCopyText in EssayEssayTableViewCellDelegate in EssayViewController!")
            return
        }
        
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Get essay rtext
        guard let essayText = currentEssay.essay else {
            print("Could not cast the essay as String when trying to copy...")
            return
        }
        
        // Copy to Pasteboard
        var text = essayText
        
        //TODO: - Make the footer text an option in settings instead of disabling it for premium entirely
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            if !PremiumHelper.get(), let shareURL = UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) {
                text = "\(text)\n\n\(Constants.copyFooterText)\n\(shareURL)"
            } else {
                text = "\(text)\n\n\(Constants.copyFooterText)"
            }
        }
        
        UIPasteboard.general.string = text
        
        // Animate Copy
        UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
            cell.copiedLabel.alpha = 1.0
            
            UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                cell.copiedLabel.alpha = 0.0
            })
        })
    }
    
    func didPressShare(cell: EssayEssayTableViewCell) {
        // Find and unwrap the cell's indexPath for looking up the current essay otherwise return
        guard let cellIndexPath = self.rootView.tableView.indexPath(for: cell) else {
            // TODO: Handle errors
            print("Could not find the indexPath for the cell in didPressShare in EssayEssayTableViewCellDelegate in EssayViewController!")
            return
        }
        
        // Get and unwrap the current essay from the cell indexPath
        guard let currentEssay = self.fetchedResultsTableViewDataSource?.object(for: cellIndexPath) else {
            // TODO: Handle errors
            print("Could not unwrap the essay for the cell in didPressShare in EssayEssayTableViewCellDelegate in EssayViewController!")
            return
        }
        
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Get prompt text
        guard let promptText = currentEssay.prompt else {
            print("Prompt was nil when trying to share...")
            return
        }
        
        // Get essay text
        guard let essayText = currentEssay.essay else {
            print("Essay text was nil when trying to share...")
            return
        }
        
        // Append footer text TODO: - Should this be changed to check for ultra?
        let text = "Prompt: \(promptText)\n\n\(essayText)\n\n\(Constants.copyFooterText)"
        
        ShareViewHelper.share(text, viewController: self)
    }
    
    func didPressDeleteRow(cell: EssayEssayTableViewCell) {
        // Do haptic
        HapticHelper.doWarningHaptic()
        
        //TODO: - Delete row
        let ac = UIAlertController(title: "Delete", message: "Are you sure you'd like to delete this Essay?", preferredStyle: .alert)
        ac.view.tintColor = Colors.alertTintColor
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { UIAlertAction in
            // Find and unwrap the cell's indexPath for looking up the current essay otherwise return
            guard let cellIndexPath = self.rootView.tableView.indexPath(for: cell) else {
                // TODO: Handle errors
                print("Could not find the indexPath for the cell in didPressDeleteRow in EssayEssayTableViewCellDelegate in EssayViewController!")
                return
            }
            
            // Get and unwrap the current essay from the cell indexPath
            guard let currentEssay = self.fetchedResultsTableViewDataSource?.object(for: cellIndexPath) else {
                // TODO: Handle errors
                print("Could not unwrap the essay for the cell in didPressDeleteRow in EssayEssayTableViewCellDelegate in EssayViewController!")
                return
            }
            
            // Do haptic
            HapticHelper.doMediumHaptic()
            
            // Delete essay and update tableView if successful
            Task {
                do {
                    try await EssayCDHelper.deleteEssay(essayObjectID: currentEssay.objectID)
                    
//                    DispatchQueue.main.async {
//                        // Delete at same index twice to remove both the prompt and body
//                        self.sourcedTableViewManager.sources[self.essaySection].remove(at: row)
//                        self.sourcedTableViewManager.sources[self.essaySection].remove(at: row)
//
//                        self.rootView.tableView.reloadData()
//                    }
                } catch {
                    // TODO: Handle error
                    print("Could not delete essay in EssayViewController EssayPromptTableViewCellDelegate didPressDeleteRow... \(error)")
                }
            }
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            // Do haptic
            HapticHelper.doLightHaptic()
        }))
        present(ac, animated: true)
    }
    
    func didPressCancelEditing(cell: EssayEssayTableViewCell) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Set shouldSaveEdit to cancel and dismiss keyboard
        shouldSaveEdit = .cancel
        dismissKeyboard()
    }
    
    func didPressSaveEditing(cell: EssayEssayTableViewCell) {
        // Do haptic
        HapticHelper.doMediumHaptic()
        
        // Set shouldSaveEdit to save and dismiss keyboard
        shouldSaveEdit = .save
        dismissKeyboard()
    }
    
    func didPressShowMore(cell: EssayEssayTableViewCell) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Show more
        if cell.essayHeightConstraint.priority >= .defaultHigh {
            // Expand Essay to Show More
            
            UIView.performWithoutAnimation {
                rootView.tableView.beginUpdates()
                cell.essayHeightConstraint.priority = .defaultLow
                cell.roundedView.setNeedsDisplay()
                cell.showLessButton.alpha = 1.0
                cell.showLessHeightConstraint.constant = 20.0
                cell.showMoreGradientView.alpha = 0.0
                cell.showMoreSolidView.alpha = 0.0
                cell.showMoreLabel.text = ""
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                rootView.tableView.endUpdates()
            }
            
            // Make Essay editable
            cell.essayTextView.isEditable = true
        }
    }
    
    func didPressShowLess(cell: EssayEssayTableViewCell) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Show less
        UIView.performWithoutAnimation {
            rootView.tableView.beginUpdates()
            cell.essayHeightConstraint.priority = .defaultHigh
            cell.roundedView.setNeedsDisplay()
            cell.showLessButton.alpha = 0.0
            cell.showLessHeightConstraint.constant = 0.0
            cell.showMoreGradientView.alpha = 1.0
            cell.showMoreSolidView.alpha = 1.0
            cell.showMoreLabel.text = "Show More..."
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            rootView.tableView.endUpdates()
        }
        
        // Make textview not editable
        cell.essayTextView.isEditable = false
    }
    
    func essayTextDidChange(cell: EssayEssayTableViewCell, textView: UITextView) {
        
    }
    
    func essayTextDidBeginEditing(cell: EssayEssayTableViewCell, textView: UITextView) {
        // Do haptic
        HapticHelper.doLightHaptic()
    }
    
    func essayTextDidEndEditing(cell: EssayEssayTableViewCell, textView: UITextView) {
        //Need to reset text view if "cancel" pressed, or present a view saying "do you want to save changes?" if editing ended any other way
        
        
        // Find and unwrap the cell's indexPath for looking up the current essay otherwise return
        guard let cellIndexPath = self.rootView.tableView.indexPath(for: cell) else {
            // TODO: Handle errors
            print("Could not find the indexPath for the cell in didPressDeleteRow in EssayEssayTableViewCellDelegate in EssayViewController!")
            return
        }
        
        // Get and unwrap the current essay from the cell indexPath
        guard let currentEssay = self.fetchedResultsTableViewDataSource?.object(for: cellIndexPath) else {
            // TODO: Handle errors
            print("Could not unwrap the essay for the cell in didPressDeleteRow in EssayEssayTableViewCellDelegate in EssayViewController!")
            return
        }
        
        guard let essayText = currentEssay.essay else {
            print("Essay was nil when trying to save edits...")
            return
        }
        
        if textView.text == essayText {
            print("No changes to save...")
            return
        }
        
        if shouldSaveEdit == .none {
            // Prompt the user confirming if they'd like to save or not
            let ac = UIAlertController(title: "Unsaved Edits", message: "You edited this essay. Would you like to save your edits?", preferredStyle: .alert)
            ac.view.tintColor = Colors.alertTintColor
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { UIAlertAction in
                self.shouldSaveEdit = .cancel
                self.essayTextDidEndEditing(cell: cell, textView: textView)
            }))
            ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { UIAlertAction in
                self.shouldSaveEdit = .save
                self.essayTextDidEndEditing(cell: cell, textView: textView)
            }))
            present(ac, animated: true)
            
        } else if shouldSaveEdit == .save {
            // Update and save the currentEssay essayText
            Task {
                do {
                    try await EssayCDHelper.updateEssay(essayObjectID: currentEssay.objectID, withText: essayText)
                } catch {
                    print("Could not update and save essay in EssayViewController EssayBodyTableVIewCellDelegate essayTextDidEndEditing!")
                }
                
                cell.editedLabel.alpha = 1.0
            }
            
        } else {
            textView.text = essayText
        }
        
        shouldSaveEdit = .none
    }
    
    
    
    
}
