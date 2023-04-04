//
//  EssayViewController+EssayBodyTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: EssayBodyTableViewCellDelegate {
    func didPressShowLess(cell: EssayBodyTableViewCell) {
        // Show less
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            cell.essayHeightConstraint.priority = .defaultHigh
            cell.halfRoundedView.setNeedsDisplay()
            cell.showLessHeightConstraint.constant = 0
            cell.showMoreGradientView.alpha = 1
            cell.showMoreSolidView.alpha = 1
            cell.showMoreLabel.text = "Show More..."
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            tableView.endUpdates()
        }
        
        // Make textview not editable
        cell.essayTextView.isEditable = false
    }
    
    func essayTextDidChange(cell: EssayBodyTableViewCell, textView: UITextView) {
        
    }
    
    func essayTextDidBeginEditing(cell: EssayBodyTableViewCell, textView: UITextView) {
        
    }
    
    func essayTextDidEndEditing(cell: EssayBodyTableViewCell, textView: UITextView) {
        //Need to reset text view if "cancel" pressed, or present a view saying "do you want to save changes?" if editing ended any other way
        
        
        // Actually all this should just be called on the "Save" button click
        guard let section = tableView.indexPath(for: cell)?.section else {
            print("Could not find section of cell to save edits...")
            return
        }
        
        // There will be an extra section if user is not premium
        var premiumPurchaseSectionShowing = 0
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            premiumPurchaseSectionShowing = 1
        }
        
        // Just to note, this would be essays.count - section - 1 + 1, -1 for the .count and +1 for the entry section
        if essays.count - section + premiumPurchaseSectionShowing < 0 {
            print("Could not find essay to save edits to because it is out of range...")
            return
        }
        
        let currentEssay = essays[essays.count - section + premiumPurchaseSectionShowing]
        guard let id = currentEssay.value(forKey: Constants.coreDataEssayIDObjectName) as? Int else {
            print("Could not cast the ID as Int when trying to save edits...")
            return
        }
        
        guard let essayText = currentEssay.value(forKey: Constants.coreDataEssayEssayObjectName) as? String else {
            print("Could not cast the essay as String when trying to save edits...")
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
            CDHelper.updateEssay(id: id, newEssay: textView.text, userEdited: true, essayArray: &essays)
            
            // Show the "- Edited" text of the Prompt cell
            guard let section = tableView.indexPath(for: cell)?.section else {
                print("Couldn't get the section for the edit text update... should update next time user loads this view...")
                shouldSaveEdit = .none
                return
            }
            
            guard let promptCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? EssayPromptTableViewCell else {
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
