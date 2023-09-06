//
//  IntroViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import UIKit

class IntroViewController: StackedViewController {
    
    var image: UIImage?
    
    lazy var rootView: IntroView! = {
        RegistryHelper.instantiateAsView(nibName: Registry.Intro.View.intro, owner: self) as? IntroView
    }()!
    
    override func loadView() {
        super.loadView()
        
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Set rootView delegate */
        rootView.delegate = self
        
        /* Set rootView imageView image */
        rootView.imageView.image = image
    }
    

    class Builder {
        
        var image: UIImage?
        
        func setImage(image: UIImage) -> Self {
            self.image = image
            return self
        }
        
        func build() -> IntroViewController {
            let ivc = IntroViewController()
            ivc.image = image
            
            return ivc
        }
        
    }

}
