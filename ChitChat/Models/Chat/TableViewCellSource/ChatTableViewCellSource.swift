//
//  ChatTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

class ChatTableViewCellSource: UITableViewCellSource {
    
    var typingLabel: UILabel?
    var typingUpdateLetterCount: Int = Constants.defaultTypingUpdateLetterCount 
    
    var reuseIdentifier: String {
        switch chat.sender {
        case .user:
            return Registry.View.TableView.Chat.Cells.user.reuseID
        case .ai:
            return Registry.View.TableView.Chat.Cells.ai.reuseID
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
