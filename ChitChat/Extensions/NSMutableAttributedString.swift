//
//  NSMutableAttributedString.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/11/23.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    var fontSize: CGFloat { return 17 }
    var boldFont: UIFont { return UIFont(name: "Avenir-Bold", size: defaultBoldSize) ?? UIFont.boldSystemFont(ofSize: defaultBoldSize) }
    var normalFont: UIFont { return UIFont(name: "Avenir-Book", size: defaultNormalSize) ?? UIFont.systemFont(ofSize: defaultNormalSize) }
    var secondaryFont: UIFont { return UIFont(name: "Avenir-Bold", size: defaultSecondarySize) ?? UIFont.systemFont(ofSize: defaultSecondarySize) }
    var normalAndBigFont: UIFont { return UIFont(name: "Avenir-Book", size: normalAndBigSize) ?? UIFont.systemFont(ofSize: normalAndBigSize) }
    var boldAndBigFont: UIFont { return UIFont(name: "Avenir-Bold", size: boldAndBigSize) ?? UIFont.boldSystemFont(ofSize: boldAndBigSize) }
    var secondarySmallerFont: UIFont { return UIFont(name: "Avenir-Bold", size: secondarySmallerSize) ?? UIFont.systemFont(ofSize: secondarySmallerSize) }
    
    var defaultBoldSize: CGFloat { return fontSize }
    var defaultNormalSize: CGFloat {return fontSize }
    var defaultSecondarySize: CGFloat { return 14.0 }
    var normalAndBigSize: CGFloat { return 24.0 }
    var boldAndBigSize: CGFloat { return 24.0 }
    var secondarySmallerSize: CGFloat { return 12.0 }
    
    func bold(_ value: String, size: CGFloat) {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: boldFont.withSize(size)
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
    }
    
    func bold(_ value: String) {
        bold(value, size: defaultBoldSize)
    }
    
    func normal(_ value: String, size: CGFloat) {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: normalFont.withSize(size)
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
    }
    
    
    func normal(_ value: String) {
        normal(value, size: defaultNormalSize)
    }
    
    func secondary(_ value: String, size: CGFloat) {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: secondaryFont.withSize(size),
            .foregroundColor: UIColor.gray
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
    }
    
    func secondary(_ value: String) {
        secondary(value, size: defaultSecondarySize)
    }
    
    func normalAndBig(_ value: String, size: CGFloat) {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: normalAndBigFont.withSize(size),
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
    }
    
    func normalAndBig(_ value: String) {
        normalAndBig(value, size: normalAndBigSize)
    }
    
    func boldAndBig(_ value: String, size: CGFloat) {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: boldAndBigFont.withSize(size)
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
    }
    
    func boldAndBig(_ value: String) {
        boldAndBig(value, size: boldAndBigSize)
    }
    
    func secondarySmaller(_ value: String, size: CGFloat) {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: secondarySmallerFont.withSize(size),
            .foregroundColor: UIColor.gray
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
    }
    
    func secondarySmaller(_ value: String) {
        secondary(value, size: defaultSecondarySize)
    }
    
    /* Other styling methods */
    func orangeHighlight(_ value:String) {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font:  normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.orange
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
    }
    
    func blackHighlight(_ value:String) {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.black
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
    }
    
    func underlined(_ value:String) {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
    }
}
