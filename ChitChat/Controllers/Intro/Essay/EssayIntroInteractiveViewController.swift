//
//  EssayIntroInteractiveViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/23/23.
//

import Foundation

class EssayIntroInteractiveViewController: IntroInteractiveViewController, LoadableViewController {
    var rootView: EssayIntroInteractiveView!
    
    @IBOutlet weak var choicesTableView: UITableView! // TODO: Change to custom class, maybe same as ChatIntroInteractiveViewController choiceTableView
    
    let choices: [PreloadedResponseChatObject] = []
    
    override func viewDidLoad() {
        
    }
    
    
    //MARK: Builder Functions
    
    func set(rootView: EssayIntroInteractiveView) -> Self {
        self.rootView = rootView
        return self
    }
    
}
