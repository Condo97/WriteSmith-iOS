//
//  EssayViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/21/23.
//

import CoreData
import UIKit

class EssayViewController: HeaderViewController {
    
    enum SaveEdit {
        case none
        case save
        case cancel
    }
    
    let sourcedTableViewManager: SourcedTableViewManagerProtocol = EssaySourcedTableViewManager()
    
    let entrySection: Int = 0
    let essaySection: Int = 1
    
    var toolbar: UIToolbar!
    var shouldSaveEdit: SaveEdit = .none
    
    var logoMenuBarItem = UIBarButtonItem()
    
    var essays: [Essay] = []
    var origin: CGFloat = 0.0
    let toolbarHeight = 48.0
    
    let inputPlaceholder = "Enter a prompt..."
    var freeInputPlaceholder = "Enter a prompt to try..."
    
    var isProcessingChat = false
    var firstChat = false
    var wasPremium = false
    var buttonsShouldEnable = true
    var tempPrompt = ""
    
    var observerID: Int?
    
    lazy var rootView: EssayView = {
        let view = RegistryHelper.instantiateAsView(nibName: Registry.Essay.View.essay, owner: self) as! EssayView
        return view
    }()!
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Keyboard Toolbar
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: toolbarHeight))
        toolbar.barStyle = .default
        toolbar.items = [UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEditingPressed)), UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveEditingPressed))]
        toolbar.tintColor = Colors.elementTextColor
        toolbar.barTintColor = Colors.elementBackgroundColor
        toolbar.sizeToFit()
        
        /* Setup Table View Manager */
        rootView.tableView.manager = sourcedTableViewManager
        
        /* Setup EssayCell Nibs */
        RegistryHelper.register(Registry.Essay.View.Table.Cell.body, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.entry, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.loading, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.premium, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.prompt, to: rootView.tableView)
        
        /* Get All Essays */
        CDHelper.getAllEssays(essayArray: &essays)
        
        /* Setup Sources */
        // Set entry source and delegate
        rootView.tableView.manager!.sources.append([EntryEssayTableViewCellSource(cellDelegate: self, textViewDelegate: self, initialText: PremiumHelper.get() ? inputPlaceholder : freeInputPlaceholder)])
        
        // Set prompt and body
        rootView.tableView.manager!.sources.append(TableViewCellSourceFactory.makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObjectArray: essays, delegate: self, inputAccessoryView: toolbar)!)
        
        // If not premium, append premium source in the essaySection
        if !PremiumHelper.get() {
            rootView.tableView.manager!.sources[essaySection].append(PremiumEssayTableViewCellSource(delegate: self))
        }
        
        
        // Setup Keyboard Stuff
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Dismiss Keyboard Gesture Recognizer
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        dismissKeyboardGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
        
        //TODO: - Delete button
        //TODO: - Edit text
        //TODO: - Edited in italics
        
//        loadMenuBarItems()
//        setLeftMenuBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        origin = self.view.frame.origin.y
        
        wasPremium = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium)
    }
    
    override func updatePremium(isPremium: Bool) {
        super.updatePremium(isPremium: isPremium)
        
        DispatchQueue.main.async {
            // If last cell in essaySection is essayPremiumTableViewCell and is premium, then remove it, and if the last cell in essaySection is not essayPremiumTableViewCell but not nil and user is not premium, then add it
            let lastCell = self.rootView.tableView.cellForRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.essaySection) - 1, section: self.essaySection))
            if lastCell is EssayPremiumTableViewCell && isPremium {
                self.removePremiumCell()
            } else if lastCell != nil && !(lastCell is EssayPremiumTableViewCell) && !isPremium {
                self.insertPremiumCell()
            }
        }
        
    }
    
    func enableButtons() {
        // Enable submit button
        buttonsShouldEnable = true
        
        // If cell is loaded, do it now!
        DispatchQueue.main.async {
            if let cell = self.rootView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EssayEntryTableViewCell {
                cell.submitButton.isEnabled = true
                cell.textView.isEditable = true
            }
        }
    }
    
    func disableButtons() {
        // Disable submit button
        buttonsShouldEnable = false
        
        // If cell is loaded, do it now!
        if let cell = rootView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EssayEntryTableViewCell {
            cell.submitButton.isEnabled = false
            cell.textView.isEditable = false
        }
    }
    
    func setPlaceholderTextViewToBlank(textView: UITextView) {
        if textView.text == inputPlaceholder || textView.text == freeInputPlaceholder {
            textView.text = ""
            textView.textColor = Colors.userChatTextColor
        }
    }
    
    func setBlankTextViewToPlaceholder(textView: UITextView) {
        if textView.text == "" {
            textView.text = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? inputPlaceholder : freeInputPlaceholder
            textView.textColor = .lightText
        }
    }
    
    func goToUltraPurchase() {
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
    func addEssay(prompt: String, essay: String, userSent: ChatSender) {
        // Save Essay
        CDHelper.appendEssay(prompt: prompt, essay: essay, date: Date(), userEdited: false, essayArray: &essays, success: {
            DispatchQueue.main.async {
                // Get source array containing prompt source and body source for the inserted essay
                let sourceArray = TableViewCellSourceFactory.makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObject: self.essays.last!, delegate: self, inputAccessoryView: self.toolbar)!
                
                // Insert prompt and body cells at top
                self.rootView.tableView.beginUpdates()
                self.rootView.tableView.insertManagedRow(bySource: sourceArray[0], at: IndexPath(row: 0, section: self.essaySection), with: .automatic)
                self.rootView.tableView.endUpdates()
                
                self.rootView.tableView.beginUpdates()
                self.rootView.tableView.insertManagedRow(bySource: sourceArray[1], at: IndexPath(row: 1, section: self.essaySection), with: .automatic)
                self.rootView.tableView.endUpdates()
            }
        })
    }
    
    func insertPremiumCell() {
        DispatchQueue.main.async {
            self.rootView.tableView.insertManagedRow(bySource: PremiumEssayTableViewCellSource(delegate: self), at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.essaySection), section: self.essaySection), with: .automatic)
        }
    }
    
    func removePremiumCell() {
        DispatchQueue.main.async {
            let lastCellIndexPath = IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.essaySection) - 1, section: self.essaySection)
            
            if self.rootView.tableView.cellForRow(at: lastCellIndexPath) is EssayPremiumTableViewCell {
                self.rootView.tableView.deleteManagedRow(at: lastCellIndexPath, with: .automatic)
            } else {
                print("The last cell was not EssayPremiumTableViewCell, so it couldn't be deleted!")
            }
        }
    }
    
//    func loadMenuBarItems() {
//        /* Setup Navigation Bar Appearance (mmake it solid) */
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = Colors.topBarBackgroundColor
//        navigationController?.navigationBar.standardAppearance = appearance;
//        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
//
//        /* Setup Logo Menu Bar Item */
//        let logoImage = UIImage(named: "logoImage")
//        let logoImageButton = UIButton(type: .custom)
//
//        logoImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 30)
//        logoImageButton.setBackgroundImage(logoImage?.withRenderingMode(.alwaysTemplate), for: .normal)
//        //logoImageButton.addTarget(self, action: #selector(doSomethingFunny), for: .touchUpInside) //Can add this for an extra way to advertise or something? Maybe shares?
//        logoImageButton.tintColor = Colors.userChatTextColor
//
//        logoMenuBarItem = UIBarButtonItem(customView: logoImageButton)
//
//        /* Setup Menu Menu Bar Item */
//        let moreImage = UIImage(systemName: "line.3.horizontal")
//        let moreImageButton = UIButton(type: .custom)
//
//        moreImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
//        moreImageButton.setBackgroundImage(moreImage, for: .normal)
//        moreImageButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
//        moreImageButton.tintColor = Colors.userChatTextColor
//
//        moreMenuBarItem = UIBarButtonItem(customView: moreImageButton)
//
//        /* Setup Share Menu Bar Item */
//        let shareImage = UIImage(named: "shareImage")?.withTintColor(Colors.userChatTextColor)
//        let shareImageButton = UIButton(type: .custom)
//
//        shareImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
//        shareImageButton.setBackgroundImage(shareImage, for: .normal)
//        shareImageButton.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
//        shareImageButton.tintColor = Colors.userChatTextColor
//
//        shareMenuBarItem = UIBarButtonItem(customView: shareImageButton)
//
//        /* Setup Pro Menu Bar Item */
//        //TODO: - New Pro Image
//        let proImage = UIImage.gifImageWithName(Constants.ImageName.giftGif)
//        let proImageButton = RoundedButton(type: .custom)
//        proImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
//        proImageButton.tintColor = Colors.userChatTextColor
//        proImageButton.setImage(proImage, for: .normal)
//        proImageButton.addTarget(self, action: #selector(ultraPressed), for: .touchUpInside)
//
//        proMenuBarItem = UIBarButtonItem(customView: proImageButton)
//
//        /* Setup Navigation Spacer */
//        navigationSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        navigationSpacer.width = 14
//
//        /* Setup More */
//        moreMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
//        moreMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
//
//        /* Setup Share */
//        shareMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
//        shareMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
//
//        /* Setup Constraints */
//        logoMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 86).isActive = true
//        logoMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
//        proMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 34).isActive = true
//        proMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 34).isActive = true
//
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 140, height: 80))
//        imageView.contentMode = .scaleAspectFit
//
//        let image = UIImage(named: "logoImage")
//        imageView.image = image
//        imageView.tintColor = Colors.elementTextColor
//        navigationItem.titleView = imageView
//    }
//
//    func setLeftMenuBarItems() {
//        /* Put things in Left NavigationBar. Phew! */
//        navigationItem.leftBarButtonItems = [moreMenuBarItem, shareMenuBarItem, navigationSpacer]
//
//    }
    
//    func setPremiumItems() {
//        /* Update the text that says how many chats are remaining for user */
////        updateRemainingText()
//
//        /* Setup Right Bar Button Items and Top Ad View */
//        var rightBarButtonItems:[UIBarButtonItem] = []
//        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
//            rightBarButtonItems.append(proMenuBarItem)
//        } else {
////            adViewHeightConstraint.constant = 0.0
////            adShadowView.isHidden = true
//        }
//
//        /* Put things in Right NavigationBar */
//        navigationItem.rightBarButtonItems = rightBarButtonItems
//
//        /* Update the tabView with correct image and button */
//        // Fix this and make it better lol
//        let tabBarItemIndex = (tabBarController?.tabBar.items?.count ?? 0) - 1
//
//        if tabBarItemIndex < 0 {
//            print("Tab bar index is less than zero...")
//            return
//        }
//
//        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
//            tabBarController?.tabBar.items![tabBarItemIndex].image = UIImage(named: Constants.ImageName.premiumBottomButtonNotSelected)
//        } else {
//            tabBarController?.tabBar.items![tabBarItemIndex].image = UIImage(named: Constants.ImageName.shareBottomButtonNotSelected)
//        }
//    }
    
    @objc func showLessPressed() {
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            rootView.tableViewBottomConstraint.constant = keyboardSize.height - (tabBarController?.tabBar.frame.height ?? 0) - rootView.bottomViewThatTableViewIsAlignedTo.frame.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        rootView.tableViewBottomConstraint.constant = 0
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
//    @objc func openMenu() {
//        performSegue(withIdentifier: "toSettingsView", sender: nil)
//    }
//
//    @objc func shareApp() {
//        let activityVC = UIActivityViewController(activityItems: [UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) ?? ""], applicationActivities: [])
//
//        present(activityVC, animated: true)
//    }
//
//    @objc func ultraPressed() {
//        goToUltraPurchase()
//    }
    
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


