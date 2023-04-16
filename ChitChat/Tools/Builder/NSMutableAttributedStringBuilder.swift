//
//  NSMutableAttributedStringBuilder.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/11/23.
//

import Foundation
import UIKit

class NSMutableAttributedStringBuilder: Any  {
    private var fontSize: CGFloat { return 17 }
    private var boldFont: UIFont { return UIFont(name: "Avenir-Heavy", size: defaultBoldSize)! }
    private var blackFont: UIFont { return UIFont(name: "Avenir-Black", size: defaultBoldSize)! }
    private var normalFont: UIFont { return UIFont(name: "Avenir-Book", size: defaultNormalSize)! }
    private var secondaryFont: UIFont { return UIFont(name: "Avenir-Heavy", size: defaultSecondarySize)! }
    private var normalAndBigFont: UIFont { return UIFont(name: "Avenir-Book", size: normalAndBigSize)! }
    private var boldAndBigFont: UIFont { return UIFont(name: "Avenir-Heavy", size: boldAndBigSize)! }
    private var secondarySmallerFont: UIFont { return UIFont(name: "Avenir-Heavy", size: secondarySmallerSize)! }
    
    private var defaultBoldSize: CGFloat { return fontSize }
    private var defaultNormalSize: CGFloat {return fontSize }
    private var defaultSecondarySize: CGFloat { return 14.0 }
    private var normalAndBigSize: CGFloat { return 24.0 }
    private var boldAndBigSize: CGFloat { return 24.0 }
    private var secondarySmallerSize: CGFloat { return 12.0 }
    
    private var attributedString: NSMutableAttributedString
    
    init() {
        attributedString = NSMutableAttributedString()
    }
    
    init(_ text: AttributedString) {
        attributedString = NSMutableAttributedString(text)
    }
    
    @discardableResult //Use this? I think it's a good idea.
    func bold(_ value: String, size: CGFloat) -> NSMutableAttributedStringBuilder {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: boldFont.withSize(size)
        ]
        
        attributedString.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    @discardableResult
    func bold(_ value: String) -> NSMutableAttributedStringBuilder {
        return bold(value, size: defaultBoldSize)
    }
    
    @discardableResult
    func normal(_ value: String, size: CGFloat) -> NSMutableAttributedStringBuilder {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: normalFont.withSize(size)
        ]
        
        attributedString.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    @discardableResult
    func normal(_ value: String) -> NSMutableAttributedStringBuilder {
        return normal(value, size: defaultNormalSize)
    }
    
    @discardableResult
    func secondary(_ value: String, size: CGFloat) -> NSMutableAttributedStringBuilder {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: secondaryFont.withSize(size),
            .foregroundColor: UIColor.gray
        ]
        
        attributedString.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    @discardableResult
    func secondary(_ value: String) -> NSMutableAttributedStringBuilder {
        return secondary(value, size: defaultSecondarySize)
    }
    
    @discardableResult
    func normalAndBig(_ value: String, size: CGFloat) -> NSMutableAttributedStringBuilder {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: normalAndBigFont.withSize(size),
        ]
        
        attributedString.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    @discardableResult
    func normalAndBig(_ value: String) -> NSMutableAttributedStringBuilder {
        return normalAndBig(value, size: normalAndBigSize)
    }
    
    @discardableResult
    func boldAndBig(_ value: String, size: CGFloat) -> NSMutableAttributedStringBuilder {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: boldAndBigFont.withSize(size)
        ]
        
        attributedString.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    @discardableResult
    func boldAndBig(_ value: String) -> NSMutableAttributedStringBuilder {
        return boldAndBig(value, size: boldAndBigSize)
    }
    
    @discardableResult
    func secondarySmaller(_ value: String, size: CGFloat) -> NSMutableAttributedStringBuilder {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font: secondarySmallerFont.withSize(size),
        ]
        
        attributedString.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    @discardableResult
    func secondarySmaller(_ value: String) -> NSMutableAttributedStringBuilder {
        return secondarySmaller(value, size: defaultSecondarySize)
    }
    
    /* Other styling methods */
    @discardableResult
    func orangeHighlight(_ value:String) -> NSMutableAttributedStringBuilder {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font:  normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.orange
        ]
        
        attributedString.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    @discardableResult
    func blackHighlight(_ value:String) -> NSMutableAttributedStringBuilder {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.black
            
        ]
        
        attributedString.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    @discardableResult
    func underlined(_ value:String) -> NSMutableAttributedStringBuilder {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
            
        ]
        
        attributedString.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    @discardableResult
    func addGlobalAttribute(_ name: NSAttributedString.Key, value: Any) -> NSMutableAttributedStringBuilder {
        attributedString.addAttribute(name, value: value, range: NSRange(0..<attributedString.length))
        return self
    }
    
    func get() -> NSMutableAttributedString {
        return attributedString
    }
}
