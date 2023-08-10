//
//  EssayViewController+EssayPromptTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: EssayPromptTableViewCellDelegate {
    
    func didPressCopyText(cell: EssayPromptTableViewCell) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Get row or return
        guard let row = rootView.tableView.indexPath(for: cell)?.row else {
            print("Could not find row of cell to copy...")
            return
        }
        
        // Get current essay
        let objectIndex = row / 2
        let currentEssay = essays[objectIndex]
        
        // Get essay rtext
        guard let essayText = currentEssay.essay else {
            print("Could not cast the essay as String when trying to copy...")
            return
        }
        
        // Get essay body cell
        guard let essayBodyCell = rootView.tableView.cellForRow(at: IndexPath(row: row + 1, section: essaySection)) as? EssayBodyTableViewCell else {
            print("Could not locate the essay cell when trying to copy...")
            return
        }
        
        // Copy to Pasteboard
        var text = essayText
        
        //TODO: - Make the footer text an option in settings instead of disabling it for premium entirely
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            if let shareURL = UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) {
                text = "\(text)\n\n\(Constants.copyFooterText)\n\(shareURL)"
            } else {
                text = "\(text)\n\n\(Constants.copyFooterText)"
            }
        }
        
        UIPasteboard.general.string = text
        
        // Animate Copy
        UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
            essayBodyCell.copiedLabel.alpha = 1.0
            
            UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                essayBodyCell.copiedLabel.alpha = 0.0
            })
        })
    }
    
    func didPressShare(cell: EssayPromptTableViewCell) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Get row or return
        guard let row = rootView.tableView.indexPath(for: cell)?.row else {
            print("Could not find row of cell to share...")
            return
        }
        
        // Get current essay
        let objectIndex = row / 2
        let currentEssay = essays[objectIndex]
        
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
    
    func didPressDeleteRow(cell: EssayPromptTableViewCell) {
        // Do haptic
        HapticHelper.doWarningHaptic()
        
        //TODO: - Delete row
        let ac = UIAlertController(title: "Delete", message: "Are you sure you'd like to delete this Essay?", preferredStyle: .alert)
        ac.view.tintColor = Colors.alertTintColor
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { UIAlertAction in
            // Do haptic
            HapticHelper.doMediumHaptic()
            
            guard let row = self.rootView.tableView.indexPath(for: cell)?.row else {
                print("Could not find row of cell to delete...")
                return
            }
            
            // Ensure the requested essay is not out of range
            let objectIndex = row / 2
            
            // Actually delete the row and CD object
            var currentEssay = self.essays[objectIndex]
            
            // Delete essay and update tableView if successful
            Task {
                do {
                    try await EssayCDHelper.deleteEssay(&currentEssay)
                    
                    DispatchQueue.main.async {
                        // Delete at same index twice to remove both the prompt and body
                        self.sourcedTableViewManager.sources[self.essaySection].remove(at: row)
                        self.sourcedTableViewManager.sources[self.essaySection].remove(at: row)
                        
                        self.rootView.tableView.reloadData()
                    }
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
    
}
