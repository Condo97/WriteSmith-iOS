//
//  LoadingTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

class LoadingChatTableViewCellSource: LoadingTableViewCellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Chat.View.Table.Cell.loading.reuseID
    
    var view: UIView?
    
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
