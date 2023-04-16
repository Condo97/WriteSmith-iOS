//
//  EssayViewController+EntryEssayTableViewCellDelegat.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: EntryEssayTableViewCellDelegate {
    
    func didPressSubmitButton(sender: Any) {
        // If not premium and there are more essays than cap give the user an upgrade prompt
        AuthHelper.ensure(completion: {isPremium in
            if self.essays.count >= UserDefaults.standard.integer(forKey: Constants.userDefaultStoredFreeEssayCap) {
                let ac = UIAlertController(title: "Upgrade", message: "You've reached the limit for free essays. Please upgrade to get unlimited full-length essays.\n\n(3-Day Free Trial)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                    self.goToUltraPurchase()
                }))
                ac.addAction(UIAlertAction(title: "Close", style: .cancel))
                self.present(ac, animated: true)
                return
            }
        })
        
        guard let cell = rootView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EssayEntryTableViewCell else {
            print("Entry cell not visible! Not generating chat...")
            return
        }
        
        guard let inputText = cell.textView.text else {
            return
        }
        
        // Disable buttons
        disableButtons()
        
        // Update entry to placeholder text and update size
        cell.textView.text = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? inputPlaceholder : freeInputPlaceholder
        cell.textView.textColor = .lightText
        updateInputTextViewSize(textView: cell.textView)
        
        // Insert loading section at top of essaySection
        if !isProcessingChat {
            isProcessingChat = true
            
            self.rootView.tableView.beginUpdates()
            rootView.tableView.insertManagedRow(bySource: LoadingEssayTableViewCellSource(), at: IndexPath(row: 0, section: essaySection), with: .automatic)
            self.rootView.tableView.endUpdates()
        }
        
        ChatRequestHelper.get(inputText: inputText, completion: {responseText, finishReason, remaining in
            DispatchQueue.main.async {
                // Enable buttons
                self.enableButtons()
                
                // Delete loading section if isProcessingChat
                if self.isProcessingChat {
                    self.isProcessingChat = false
                    
                    self.rootView.tableView.beginUpdates()
                    self.rootView.tableView.deleteManagedRow(at: IndexPath(row: 0, section: self.essaySection), with: .automatic)
                    self.rootView.tableView.endUpdates()
                }
                
                // Trim first occurence of \n\n if it exists
                var trimmedResponseText = responseText
                if let firstOccurence = responseText.range(of: "\n\n") {
                    trimmedResponseText.removeSubrange(responseText.startIndex..<firstOccurence.upperBound)
                }
                
                // If finish reason is length and user is not premium append the length finish reason additional text
                if finishReason == FinishReasons.length && !PremiumHelper.get() {
                    trimmedResponseText += Constants.lengthFinishReasonAdditionalText
                }
                
                // Set firstChat to false
                self.firstChat = false
                
                // Add essay
                self.addEssay(prompt: inputText, essay: trimmedResponseText, userSent: .ai)
                
                // If user is not premium, and finish reason is limit, show a limit reached alert
                //            if !PremiumHelper.get() {
                //                let ac = UIAlertController(title: "Limit Reached", message: "You've reached your daily chat limit. Upgrade for unlimited chats...", preferredStyle: .alert)
                //                ac.addAction(UIAlertAction(title: "Close", style: .cancel))
                //                ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                //                    self.goToUltraPurchase()
                //                }))
                //                self.present(ac, animated: true)
                //            }
            }
        })
    }
    
}
