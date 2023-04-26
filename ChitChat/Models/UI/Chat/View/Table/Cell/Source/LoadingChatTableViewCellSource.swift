//
//  LoadingTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

class LoadingChatTableViewCellSource: LoadingTableViewCellSource {
    
    var reuseIdentifier: String = Registry.Chat.View.TableView.Cell.loading.reuseID
    
    var pulsatingDotsAnimation: PulsatingDotsAnimation?
    var dotColor: UIColor
    
    convenience init() {
        self.init(dotColor: Colors.elementBackgroundColor)
    }
    
    init(dotColor: UIColor) {
        self.dotColor = dotColor
    }
    
    func setPulsatingDotsAnimation(_ pulsatingDotsAnimation: PulsatingDotsAnimation) {
        self.pulsatingDotsAnimation = pulsatingDotsAnimation
    }
    
}