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
    
//    let sourcedTableViewManager: SourcedTableViewManagerProtocol = EssaySmallBlankHeaderSourcedTableViewManager()
    
    let entrySection: Int = 0
    let essaySection: Int = 1
    
//    var toolbar: UIToolbar!
    var shouldSaveEdit: SaveEdit = .none
    
    var logoMenuBarItem = UIBarButtonItem()
    
//    var essays: [Essay] = []
    var origin: CGFloat = 0.0
    
    var isProcessingChat = false
    var firstChat = false
    var wasPremium = false
    var tempPrompt = ""
    
    var observerID: Int?
    
    lazy var essayTableViewDelegate: EssayTableViewDelegate = EssayTableViewDelegate()
    
    lazy var fetchedResultsTableViewDataSource: EssayTableViewDataSource<Essay>? = {
        let fetchRequest: NSFetchRequest<Essay> = Essay.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Essay.date), ascending: false)
        ]
        
        return EssayTableViewDataSource<Essay>(
            tableView: rootView.tableView,
            managedObjectContext: CDClient.mainManagedObjectContext,
            fetchRequest: fetchRequest,
            cacheName: nil,
            topViewCellReuseIdentifier: Registry.Essay.View.Table.Cell.entry.reuseID,
            topViewCellDelegate: self,
            premiumCellReuseIdentifier: Registry.Essay.View.Table.Cell.premium.reuseID,
            premiumCellDelegate: self,
            loadingCellReuseIdentifier: Registry.Essay.View.Table.Cell.loading.reuseID,
            editingDelegate: nil,
            universalCellDelegate: self,
            reuseIdentifier: {essay, indexPath in
                return Registry.Essay.View.Table.Cell.essay.reuseID
            })
    }()
    
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
        
        /* Setup Table View Manager */
        rootView.tableView.delegate = essayTableViewDelegate
        rootView.tableView.dataSource = fetchedResultsTableViewDataSource
//        rootView.tableView.manager = sourcedTableViewManager
        
//        /* Set Haptics to Not Enabled */
//        rootView.tableView.manager!.hapticsEnabled = false
        
        /* Setup EssayCell Nibs */
//        RegistryHelper.register(Registry.Essay.View.Table.Cell.body, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.essay, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.entry, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.loading, to: rootView.tableView)
        RegistryHelper.register(Registry.Essay.View.Table.Cell.premium, to: rootView.tableView)
//        RegistryHelper.register(Registry.Essay.View.Table.Cell.prompt, to: rootView.tableView)
        
//        /* Get All Essays */
//        Task {
//            essays = await EssayCDHelper.getAllEssaysReversed() ?? [] //TODO: Should this be unwrapped like this?
//
//            /* Setup Sources */
//            DispatchQueue.main.async {
//                // Set entry source and delegate
//                self.rootView.tableView.manager!.sources.append([EntryEssayTableViewCellSource(cellDelegate: self, textViewDelegate: self, useTryPlaceholderWhenLoaded: !PremiumHelper.get())])
//
//                // Set prompt and body
//                self.rootView.tableView.manager!.sources.append(TableViewCellSourceFactory.makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObjectArray: self.essays, delegate: self, inputAccessoryView: self.toolbar)!)
//
//                // If not premium, append premium source in the essaySection
//                if !PremiumHelper.get() {
//                    self.rootView.tableView.manager!.sources[self.essaySection].append(PremiumEssayTableViewCellSource(delegate: self))
//                }
//
//                self.rootView.tableView.reloadData()
//            }
//        }
        
        // Update premium cell showing
        updatePremiumCellShowing()
        
//        /* Setup Ordered Section Headers */
//        rootView.tableView.manager!.orderedSectionHeaderTitles = [] // TODO: - Order these by date, right now this just gives it a header
        
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
        
        // Get topView cell and update the placeholder text
        loadEntryPlaceholderText()
        
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
        
        updatePremiumCellShowing()
        
//        DispatchQueue.main.async {
//            // Set shouldShowDeleteButton to isPremium in all prompt sources
//            for sourceArray in self.sourcedTableViewManager.sources {
//                for source in sourceArray {
//                    if let promptSource = source as? PromptEssayTableViewCellSource {
//                        promptSource.shouldShowDeleteButton = isPremium
//                    }
//                }
//            }
//
//            self.updatePremiumCellShowing()
//        }
        
    }
    
    override func setLeftMenuBarItems() {
        super.setLeftMenuBarItems()
        
//        // Remove first left bar button item if it is there
//        if navigationItem.leftBarButtonItems!.count > 0 {
//            navigationItem.leftBarButtonItems!.remove(at: 0)
//        }
        
        //TODO: Swap this with the three lines, since the gear is shown on more views
        // Insert gear button with settingsPressed target as first left bar button item
        let settingsMenuBarButtonImage = UIImage(systemName: "gear")
        let settingsMenuBarButton = UIButton(type: .custom)
        settingsMenuBarButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 28.0)
        settingsMenuBarButton.tintColor = Colors.elementTextColor
        settingsMenuBarButton.setBackgroundImage(settingsMenuBarButtonImage, for: .normal)
        settingsMenuBarButton.addTarget(self, action: #selector(settingsPressed), for: .touchUpInside)
        let settingsMenuBarItem = UIBarButtonItem(customView: settingsMenuBarButton)
        
        navigationItem.leftBarButtonItems = [settingsMenuBarItem]
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
    
//    @objc func cancelEditingPressed() {
//        // Do haptic
//        HapticHelper.doLightHaptic()
//
//        // Set shouldSaveEdit to cancel and dismiss keyboard
//        shouldSaveEdit = .cancel
//        dismissKeyboard()
//    }
//
//    @objc func saveEditingPressed(sender: Any) {
//        // Do haptic
//        HapticHelper.doMediumHaptic()
//
//        // Set shouldSaveEdit to save and dismiss keyboard
//        shouldSaveEdit = .save
//        dismissKeyboard()
//    }
    
    func goToUltraPurchase() {
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
    func addEssay(prompt: String, essayText: String) async throws {
        // Save Essay
        let essay = try await EssayCDHelper.appendEssay(prompt: prompt, essayText: essayText, date: Date(), userEdited: false)
//
//            // Create newEssay in managed context
//            essays.append(essay)
//
//            DispatchQueue.main.async {
//                // Get source array containing prompt source and body source for the inserted essay
//                let sourceArray = TableViewCellSourceFactory.makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObject: self.essays.last!, delegate: self, inputAccessoryView: self.toolbar)!
//
//                // Insert prompt and body cells at top
//                self.sourcedTableViewManager.sources[self.essaySection].insert(sourceArray[1], at: 0)
//                self.sourcedTableViewManager.sources[self.essaySection].insert(sourceArray[0], at: 0)
//                self.rootView.tableView.reloadData()
//            }
//        }
    }
    
//    func insertPremiumCell() {
//        DispatchQueue.main.async {
//            self.sourcedTableViewManager.sources[self.essaySection].append(PremiumEssayTableViewCellSource(delegate: self))
//
//            self.rootView.tableView.reloadData()
//        }
//    }
//
//    func removePremiumCell() {
//        DispatchQueue.main.async {
//            let lastCellIndexPath = IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.essaySection) - 1, section: self.essaySection)
//
//            if self.rootView.tableView.cellForRow(at: lastCellIndexPath) is EssayPremiumTableViewCell {
//                self.sourcedTableViewManager.sources[lastCellIndexPath.section].remove(at: lastCellIndexPath.row)
//
//                self.rootView.tableView.reloadData()
//            } else {
//                print("The last cell was not EssayPremiumTableViewCell, so it couldn't be deleted!")
//            }
//        }
//    }
    
    func loadEntryPlaceholderText() {
        // Get and unwrap entry cell, otherwise return
        guard let entryCell = fetchedResultsTableViewDataSource?.getTopViewCell() as? EssayEntryTableViewCell else {
            // TODO: Handle errors
            return
        }
        
        // Use textFieldLoadPlaceholder with useTryPlaceholder as not is premium to update placeholder text
        entryCell.textViewLoadPlaceholder(useTryPlaceholder: !PremiumHelper.get())
    }
    
    func updatePremiumCellShowing() {
        DispatchQueue.main.async {
            if !PremiumHelper.get() {
                self.fetchedResultsTableViewDataSource?.showPremiumCell()
            } else {
                self.fetchedResultsTableViewDataSource?.hidePremiumCell()
            }
        }
        
//        // Ensure the essaySection exists
//        guard sourcedTableViewManager.sources.count > self.essaySection else {
//            // TODO: Handle error if necessary
//            return
//        }
//
//        // If sources contains premiumEssayTableViewCellSource and is premium then remove it, otherwise if it doesent and user is not premium, then add it
//        let containsPremiumEssayTableViewCellSource = self.sourcedTableViewManager.sources[self.essaySection].contains(where: {$0 is PremiumEssayTableViewCellSource})
//        if containsPremiumEssayTableViewCellSource && PremiumHelper.get() {
//            DispatchQueue.main.async {
//                self.sourcedTableViewManager.sources[self.essaySection].removeAll(where: {$0 is PremiumEssayTableViewCellSource})
//
//                self.rootView.tableView.reloadData()
//            }
//        } else if !containsPremiumEssayTableViewCellSource && !PremiumHelper.get() {
//            DispatchQueue.main.async {
//                self.sourcedTableViewManager.sources[self.essaySection].append(PremiumEssayTableViewCellSource(delegate: self))
//
//                self.rootView.tableView.reloadData()
//            }
//        }
    }
    
}


