//
//  MainNavigationViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/12/23.
//

import UIKit

class MainNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultHasFinishedIntro) {
            setNavigationBarHidden(true, animated: false)
            
            let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "introStart")
            viewControllers = [mainViewController]
        }
    }
}
