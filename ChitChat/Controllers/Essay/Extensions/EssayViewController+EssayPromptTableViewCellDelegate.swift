//
//  EssayViewController+EssayPromptTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: EssayPromptTableViewCellDelegate {
    func didPressCopyText(cell: EssayPromptTableViewCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            print("Could not find section of cell to copy...")
            return
        }
        
        // There will be an extra section if user is not premium
        var premiumPurchaseSectionShowing = 0
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            premiumPurchaseSectionShowing = 1
        }
        
        // Just to note, this would be essays.count - section - 1 + 1, -1 for the .count and +1 for the entry section
        if essays.count - section + premiumPurchaseSectionShowing < 0 {
            print("Could not find essay to copy because it is out of range...")
            return
        }
        
        let currentEssay = essays[essays.count - section + premiumPurchaseSectionShowing]
        guard let essayText = currentEssay.value(forKey: Constants.coreDataEssayEssayObjectName) as? String else {
            print("Could not cast the essay as String when trying to copy...")
            return
        }
        
        guard let essayCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as? EssayBodyTableViewCell else {
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
            essayCell.copiedLabel.alpha = 1.0
            
            UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                essayCell.copiedLabel.alpha = 0.0
            })
        })
    }
    
    func didPressShare(cell: EssayPromptTableViewCell) {
        // Share row with appended footer text
        guard let section = tableView.indexPath(for: cell)?.section else {
            print("Could not find section of cell to share...")
            return
        }
        
        // There will be an extra section if user is not premium
        var premiumPurchaseSectionShowing = 0
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            premiumPurchaseSectionShowing = 1
        }
        
        // Just to note, this would be essays.count - section - 1 + 1, -1 for the .count and +1 for the entry section
        if essays.count - section + premiumPurchaseSectionShowing < 0 {
            print("Could not find essay to share because it is out of range...")
            return
        }
        
        let currentEssay = essays[essays.count - section + premiumPurchaseSectionShowing]
        guard let promptText = currentEssay.value(forKey: Constants.coreDataEssayPromptObjectName) as? String else {
            print("Could not cast the prompt as String when trying to share...")
            return
        }
        
        guard let essayText = currentEssay.value(forKey: Constants.coreDataEssayEssayObjectName) as? String else {
            print("Could not cast the essay as String when trying to share...")
            return
        }
        
        let text = "Prompt: \(promptText)\n\n\(essayText)\n\n\(Constants.copyFooterText)"
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: [])
        
        present(activityVC, animated: true)
    }
    
    func didPressDeleteRow(cell: EssayPromptTableViewCell) {
        //TODO: - Delete row
        let ac = UIAlertController(title: "Delete", message: "Are you sure you'd like to delete this Essay?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { UIAlertAction in
            guard let section = self.tableView.indexPath(for: cell)?.section else {
                print("Could not find section of cell to delete...")
                return
            }
            // Just to note, this would be essays.count - section - 1 + 1, -1 for the .count and +1 for the entry section
            if self.essays.count - section < 0 {
                print("Could not find essay to delete because it is out of range...")
                return
            }
            // Actually delete the row and CD object
            let currentEssay = self.essays[self.essays.count - section]
            guard let id = currentEssay.value(forKey: Constants.coreDataEssayIDObjectName) as? Int else {
                print("Could not cast the ID as Int when trying to delete...")
                return
            }
            
            CDHelper.deleteEssay(id: id, essayArray: &self.essays, success: {
                DispatchQueue.main.async {
                    self.tableView.deleteSections(IndexSet(integer: section /* not -1 bc of entry section */), with: .middle)
                }
            })
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}
