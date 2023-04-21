//
//  IntroPresentationSpecification.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import Foundation

class IntroPresentationSpecification: StackedPresentationSpecification {
    
    var stackedViewControllers: [StackedViewController] = [
        IntroViewController.Builder()
            .setImage(image: UIImage(named: Constants.ImageName.introScreenshot1)!)
            .build(),
        IntroViewController.Builder()
            .setImage(image: UIImage(named: Constants.ImageName.introScreenshot2)!)
            .build()
    ]
    
}
