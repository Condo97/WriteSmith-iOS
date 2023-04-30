//
//  EssayViewController+EssayBodyTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: EssayBodyTableViewCellDelegate {
    
    func didPressShowMore(cell: EssayBodyTableViewCell) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Show more
        if cell.essayHeightConstraint.priority >= .defaultHigh {
            // Expand Essay to Show More
            
            UIView.performWithoutAnimation {
                rootView.tableView.beginUpdates()
                cell.essayHeightConstraint.priority = .defaultLow
                cell.halfRoundedView.setNeedsDisplay()
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
    
    func didPressShowLess(cell: EssayBodyTableViewCell) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Show less
        UIView.performWithoutAnimation {
            rootView.tableView.beginUpdates()
            cell.essayHeightConstraint.priority = .defaultHigh
            cell.halfRoundedView.setNeedsDisplay()
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
    
    func essayTextDidChange(cell: EssayBodyTableViewCell, textView: UITextView) {
        
    }
    
    func essayTextDidBeginEditing(cell: EssayBodyTableViewCell, textView: UITextView) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
    }
    
    func essayTextDidEndEditing(cell: EssayBodyTableViewCell, textView: UITextView) {
        //Need to reset text view if "cancel" pressed, or present a view saying "do you want to save changes?" if editing ended any other way
        
        
        // Actually all this should just be called on the "Save" button click
        guard let row = rootView.tableView.indexPath(for: cell)?.row else {
            print("Could not find row of cell to save edits...")
            return
        }
        
        // Get current essay
        let objectIndex = row / 2
        let currentEssay = essays[objectIndex]
        
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
            
            // Update the currentEssay essayText
            currentEssay.essay = textView.text
            
            // Save the Essay
            guard EssayCDHelper.saveContext() else {
                print("Could not save the essay in context...")
                return
            }
            
            // Show the "- Edited" text of the Prompt cell
            guard let section = rootView.tableView.indexPath(for: cell)?.section else {
                print("Couldn't get the section for the edit text update... should update next time user loads this view...")
                shouldSaveEdit = .none
                return
            }
            
            guard let promptCell = rootView.tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? EssayPromptTableViewCell else {
                print("Couldn't update edit text here... should update next time user loads this view...")
                shouldSaveEdit = .none
                return
            }
            
            promptCell.editedLabel.alpha = 1.0
            
        } else {
            textView.text = essayText
        }
        
        shouldSaveEdit = .none
    }
    
}
