//
//  ChatTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

class ChatTableViewCellSource: CellSource {
    
    var typingLabel: UILabel?
    var typingUpdateLetterCount: Int = Constants.defaultTypingUpdateLetterCount 
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? {
        switch chat.sender {
        case Constants.Chat.Sender.user:
            return Registry.Chat.View.TableView.Cell.user.reuseID
        case Constants.Chat.Sender.ai:
            return Registry.Chat.View.TableView.Cell.ai.reuseID
        default:
            fatalError("Invalid chat sender.")
        }
    }
    
    var chat: Chat
    var typewriter: Typewriter?
    
    convenience init(chat: Chat) {
        self.init(chat: chat, typewriter: nil)
    }
    
    init(chat: Chat, typewriter: Typewriter?) {
        self.chat = chat
        self.typewriter = typewriter
    }
    
}
