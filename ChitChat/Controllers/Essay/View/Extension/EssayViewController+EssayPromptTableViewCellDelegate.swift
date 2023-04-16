//
//  EssayViewController+EssayPromptTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: EssayPromptTableViewCellDelegate {
    func didPressCopyText(cell: EssayPromptTableViewCell) {
        guard let row = rootView.tableView.indexPath(for: cell)?.row else {
            print("Could not find row of cell to copy...")
            return
        }
        
        // Ensure the requested essay is not out of range
        let objectIndex = row / 2
        if essays.count - 1 - objectIndex < 0 {
            print("Could not find essay to copy because it is out of range...")
            return
        }
        
        let currentEssay = essays[essays.count - 1 - objectIndex]
        guard let essayText = currentEssay.value(forKey: Constants.coreDataEssayEssayObjectName) as? String else {
            print("Could not cast the essay as String when trying to copy...")
            return
        }
        
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
        // Share row with appended footer text
        guard let row = rootView.tableView.indexPath(for: cell)?.row else {
            print("Could not find row of cell to share...")
            return
        }
        
        // Ensure the requested essay is not out of range
        let objectIndex = row / 2
        if essays.count - 1 - objectIndex < 0 {
            print("Could not find essay to copy because it is out of range...")
            return
        }
        
        let currentEssay = essays[essays.count - 1 - objectIndex]
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
            guard let row = self.rootView.tableView.indexPath(for: cell)?.row else {
                print("Could not find row of cell to delete...")
                return
            }
            
            // Ensure the requested essay is not out of range
            let objectIndex = row / 2
            if self.essays.count - 1 - objectIndex < 0 {
                print("Could not find essay to copy because it is out of range...")
                return
            }
            
            // Actually delete the row and CD object
            let currentEssay = self.essays[self.essays.count - 1 - objectIndex]
            guard let id = currentEssay.value(forKey: Constants.coreDataEssayIDObjectName) as? Int else {
                print("Could not cast the ID as Int when trying to delete...")
                return
            }
            
            CDHelper.deleteEssay(id: id, essayArray: &self.essays, success: {
                DispatchQueue.main.async {
                    // Delete at same index twice to remove both the prompt and body
                    self.rootView.tableView.beginUpdates()
                    self.rootView.tableView.deleteManagedRow(at: IndexPath(row: row, section: self.essaySection), with: .automatic)
                    self.rootView.tableView.endUpdates()
                    
                    self.rootView.tableView.beginUpdates()
                    self.rootView.tableView.deleteManagedRow(at: IndexPath(row: row, section: self.essaySection), with: .automatic)
                    self.rootView.tableView.endUpdates()
                }
            })
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}
