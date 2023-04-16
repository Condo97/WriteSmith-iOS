//
//  ChatTableViewCellSourceBuilder.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

import Foundation

class TableViewCellSourceFactory: Any {
    
    /***
     Chat Table View Cell Source
     */
    
    static func makeChatTableViewCellSource(fromChatObject chatObject: Chat) -> ChatTableViewCellSource {
        return makeChatTableViewCellSourceArray(fromChatObjectArray: [chatObject])[0]
    }
    
    static func makeChatTableViewCellSourceArray(fromChatObjectArray chatObjectArray: [Chat]) -> [ChatTableViewCellSource] {
        var sourceArray: [ChatTableViewCellSource] = []
        
        for obj in chatObjectArray {
            sourceArray.append(ChatTableViewCellSource(chat: obj, typewriter: nil))
        }
        
        return sourceArray
    }
    
    
    /***
     Essay Table View Cell Source
     */
    
    static func makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObject essayObject: Essay, delegate: Any, inputAccessoryView: UIView?) -> [TableViewCellSource]? {
        return makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObjectArray: [essayObject], delegate: delegate, inputAccessoryView: inputAccessoryView)
    }
    
    static func makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObjectArray essayObjectArray: [Essay], delegate: Any, inputAccessoryView: UIView?) -> [TableViewCellSource]? {
        guard let promptDelegate = delegate as? EssayPromptTableViewCellDelegate, let bodyDelegate = delegate as? EssayBodyTableViewCellDelegate else {
            return nil
        }
        
        var sourceArray: [TableViewCellSource] = []
        
        for obj in essayObjectArray {
            // Append prompt first
            sourceArray.append(makePromptEssayTableViewCellSource(fromEssayObject: obj, delegate: promptDelegate))
            
            // Then body
            sourceArray.append(makeBodyEssayTableViewCellSource(fromEssayObject: obj, delegate: bodyDelegate, inputAccessoryView: inputAccessoryView))
        }
        
        return sourceArray
    }
    
    
    static func makePromptEssayTableViewCellSource(fromEssayObject essayObject: Essay, delegate: EssayPromptTableViewCellDelegate) -> PromptEssayTableViewCellSource {
        return makePromptEssayTableViewCellSourceArray(fromEssayObjectArray: [essayObject], delegate: delegate)[0]
    }
    
    static func makePromptEssayTableViewCellSourceArray(fromEssayObjectArray essayObjectArray: [Essay], delegate: EssayPromptTableViewCellDelegate) -> [PromptEssayTableViewCellSource] {
        var sourceArray: [PromptEssayTableViewCellSource] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        for obj in essayObjectArray {
            sourceArray.append(PromptEssayTableViewCellSource(delegate: delegate, titleText: obj.prompt ?? "", dateText: dateFormatter.string(from: obj.date!), editedText: (obj.userEdited ? Constants.Essay.View.Table.Cell.Prompt.defaultEditedText : nil)))
        }
        
        return sourceArray
    }
    
    
    static func makeBodyEssayTableViewCellSource(fromEssayObject essayObject: Essay, delegate: EssayBodyTableViewCellDelegate, inputAccessoryView: UIView?) -> BodyEssayTableViewCellSource {
        return makeBodyEssayTableViewCellSourceArray(fromEssayObjectArray: [essayObject], delegate: delegate, inputAccessoryView: inputAccessoryView)[0]
    }
    
    static func makeBodyEssayTableViewCellSourceArray(fromEssayObjectArray essayObjectArray: [Essay], delegate: EssayBodyTableViewCellDelegate, inputAccessoryView: UIView?) -> [BodyEssayTableViewCellSource] {
        var sourceArray: [BodyEssayTableViewCellSource] = []
        
        for obj in essayObjectArray {
            sourceArray.append(BodyEssayTableViewCellSource(delegate: delegate, text: obj.essay ?? "", inputAccessoryView: inputAccessoryView))
        }
        
        return sourceArray
    }
    
    
    
    
    
}
