//
//  EssayViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/21/23.
//

import CoreData
import UIKit

class EssayViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewThatTableViewIsAlignedTo: UIView!
    
    enum SaveEdit {
        case none
        case save
        case cancel
    }
    
    var toolbar: UIToolbar!
    var shouldSaveEdit: SaveEdit = .none
    
    var logoMenuBarItem = UIBarButtonItem()
    var moreMenuBarItem = UIBarButtonItem()
    var shareMenuBarItem = UIBarButtonItem()
    var proMenuBarItem = UIBarButtonItem()
    var navigationSpacer = UIBarButtonItem()
    
    var essays: [NSManagedObject] = []
    var origin: CGFloat = 0.0
    let toolbarHeight = 48.0
    
    let inputPlaceholder = "Enter a prompt..."
    var freeInputPlaceholder = "Enter a prompt to try..."
    
    var isProcessingChat = false
    var firstChat = false
    var wasPremium = false
    var buttonsShouldEnable = true
    var tempPrompt = ""
    
    //    var remaining = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        CDHelper.getAllEssays(essayArray: &essays)
        
        // Setup Keyboard Stuff
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Dismiss Keyboard Gesture Recognizer
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        dismissKeyboardGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
        
        // Setup Keyboard Toolbar
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: toolbarHeight))
        toolbar.barStyle = .default
        toolbar.items = [UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEditingPressed)), UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveEditingPressed))]
        toolbar.tintColor = Colors.aiChatBubbleColor
        toolbar.barTintColor = Colors.aiChatTextColor
        toolbar.sizeToFit()
        
        //TODO: - Delete button
        //TODO: - Edit text
        //TODO: - Edited in italics
        
        loadMenuBarItems()
        setLeftMenuBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Did the user recently upgrade or downgrade?
        // Should see if this can be moved to viewWillAppear
        if !wasPremium && UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            switchToPremium()
        } else if wasPremium && !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            switchToStandard()
        }
        
        doServerPremiumCheck()
        
        setPremiumItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        origin = self.view.frame.origin.y
        
        wasPremium = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium)
    }
    
    func enableButtons() {
        // Enable submit button
        buttonsShouldEnable = true
        
        // If cell is loaded, do it now!
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EssayEntryTableViewCell {
            cell.submitButton.isEnabled = true
            cell.textView.isEditable = true
        }
    }
    
    func disableButtons() {
        // Disable submit button
        buttonsShouldEnable = false
        
        // If cell is loaded, do it now!
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EssayEntryTableViewCell {
            cell.submitButton.isEnabled = false
            cell.textView.isEditable = false
        }
    }
    
    func goToUltraPurchase() {
        performSegue(withIdentifier: "toUltraPurchase", sender: nil)
    }
    
    func addEssay(prompt: String, essay: String, userSent: ChatSender) {
        // Save Essay
        CDHelper.appendEssay(prompt: prompt, essay: essay, date: Date(), userEdited: false, essayArray: &essays, success: {
            // Insert new section
            DispatchQueue.main.async {
                if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                    // Insert section below premium section but at top if not premium
                    self.tableView.insertSections(IndexSet(integer: 2), with: .top)
                } else {
                    // Insert section at top if premium
                    self.tableView.insertSections(IndexSet(integer: 1 /* the first section */), with: .top)
                }
                
            }
        })
    }
    
    func loadMenuBarItems() {
        /* Setup Navigation Bar Appearance (mmake it solid) */
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.topBarBackgroundColor
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        /* Setup Logo Menu Bar Item */
        let logoImage = UIImage(named: "logoImage")
        let logoImageButton = UIButton(type: .custom)
        
        logoImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 30)
        logoImageButton.setBackgroundImage(logoImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        //logoImageButton.addTarget(self, action: #selector(doSomethingFunny), for: .touchUpInside) //Can add this for an extra way to advertise or something? Maybe shares?
        logoImageButton.tintColor = Colors.userChatTextColor
        
        logoMenuBarItem = UIBarButtonItem(customView: logoImageButton)
        
        /* Setup Menu Menu Bar Item */
        let moreImage = UIImage(systemName: "line.3.horizontal")
        let moreImageButton = UIButton(type: .custom)
        
        moreImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        moreImageButton.setBackgroundImage(moreImage, for: .normal)
        moreImageButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        moreImageButton.tintColor = Colors.userChatTextColor
        
        moreMenuBarItem = UIBarButtonItem(customView: moreImageButton)
        
        /* Setup Share Menu Bar Item */
        let shareImage = UIImage(named: "shareImage")?.withTintColor(Colors.userChatTextColor)
        let shareImageButton = UIButton(type: .custom)
        
        shareImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        shareImageButton.setBackgroundImage(shareImage, for: .normal)
        shareImageButton.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        shareImageButton.tintColor = Colors.userChatTextColor
        
        shareMenuBarItem = UIBarButtonItem(customView: shareImageButton)
        
        /* Setup Pro Menu Bar Item */
        //TODO: - New Pro Image
        let proImage = UIImage.gifImageWithName("giftGif")
        let proImageButton = RoundedButton(type: .custom)
        proImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        proImageButton.tintColor = Colors.userChatTextColor
        proImageButton.setImage(proImage, for: .normal)
        proImageButton.addTarget(self, action: #selector(ultraPressed), for: .touchUpInside)
        
        proMenuBarItem = UIBarButtonItem(customView: proImageButton)
        
        /* Setup Navigation Spacer */
        navigationSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationSpacer.width = 14
        
        /* Setup More */
        moreMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
        moreMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        /* Setup Share */
        shareMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
        shareMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        /* Setup Constraints */
        logoMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 86).isActive = true
        logoMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        proMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 34).isActive = true
        proMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 140, height: 80))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "logoImage")
        imageView.image = image
        imageView.tintColor = Colors.elementTextColor
        navigationItem.titleView = imageView
    }
    
    func setLeftMenuBarItems() {
        /* Put things in Left NavigationBar. Phew! */
        navigationItem.leftBarButtonItems = [moreMenuBarItem, shareMenuBarItem, navigationSpacer]
        
    }
    
    func setPremiumItems() {
        /* Update the text that says how many chats are remaining for user */
//        updateRemainingText()
        
        /* Setup Right Bar Button Items and Top Ad View */
        var rightBarButtonItems:[UIBarButtonItem] = []
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            rightBarButtonItems.append(proMenuBarItem)
        } else {
//            adViewHeightConstraint.constant = 0.0
//            adShadowView.isHidden = true
        }
        
        /* Put things in Right NavigationBar */
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        /* Update the tabView with correct image and button */
        // Fix this and make it better lol
        let tabBarItemIndex = (tabBarController?.tabBar.items?.count ?? 0) - 1
        
        if tabBarItemIndex < 0 {
            print("Tab bar index is less than zero...")
            return
        }
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            tabBarController?.tabBar.items![tabBarItemIndex].image = UIImage(named: Constants.premiumBottomButtonNotSelectedImageName)
        } else {
            tabBarController?.tabBar.items![tabBarItemIndex].image = UIImage(named: Constants.shareBottomButtonNotSelectedImageName)
        }
    }
    
    func updateTextViewSubmitButtonEnabled(textView: UITextView) {
        if textView.text == "" || textView.textColor == .lightText || (textView.text == inputPlaceholder || textView.text == freeInputPlaceholder) {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EssayEntryTableViewCell
            cell.submitButton.isEnabled = false
        } else {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EssayEntryTableViewCell
            cell.submitButton.isEnabled = true
        }
    }
    
    @objc func showLessPressed() {
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableViewBottomConstraint.constant = keyboardSize.height - (tabBarController?.tabBar.frame.height ?? 0) - bottomViewThatTableViewIsAlignedTo.frame.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tableViewBottomConstraint.constant = 0
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func openMenu() {
        performSegue(withIdentifier: "toSettingsView", sender: nil)
    }
    
    @objc func shareApp() {
        let activityVC = UIActivityViewController(activityItems: [UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) ?? ""], applicationActivities: [])
        
        present(activityVC, animated: true)
    }
    
    @objc func ultraPressed() {
        goToUltraPurchase()
    }
    
    @objc func cancelEditingPressed() {
        //TODO: - Cancel editing
        shouldSaveEdit = .cancel
        dismissKeyboard()
    }
    
    @objc func saveEditingPressed(sender: Any) {
        //TODO: - Save editing
        shouldSaveEdit = .save
        dismissKeyboard()
    }
}

extension EssayViewController: UITableViewDelegate, UITableViewDataSource {
    
    /**
     * Structure
     * Section 0
     * - Entry
     * Section n
     * - Prompt
     * - Essay
     *
     */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var value = essays.count + 1
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            value += 1
        }
        
        if isProcessingChat {
            value += 1
        }
        
        return value
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // If the user is not premium, then it needs to make sure the section is 1 when not processing chat and 2 when processing chat
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) && ((section == 1 && !isProcessingChat) || (section == 2 && isProcessingChat)) {
            return 1
        }
        
        if section == 0 {
            return 1
        }
        
        if section == 1 && isProcessingChat {
            return 1
        }
        
        //TODO: - Add a little blurb explaining how to use this view if there are no essays stored
        
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Show loading chat row
        if isProcessingChat && indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath) as! EssayLoadingTableViewCell
            cell.loadingImageView.image = UIImage.gifImageWithName("loadingDots")
            return cell
        }
        
        // Show premium row and disabled header row
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
//            if indexPath.section == 0 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "entry", for: indexPath) as! EssayEntryTableViewCell
//                
//                // Setup "placeholder" for TextView
//                cell.textView.text = inputPlaceholder
//                cell.textView.textColor = .lightGray
//                cell.submitButton.isEnabled = false
//                cell.textView.isEditable = false
//                
//                return cell
//            } else
            
            // Show the essayPremiumTableViewCell, moving it down a section if isProcessingChat
            if (!isProcessingChat && indexPath.section == 1) || (isProcessingChat && indexPath.section == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "premium", for: indexPath) as! EssayPremiumTableViewCell
                
                cell.delegate = self
                
                return cell
            }
        }
        
        // First section has only one row, which is the entry row
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "entry", for: indexPath) as! EssayEntryTableViewCell
            
            cell.delegate = self
            
            // Setup "placeholder" for TextView
            cell.textView.text = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? inputPlaceholder : freeInputPlaceholder
            cell.textView.textColor = .lightText
            cell.textView.delegate = self
            cell.submitButton.isEnabled = false
            cell.textView.isEditable = buttonsShouldEnable
            
            return cell
        }
        
        // Every section after first conforms to the same structure
        if indexPath.row == 0 {
            // Prompt row
            let cell = tableView.dequeueReusableCell(withIdentifier: "prompt", for: indexPath) as! EssayPromptTableViewCell
            guard let prompt = essays[tableView.numberOfSections - indexPath.section - 1].value(forKey: Constants.coreDataEssayPromptObjectName) as? String else {
                print("Error getting the prompt object for cell...")
                return UITableViewCell()
            }
            
            guard let date = essays[tableView.numberOfSections - indexPath.section - 1].value(forKey: Constants.coreDataEssayDateObjectName) as? Date else {
                print("Error getting the essay object for cell...")
                return UITableViewCell()
            }
            
            guard let userEdited = essays[tableView.numberOfSections - indexPath.section - 1].value(forKey: Constants.coreDataEssayUserEditedObjectName) as? Bool else {
                    print("Error getting the userEdited object for cell...")
                return UITableViewCell()
            }
            
            // Hide delete button if not premium, show if premium
            if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                cell.deleteButtonWidthConstraint.constant = 0
            } else {
                cell.deleteButtonWidthConstraint.constant = cell.shareButtonWidthConstraint.constant
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            cell.delegate = self
            cell.title.text = prompt
            cell.date.text = dateFormatter.string(from: date)
            
            // Update halfRoundedView layout
            cell.halfRoundedView.setNeedsDisplay()
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            if userEdited {
                cell.editedLabel.alpha = 1.0
            } else {
                cell.editedLabel.alpha = 0.0
            }
            
            return cell
        } else if indexPath.row == 1 {
            // Essay
            let cell = tableView.dequeueReusableCell(withIdentifier: "essay", for: indexPath) as! EssayEssayTableViewCell
            guard let essay = essays[tableView.numberOfSections - indexPath.section - 1].value(forKey: Constants.coreDataEssayEssayObjectName) as? String else {
                return cell
            }
            
            cell.delegate = self
            cell.essayTextView.text = essay
            cell.essayTextView.inputAccessoryView = toolbar
            
            // Update halfRoundedView layout
            cell.halfRoundedView.setNeedsDisplay()
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 0 { return }
        if isProcessingChat && indexPath.section == 1 { return }
        
        // Check if the "show more" was tapped
        if indexPath.row == 1 {
            guard let cell = tableView.cellForRow(at: indexPath) as? EssayEssayTableViewCell else {
                print("Not an EssayEssayTableViewCell tapped...")
                return
            }
            
            if cell.essayHeightConstraint.priority >= .defaultHigh {
                // Expand Essay to Show More
                
                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    cell.essayHeightConstraint.priority = .defaultLow
                    cell.halfRoundedView.setNeedsDisplay()
                    cell.showLessHeightConstraint.constant = 20
                    cell.showMoreGradientView.alpha = 0
                    cell.showMoreSolidView.alpha = 0
                    cell.showMoreLabel.text = ""
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                    tableView.endUpdates()
                }
                
                // Make Essay editable
                cell.essayTextView.isEditable = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 40
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == tableView.numberOfSections - 1 {
            return UIView()
        }
        
        return nil
    }
}

extension EssayViewController: EssayPromptTableViewCellDelegate {
    func didPressCopyText(cell: EssayPromptTableViewCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            print("Could not find section of cell to copy...")
            return
        }
        
        // There will be an extra section if user is not premium
        var premiumPurchaseSectionShowing = 0
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            premiumPurchaseSectionShowing = 1
        }
        
        // Just to note, this would be essays.count - section - 1 + 1, -1 for the .count and +1 for the entry section
        if essays.count - section + premiumPurchaseSectionShowing < 0 {
            print("Could not find essay to copy because it is out of range...")
            return
        }
        
        let currentEssay = essays[essays.count - section + premiumPurchaseSectionShowing]
        guard let essayText = currentEssay.value(forKey: Constants.coreDataEssayEssayObjectName) as? String else {
            print("Could not cast the essay as String when trying to copy...")
            return
        }
        
        guard let essayCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as? EssayEssayTableViewCell else {
            print("Could not locate the essay cell when trying to copy...")
            return
        }
        
        // Copy to Pasteboard
        var text = essayText
        
        //TODO: - Make the footer text an option in settings instead of disabling it for premium entirely
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            if let shareURL = UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) {
                text = "\(text)\n\n\(Constants.copyFooterText)\n\(shareURL)"
            } else {
                text = "\(text)\n\n\(Constants.copyFooterText)"
            }
        }
        
        UIPasteboard.general.string = text
        
        // Animate Copy
        UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
            essayCell.copiedLabel.alpha = 1.0
            
            UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                essayCell.copiedLabel.alpha = 0.0
            })
        })
    }
    
    func didPressShare(cell: EssayPromptTableViewCell) {
        // Share row with appended footer text
        guard let section = tableView.indexPath(for: cell)?.section else {
            print("Could not find section of cell to share...")
            return
        }
        
        // There will be an extra section if user is not premium
        var premiumPurchaseSectionShowing = 0
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            premiumPurchaseSectionShowing = 1
        }
        
        // Just to note, this would be essays.count - section - 1 + 1, -1 for the .count and +1 for the entry section
        if essays.count - section + premiumPurchaseSectionShowing < 0 {
            print("Could not find essay to share because it is out of range...")
            return
        }
        
        let currentEssay = essays[essays.count - section + premiumPurchaseSectionShowing]
        guard let promptText = currentEssay.value(forKey: Constants.coreDataEssayPromptObjectName) as? String else {
            print("Could not cast the prompt as String when trying to share...")
            return
        }
        
        guard let essayText = currentEssay.value(forKey: Constants.coreDataEssayEssayObjectName) as? String else {
            print("Could not cast the essay as String when trying to share...")
            return
        }
        
        let text = "Prompt: \(promptText)\n\n\(essayText)\n\n\(Constants.copyFooterText)"
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: [])
        
        present(activityVC, animated: true)
    }
    
    func didPressDeleteRow(cell: EssayPromptTableViewCell) {
        //TODO: - Delete row
        let ac = UIAlertController(title: "Delete", message: "Are you sure you'd like to delete this Essay?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { UIAlertAction in
            guard let section = self.tableView.indexPath(for: cell)?.section else {
                print("Could not find section of cell to delete...")
                return
            }
            // Just to note, this would be essays.count - section - 1 + 1, -1 for the .count and +1 for the entry section
            if self.essays.count - section < 0 {
                print("Could not find essay to delete because it is out of range...")
                return
            }
            // Actually delete the row and CD object
            let currentEssay = self.essays[self.essays.count - section]
            guard let id = currentEssay.value(forKey: Constants.coreDataEssayIDObjectName) as? Int else {
                print("Could not cast the ID as Int when trying to delete...")
                return
            }
            
            CDHelper.deleteEssay(id: id, essayArray: &self.essays, success: {
                DispatchQueue.main.async {
                    self.tableView.deleteSections(IndexSet(integer: section /* not -1 bc of entry section */), with: .middle)
                }
            })
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

extension EssayViewController: EntryEssayTableViewCellDelegate {
    func didPressSubmitButton(sender: Any) {
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            if essays.count >= UserDefaults.standard.integer(forKey: Constants.userDefaultStoredFreeEssayCap) {
                let ac = UIAlertController(title: "Upgrade", message: "You've reached the limit for free essays. Please upgrade to get unlimited full-length essays.\n\n(3-Day Free Trial)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                    self.goToUltraPurchase()
                }))
                ac.addAction(UIAlertAction(title: "Close", style: .cancel))
                present(ac, animated: true)
                return
            }
        }
        
        //TODO: - Ask the server and save
        guard let authToken = UserDefaults.standard.string(forKey: Constants.authTokenKey) else {
            HTTPSHelper.registerUser(delegate: self)
            return
        }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EssayEntryTableViewCell else {
            print("Entry cell not visible! Not generating chat...")
            return
        }
        
        guard let inputText = cell.textView.text else {
            return
        }
        
        if cell.textView.text == nil {
            tempPrompt = "Error getting prompt..."
        } else {
            tempPrompt = cell.textView.text
        }
        
        disableButtons()
        
        // Update entry to placeholder text and update size
        cell.textView.text = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? inputPlaceholder : freeInputPlaceholder
        cell.textView.textColor = .lightText
        updateInputTextViewSize(textView: cell.textView)
        
        if !isProcessingChat {
            isProcessingChat = true
            tableView.beginUpdates()
            tableView.insertSections(IndexSet(integer: 1), with: .none)
            tableView.endUpdates()
        }
        
        HTTPSHelper.getChat(delegate: self, authToken: authToken, inputText: inputText)
    }
}

extension EssayViewController: EssayEssayTableViewCellDelegate {
    func didPressShowLess(cell: EssayEssayTableViewCell) {
        // Show less
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            cell.essayHeightConstraint.priority = .defaultHigh
            cell.halfRoundedView.setNeedsDisplay()
            cell.showLessHeightConstraint.constant = 0
            cell.showMoreGradientView.alpha = 1
            cell.showMoreSolidView.alpha = 1
            cell.showMoreLabel.text = "Show More..."
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            tableView.endUpdates()
        }
        
        // Make textview not editable
        cell.essayTextView.isEditable = false
    }
    
    func essayTextDidChange(cell: EssayEssayTableViewCell, textView: UITextView) {
    }
    
    func essayTextDidBeginEditing(cell: EssayEssayTableViewCell, textView: UITextView) {
    }
    
    func essayTextDidEndEditing(cell: EssayEssayTableViewCell, textView: UITextView) {
        //Need to reset text view if "cancel" pressed, or present a view saying "do you want to save changes?" if editing ended any other way
        
        
        // Actually all this should just be called on the "Save" button click
        guard let section = tableView.indexPath(for: cell)?.section else {
            print("Could not find section of cell to save edits...")
            return
        }
        
        // There will be an extra section if user is not premium
        var premiumPurchaseSectionShowing = 0
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            premiumPurchaseSectionShowing = 1
        }
        
        // Just to note, this would be essays.count - section - 1 + 1, -1 for the .count and +1 for the entry section
        if essays.count - section + premiumPurchaseSectionShowing < 0 {
            print("Could not find essay to save edits to because it is out of range...")
            return
        }
        
        let currentEssay = essays[essays.count - section + premiumPurchaseSectionShowing]
        guard let id = currentEssay.value(forKey: Constants.coreDataEssayIDObjectName) as? Int else {
            print("Could not cast the ID as Int when trying to save edits...")
            return
        }
        
        guard let essayText = currentEssay.value(forKey: Constants.coreDataEssayEssayObjectName) as? String else {
            print("Could not cast the essay as String when trying to save edits...")
            return
        }
        
        if textView.text == essayText {
            print("No changes to save...")
            return
        }
        
        if shouldSaveEdit == .none {
            // Prompt the user confirming if they'd like to save or not
            let ac = UIAlertController(title: "Unsaved Edits", message: "You edited this essay. Would you like to save your edits?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { UIAlertAction in
                self.shouldSaveEdit = .cancel
                self.essayTextDidEndEditing(cell: cell, textView: textView)
            }))
            ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { UIAlertAction in
                self.shouldSaveEdit = .save
                self.essayTextDidEndEditing(cell: cell, textView: textView)
            }))
            present(ac, animated: true)
            
        } else if shouldSaveEdit == .save {
            CDHelper.updateEssay(id: id, newEssay: textView.text, userEdited: true, essayArray: &essays)
            
            // Show the "- Edited" text of the Prompt cell
            guard let section = tableView.indexPath(for: cell)?.section else {
                print("Couldn't get the section for the edit text update... should update next time user loads this view...")
                shouldSaveEdit = .none
                return
            }
            
            guard let promptCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? EssayPromptTableViewCell else {
                print("Couldn't update edit text here... should update next time user loads this view...")
                shouldSaveEdit = .none
                return
            }
            
            promptCell.editedLabel.alpha = 1.0
            
        } else {
            textView.text = essayText
        }
        
        shouldSaveEdit = .none
    }
}

extension EssayViewController: EssayPremiumTableViewCellDelegate {
    func didPressPremiumButton(sender: Any, cell: EssayPremiumTableViewCell) {
        goToUltraPurchase()
    }
}

extension EssayViewController: IAPHTTPSHelperDelegate {
    func doServerPremiumCheck() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)
                
                let receiptString = receiptData.base64EncodedString(options: [])
                print(receiptString)
                
                guard let authToken = UserDefaults.standard.string(forKey: Constants.authTokenKey) else {
                    print("Didn't have authToken...")
                    setPremiumToFalse()
                    return
                }
                
                IAPHTTPSHelper.validateAndSaveReceipt(authToken: authToken, receiptData: receiptData, delegate: self)
            } catch {
                
            }
        } else {
            /* No receipt, so set isPremium to false */
            setPremiumToFalse()
        }
    }
    
    func switchToPremium() {
        // Remove 2 sections, add entry and any stored essays
        let premiumCount = essays.count
        let freeCount = essays.count + 1
        tableView.beginUpdates()
        tableView.deleteSections(IndexSet(integersIn: 0...freeCount), with: .none)
        tableView.insertSections(IndexSet(integersIn: 0...premiumCount), with: .none)
        tableView.endUpdates()
    }
    
    func switchToStandard() {
        // Remove entry and all stored essay sections, add 2 sections
        let premiumCount = essays.count
        let freeCount = essays.count + 1
        tableView.beginUpdates()
        tableView.deleteSections(IndexSet(integersIn: 0...premiumCount), with: .none)
        tableView.insertSections(IndexSet(integersIn: 0...freeCount), with: .none)
        tableView.endUpdates()
    }
    
    func setPremiumToFalse() {
        UserDefaults.standard.set(false, forKey: Constants.userDefaultStoredIsPremium)
        
        setPremiumItems()
    }
    
    func setPremiumToTrue() {
        UserDefaults.standard.set(true, forKey: Constants.userDefaultStoredIsPremium)
        
        setPremiumItems()
    }
    
    //MARK: - IAPHTTPSHelper Delegate Function
    /* Did Validate Save Update Receipt
     * IAPHTTPSHelperDelegate Function
     - Called when Receipt is saved or not
     - Returns if user is premium or not
     */
    func didValidateSaveUpdateReceipt(json: [String : Any]) {
        /**
         ValidateAndUpdateReceipt Response JSON
         
         {
         "Success": Int
         "Body?":  {
         "isPremium": Bool
         }
         (Error)         "Type?": Int
         (Error) "       Message?" String
         }
         */
        if let success = json["Success"] as? Int {
            if success == 1 {
                if let body = json["Body"] as? [String: Any] {
                    if let isPremium = body["isPremium"] as? Bool {
                        if isPremium {
                            /* Server has validated user is Premium */
                            UserDefaults.standard.set(true, forKey: Constants.userDefaultStoredIsPremium)
                        } else {
                            /* Server has validated user is Free */
                            UserDefaults.standard.set(false, forKey: Constants.userDefaultStoredIsPremium)
                        }
                        
                        setPremiumItems()
                    }
                }
            }
        }
    }
    
    func didGetIAPStuffFromServer(json: [String : Any]) {
    }
}

extension EssayViewController: HTTPSHelperDelegate {
    func didRegisterUser(json: [String : Any]?) {
        // Register user if they don't have an authToken stored
        guard let body = json?["Body"] as? [String: Any] else {
            print("Error! No Body in response...\n\(String(describing: json))")
            return
        }
        
        guard let authToken = body["authToken"] as? String else {
            print("Error! No AuthToken in response...\n\(String(describing: json))")
            return
        }
        
        HTTPSHelper.getRemaining(delegate: self, authToken: authToken)
        UserDefaults.standard.set(authToken, forKey: Constants.authTokenKey)
    }
    
    func getRemaining(json: [String : Any]?) {
        //TODO: - Handle remaining chats, maybe need to do something new for essay view, or just make it fully premium? Maybe fully premium to start?
    }
    
    func didGetAndSaveImportantConstants(json: [String : Any]?) {
        
    }
    
    func getChat(json: [String : Any]?) {
        enableButtons()
        
        if isProcessingChat {
            isProcessingChat = false
            tableView.deleteSections(IndexSet(integer: 1), with: .none)
        }
        
        guard let success = json?["Success"] as? Int else {
            print("Error! No success in response...\n\(String(describing: json))")
            return
        }
        
        if success == 1 {
            //Everything's good!
            guard let body = json?["Body"] as? [String: Any] else {
                print("Error! No Body in response...\n\(String(describing: json))")
                return
            }
            
            guard let output = body["output"] as? String else {
                print("Error! No Output in response...\n\(String(describing: json))")
                return
            }
            
            guard let finishReason = body["finishReason"] as? String else {
                print("Error! No Finish Reason in response...\n\(String(describing: json))")
                return
            }
            
            print(finishReason)
            // Trim first two lines off of output
            var trimmedOutput = output
            if output.contains("\n\n") {
                let firstOccurence = output.range(of: "\n\n")!
                trimmedOutput.removeSubrange(output.startIndex..<firstOccurence.upperBound)
            }
            
            if finishReason == FinishReasons.length && !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                trimmedOutput += "...\n\nThis answer is too long for your plan. Please upgrade to Ultra for unlimited length."
            }
            
            //TODO: - Add remaining stuff
//            self.remaining = remaining
//            updateRemainingText()
            firstChat = false
            
            addEssay(prompt: tempPrompt, essay: trimmedOutput, userSent: .ai)
            tempPrompt = ""
        } else if success == 51 {
            //Too many chats generated
            
            let ac = UIAlertController(title: "Limit Reached", message: "You've reached your daily chat limit. Upgrade for unlimited chats...", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Close", style: .cancel))
            ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                self.goToUltraPurchase()
            }))
            present(ac, animated: true)
            
//            addEssay(message: output, userSent: .ai)
        } else {
            print("Error! Unhandled error number...\n\(String(describing: json))")
        }
    }
    
    func getChatError() {
        //TODO: - Handle chat errors
        DispatchQueue.main.async {
            if self.isProcessingChat {
                self.isProcessingChat = false
                self.tableView.deleteRows(at: [IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)], with: .none)
            }
        }
    }
}

extension EssayViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // Is it the input text field?
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            updateInputTextViewSize(textView: textView)
            updateTextViewSubmitButtonEnabled(textView: textView)
            
            return
        }
    }
    
    func updateInputTextViewSize(textView: UITextView) {
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            let size = CGSize(width: textView.frame.size.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            
            textView.constraints.forEach{ (constraint) in
                if constraint.firstAttribute == .height {
                    self.tableView.beginUpdates()
                    constraint.constant = estimatedSize.height
                    self.tableView.endUpdates()
                }
            }
            
            guard textView.contentSize.height < 70.0 else { textView.isScrollEnabled = true; return }
            
            textView.isScrollEnabled = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            if text == "\n" {
                view.endEditing(true)
                return false
            }
            
            return true
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            if textView.textColor == .lightText {
                textView.text = ""
                textView.textColor = Colors.userChatTextColor
            }
            
            return
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            if textView.text == "" {
                textView.text = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? inputPlaceholder : freeInputPlaceholder
                textView.textColor = .lightText
            }
            
            return
        }
    }
}

