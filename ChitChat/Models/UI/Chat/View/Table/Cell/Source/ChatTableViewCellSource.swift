//
//  ChatTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

protocol ChatTableViewCellSourceDelegate {
    func delete(source: ChatTableViewCellSource, in view: UIView, for indexPath: IndexPath)
}

class ChatTableViewCellSource: CellSource, EditableCellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? {
        switch chat.sender {
        case Constants.Chat.Sender.user:
            return Registry.Chat.View.TableView.Cell.user.reuseID
        case Constants.Chat.Sender.ai:
            return Registry.Chat.View.TableView.Cell.ai.reuseID
        default:
            return nil
        }
    }
    
    var canEdit: Bool
    var commit: ((UIView, IndexPath, UITableViewCell.EditingStyle) -> Void)?
    
    var typingLabel: UILabel?
    var view: UIView?
    var typingUpdateLetterCount: Int = Constants.defaultTypingUpdateLetterCount
    
    var isTyping: Bool
    var typingText: String = ""
    
    var chat: Chat
    
    var delegate: ChatTableViewCellSourceDelegate
    
    
    convenience init(chat: Chat, isTyping: Bool, delegate: ChatTableViewCellSourceDelegate) {
        self.init(chat: chat, canEdit: true, isTyping: isTyping, delegate: delegate)
    }
    
    init (chat: Chat, canEdit: Bool, isTyping: Bool, delegate: ChatTableViewCellSourceDelegate) {
        self.chat = chat
        self.canEdit = canEdit
        self.isTyping = isTyping
        self.delegate = delegate
        
        self.commit = {view, indexPath, editingStyle in
            if editingStyle == .delete {
                self.delegate.delete(source: self, in: view, for: indexPath)
            }
        }
    }
    
}
