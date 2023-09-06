//
//  EssayEssayTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/4/23.
//

import CoreData
import Foundation

protocol EssayEssayTableViewCellDelegate {
    func didPressCopyText(cell: EssayEssayTableViewCell)
    func didPressShare(cell: EssayEssayTableViewCell)
    func didPressDeleteRow(cell: EssayEssayTableViewCell)
    
    func didPressCancelEditing(cell: EssayEssayTableViewCell)
    func didPressSaveEditing(cell: EssayEssayTableViewCell)
    
    func didPressShowMore(cell: EssayEssayTableViewCell) // TODO: This is unimplemented I guess? Delete this or use it
    func didPressShowLess(cell: EssayEssayTableViewCell)
    func essayTextDidChange(cell: EssayEssayTableViewCell, textView: UITextView)
    func essayTextDidBeginEditing(cell: EssayEssayTableViewCell, textView: UITextView)
    func essayTextDidEndEditing(cell: EssayEssayTableViewCell, textView: UITextView)
}

class EssayEssayTableViewCell: UITableViewCell, ManagedObjectCell, DelegateCell {
    
    let EDITED_TEXT = "Edited"
    
    @IBOutlet weak var roundedView: RoundedView!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var editedLabel: UILabel!
    @IBOutlet weak var deleteButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var essayTextView: UITextView!
    @IBOutlet weak var essayHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var showLessButton: UIButton!
    @IBOutlet weak var showLessHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMoreGradientView: GradientView!
    @IBOutlet weak var showMoreSolidView: UIView!
    @IBOutlet weak var copiedLabel: UILabel!
    
    var delegate: AnyObject?
    
    let toolbarHeight = 48.0
    
    lazy var toolbar: UIToolbar = {
        // Setup keyboard toolbar
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: toolbarHeight))
        toolbar.barStyle = .default
        toolbar.items = [UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEditingPressed)), UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveEditingPressed))]
        toolbar.tintColor = Colors.elementTextColor
        toolbar.barTintColor = Colors.elementBackgroundColor
        toolbar.sizeToFit()
        
        return toolbar
    }()
    
    lazy var showMoreTapGestureRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(tappedShowMore))
    }()
    
    
    private var essayEssayDelegate: EssayEssayTableViewCellDelegate? {
        delegate as? EssayEssayTableViewCellDelegate
    }
    
    @IBAction func copyText(_ sender: Any) {
        essayEssayDelegate?.didPressCopyText(cell: self)
    }
    
    @IBAction func share(_ sender: Any) {
        essayEssayDelegate?.didPressShare(cell: self)
    }
    
    @IBAction func deleteRow(_ sender: Any) {
        essayEssayDelegate?.didPressDeleteRow(cell: self)
    }
    
    @IBAction func showLess(_ sender: Any) {
        essayEssayDelegate?.didPressShowLess(cell: self)
        
        setEssayTextViewInteractibility()
    }
    
    
    func configure(managedObject: NSManagedObject) {
        if let essay = managedObject as? Essay {
            // Setup dateFormatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            title.text = essay.prompt
            date.text = essay.date != nil ? dateFormatter.string(from: essay.date!) : nil
            editedLabel.text = essay.userEdited ? EDITED_TEXT : nil
            
            deleteButtonWidthConstraint.constant = PremiumHelper.get() ? deleteButtonWidthConstraint.constant : 0.0
            
            essayTextView.text = essay.essay
            essayTextView.inputAccessoryView = toolbar
            
            essayTextView.delegate = self
            
            roundedView.addGestureRecognizer(showMoreTapGestureRecognizer)
            
            setEssayTextViewInteractibility()
            
            setNeedsDisplay()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    @objc func cancelEditingPressed() {
        essayEssayDelegate?.didPressCancelEditing(cell: self)
    }
    
    @objc func saveEditingPressed() {
        essayEssayDelegate?.didPressSaveEditing(cell: self)
    }
    
    @objc func tappedShowMore() {
        essayEssayDelegate?.didPressShowMore(cell: self)
        
        setEssayTextViewInteractibility()
    }
    
    private func setEssayTextViewInteractibility() {
        // TODO: Is this an okay way to do this? Fix it if not lol
        if essayHeightConstraint.priority == .defaultLow {
            // Enable user interaction if essayTextView is showing
            essayTextView.isUserInteractionEnabled = true
        } else {
            // Disable user interaction if essayTextView is not showing
            essayTextView.isUserInteractionEnabled = false
        }
    }
    
}

extension EssayEssayTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        essayEssayDelegate?.essayTextDidChange(cell: self, textView: textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        essayEssayDelegate?.essayTextDidBeginEditing(cell: self, textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        essayEssayDelegate?.essayTextDidEndEditing(cell: self, textView: textView)
    }
    
}
