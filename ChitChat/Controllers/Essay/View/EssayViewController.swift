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
    
    let sourcedTableViewManager: SourcedTableViewManagerProtocol = EssaySmallBlankHeaderSourcedTableViewManager()
    
    let entrySection: Int = 0
    let essaySection: Int = 1
    
    var toolbar: UIToolbar!
    var shouldSaveEdit: SaveEdit = .none
    
    var logoMenuBarItem = UIBarButtonItem()
    
    var essays: [Essay] = []
    var origin: CGFloat = 0.0
    let toolbarHeight = 48.0
    
    var isProcessingChat = false
    var firstChat = false
    var wasPremium = false
    var tempPrompt = ""
    
    var observerID: Int?
    
    
    lazy var rootView: EssayView = {
        let view = RegistryHelper.instantiateAsView(nibName: Registry.Essay.View.essay, owner: self) as! EssayView
        return view
    }()!
    
    override func loadView() {
        super.loadView()
        
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
        
        /* Set Haptics to Not Enabled */
        rootView.tableView.manager!.hapticsEnabled = false
        
        /* Setup EssayCell Nibs */
        RegistryHelper.register(Registry.Essay.View.Table.Cell.body, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.entry, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.loading, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.premium, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.prompt, to: rootView.tableView)
        
        /* Get All Essays */
        essays = EssayCDHelper.getAllEssaysReversed()! //TODO: Should this be unwrapped?
        
        /* Setup Sources */
        // Set entry source and delegate
        rootView.tableView.manager!.sources.append([EntryEssayTableViewCellSource(cellDelegate: self, textViewDelegate: self, useTryPlaceholderWhenLoaded: !PremiumHelper.get())])
        
        // Set prompt and body
        rootView.tableView.manager!.sources.append(TableViewCellSourceFactory.makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObjectArray: essays, delegate: self, inputAccessoryView: toolbar)!)
        
        // If not premium, append premium source in the essaySection
        if !PremiumHelper.get() {
            rootView.tableView.manager!.sources[essaySection].append(PremiumEssayTableViewCellSource(delegate: self))
        }
        
        /* Setup Ordered Section Headers */
        rootView.tableView.manager!.orderedSectionHeaderTitles = [] // TODO: - Order these by date, right now this just gives it a header
        
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
            // Set shouldShowDeleteButton to isPremium in all prompt sources
            for sourceArray in self.sourcedTableViewManager.sources {
                for source in sourceArray {
                    if let promptSource = source as? PromptEssayTableViewCellSource {
                        promptSource.shouldShowDeleteButton = isPremium
                    }
                }
            }
            
            // If last cell in essaySection is essayPremiumTableViewCell and is premium, then remove it, and if the last cell in essaySection is not essayPremiumTableViewCell but not nil and user is not premium, then add it
            let lastCell = self.rootView.tableView.cellForRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.essaySection) - 1, section: self.essaySection))
            if lastCell is EssayPremiumTableViewCell && isPremium {
                self.removePremiumCell()
            } else if lastCell != nil && !(lastCell is EssayPremiumTableViewCell) && !isPremium {
                self.insertPremiumCell()
            }
        }
        
    }
    
    override func setLeftMenuBarItems() {
        super.setLeftMenuBarItems()
        
        // Remove first left bar button item if it is there
        if navigationItem.leftBarButtonItems!.count > 0 {
            navigationItem.leftBarButtonItems!.remove(at: 0)
        }
        
        //TODO: Swap this with the three lines, since the gear is shown on more views
        // Insert gear button with settingsPressed target as first left bar button item
        let settingsMenuBarButtonImage = UIImage(systemName: "gear")
        let settingsMenuBarButton = UIButton(type: .custom)
        settingsMenuBarButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 28.0)
        settingsMenuBarButton.tintColor = Colors.elementTextColor
        settingsMenuBarButton.setBackgroundImage(settingsMenuBarButtonImage, for: .normal)
        settingsMenuBarButton.addTarget(self, action: #selector(settingsPressed), for: .touchUpInside)
        let settingsMenuBarItem = UIBarButtonItem(customView: settingsMenuBarButton)
        
        navigationItem.leftBarButtonItems!.insert(settingsMenuBarItem, at: 0)
    }
    
    @objc func settingsPressed() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Push to settings TODO: Move this!
        navigationController?.pushViewController(SettingsPresentationSpecification().viewController, animated: true)
    }
    
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
    
    @objc func cancelEditingPressed() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Set shouldSaveEdit to cancel and dismiss keyboard
        shouldSaveEdit = .cancel
        dismissKeyboard()
    }
    
    @objc func saveEditingPressed(sender: Any) {
        // Do haptic
        HapticHelper.doMediumHaptic()
        
        // Set shouldSaveEdit to save and dismiss keyboard
        shouldSaveEdit = .save
        dismissKeyboard()
    }
    
    func goToUltraPurchase() {
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
    func addEssay(prompt: String, essayText: String) {
        // Save Essay
        if let essay = EssayCDHelper.appendEssay(prompt: prompt, essayText: essayText, date: Date(), userEdited: false) {
            
            // Create newEssay in managed context
            essays.append(essay)
            
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
        }
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
    
}


