//
//  String+ToImage.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation
import UIKit

extension String {
    
    func toImage(fontName: String) -> UIImage? {
        return toImage(fontName: fontName, fontSize: 1024)
    }
    
    func toImage(fontName: String, fontSize: CGFloat) -> UIImage? {
        let nsString = self as NSString
        let font = UIFont(name: fontName, size: fontSize)
        let stringAttributes = [NSAttributedString.Key.font: font!]
        let imageSize = nsString.size(withAttributes: stringAttributes)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: imageSize)
        UIRectFill(rect)
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont(name: fontName, size: fontSize)!])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
