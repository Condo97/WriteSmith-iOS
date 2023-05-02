//
//  String+ToImage.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/30/23.
//

import Foundation

extension String {
    
    func toImage() -> UIImage? {
        return toImage(fontSize: 1024)
    }
    
    func toImage(fontSize: CGFloat) -> UIImage? {
        let nsString = self as NSString
        let font = UIFont(name: Constants.primaryFontName, size: fontSize)
        let stringAttributes = [NSAttributedString.Key.font: font!]
        let imageSize = nsString.size(withAttributes: stringAttributes)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: imageSize)
        UIRectFill(rect)
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont(name: Constants.primaryFontName, size: fontSize)!])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
