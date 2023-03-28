//
//  LoadingTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

class LoadingTableViewCellSource: UITableViewCellSource {
    var reuseIdentifier: String = Registry.View.TableView.Chat.Cells.loading.reuseID
    
    var pulsatingDotsAnimation: PulsatingDotsAnimation?
    var dotColor: UIColor
    
    convenience init() {
        self.init(dotColor: Colors.elementBackgroundColor)
    }
    
    init(dotColor: UIColor) {
        self.dotColor = dotColor
    }
}
