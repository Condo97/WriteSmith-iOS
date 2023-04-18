//
//  ChatIntroInteractiveViewController+ChatTableViewTouchDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/24/23.
//

import Foundation

extension ChatIntroInteractiveViewController: ManagedTableViewTouchDelegate {
    
    func tappedIndexPath(_ indexPath: IndexPath, tableView: UITableView, touch: UITouch) {
        // If the tableView is choiceTableView, remove the cell from it, animate showing of the next button that reduces size of choiceTableView, add the user chat source and a loading source to the chatTableView, then after a delay add the ai chat source with a typewriter
        if tableView == rootView.choiceTableView {
            // Get source
            let source = rootView.choiceTableView.manager?.sourceFrom(indexPath: indexPath) as? ChatTableViewCellSource
            if let preloadedResponseChatObject = source?.chat as? PreloadedResponseChatObject {
                let responseChatObject = ChatObject(text: preloadedResponseChatObject.responseText, sender: preloadedResponseChatObject.responseSender)
                let responseChatTableViewCellSource = TableViewCellSourceFactory.makeChatTableViewCellSource(fromChatObject: responseChatObject)
                
                // Remove cell
                rootView.choiceTableView.deleteManagedRow(at: indexPath, with: .fade)
                
                // If there are no more ChatTableViewCellSource objects in choiceTableView manager, animate its height going to 0 TODO: make this better and more efficient
                var containsChatRowSource = false
                for i in 0..<(rootView.choiceTableView.manager?.sources.count)! {
                    let sources = rootView.choiceTableView.manager?.sources[i]
                    for j in 0..<sources!.count {
                        if sources![j] is ChatTableViewCellSource {
                            containsChatRowSource = true
                            break
                        }
                    }
                }
                
                if !containsChatRowSource {
                    // Animate decrease choiceTableViewHeightConstraint
                    UIView.animate(withDuration: 0.4, delay: 0.0, animations: {
                        self.rootView.choiceTableViewHeightConstraint.constant = 0.0
                        
                        self.rootView.layoutIfNeeded()
                    })
                }
                
                // Get section and rowCount
                let section = indexPath.section
                let rowCount = rootView.chatTableView.numberOfRows(inSection: section)
                
                // Append chat row source
                rootView.chatTableView.appendManagedRow(bySource: source!, inSection: section, with: .fade)
                
                // Insert loading row source, +1 to row count becuase of appended chat row source
                rootView.chatTableView.insertManagedRow(bySource: LoadingChatTableViewCellSource(), at: IndexPath(row: rowCount + 1, section: section), with: .fade)
                
                // Enable scrolling for chatTableView (disabled in IB)
                rootView.chatTableView.isScrollEnabled = true
                
                // Do animations on the main thread
                DispatchQueue.main.async {
                    // Animate increase height of nextViewHeightConstraint and decrease height of choiceTableViewHeightConstraint with a slight delay to allow for tableViewCell deletion animation
                    UIView.animate(withDuration: 0.4, delay: 0.2, animations: {
                        // TODO: - Should this value be moved, or is it specific enough to remain as a number?
                        let nextButtonViewHeight = 84.0
                        
                        self.rootView.choiceTableViewHeightConstraint.constant -= nextButtonViewHeight
                        self.rootView.nextViewHeightConstraint.constant = nextButtonViewHeight
                        
                        // Need to call setNeedsDisplay to redraw nextButton so the background can show
                        self.rootView.nextButton.setNeedsDisplay()
                        
                        // Need to call layoutIfNeeded for it to animate
                        self.rootView.layoutIfNeeded()
                    })
                    
                    UIView.animate(withDuration: 0.4, delay: 0.4, animations: {
                        self.rootView.nextButton.alpha = 1.0
                        self.rootView.nextButton.layoutIfNeeded()
                    })
                }
                
                // Scroll to bottom if not already at bottom
                scrollToBottomSectionIfNotAlready(tableView: rootView.chatTableView, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    // Remove loading row source
                    self.rootView.chatTableView.deleteManagedRow(at: IndexPath(row: rowCount + 1, section: section), with: .fade)
                    
                    // A little more time for the loading row to animate away :)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        // Create Typewriter for response source, here because it will start before the delays otherwise
                        let prevChatTableViewContentSizeHeight = self.rootView.chatTableView.contentSize.height
                        responseChatTableViewCellSource.typewriter = Typewriter.start(text: responseChatTableViewCellSource.chat.text, timeInterval: Constants.freeTypingTimeInterval, typingUpdateLetterCount: responseChatTableViewCellSource.chat.text.count/Constants.introTypingUpdateLetterCountFactor + 1, block: { typewriter, currentText in
                            DispatchQueue.main.async {
                                if !typewriter.isValid() {
                                    // Do something when the typewriter finishes maybe?
                                }
                                
                                if prevChatTableViewContentSizeHeight <
                                    self.rootView.chatTableView.contentSize.height {
                                    // TODO: - Implement better way to scroll to bottom
                                    if self.rootView.chatTableView.isAtBottom() {
                                        self.rootView.chatTableView.reallyScrollToRow(at: IndexPath(row: 0, section: self.rootView.chatTableView.numberOfSections - 1), at: .bottom, animated: false)
                                    }
                                }
                                
                                self.rootView.chatTableView.reloadData()
                            }
                        })
                        
                        // Append response
                        self.rootView.chatTableView.appendManagedRow(bySource: responseChatTableViewCellSource, inSection: section, with: .fade)
                        
                        // Scroll to bottom if not already at bottom
                        self.scrollToBottomSectionIfNotAlready(tableView: self.rootView.chatTableView, animated: true)
                    })
                })
            }
        }
    }
    
    private func scrollToBottomSectionIfNotAlready(tableView: UITableView, animated: Bool) {
        // Scroll to top row of bottom section if not already at bottom
        if !tableView.isAtBottom() {
            // TODO: - Implement better way to scroll to bottom
            tableView.reallyScrollToRow(at: IndexPath(row: 0, section: tableView.numberOfSections - 1), at: .bottom, animated: animated)
        }
    }
    
}
