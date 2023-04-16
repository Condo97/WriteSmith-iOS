//
//  UIImage+StackedTemplates.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/21/23.
//

import Foundation

extension UIImage {
    
    static func fromStacked(topImage: UIImage, bottomImage: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bottomImage.size, false, 3.0)
        let rect = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
        bottomImage.draw(in: rect)
        topImage.draw(in: rect)
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()
        
        return outputImage ?? topImage
    }
}
