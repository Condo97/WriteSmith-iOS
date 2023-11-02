//
//  RegistryHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/23/23.
//

import Foundation
import UIKit

class RegistryHelper {
    
    static func instantiateAsView(nibName: String, owner: UIViewController) -> UIView? {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: owner)[0] as? UIView
    }
    
    static func instantiateInitialViewControllerFromStoryboard(storyboardName: String) -> UIViewController? {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController()
    }
    
    
//    static func register(_ xib_reuseID: XIB_ReuseID, to collectionView: UICollectionView) {
//        register([xib_reuseID], to: collectionView)
//    }
//    
//    static func register(_ xib_reuseIDs: [XIB_ReuseID], to collectionView: UICollectionView) {
//        xib_reuseIDs.forEach({ xib_reuseID in
//            collectionView.register(UINib(nibName: xib_reuseID.xibName, bundle: nil), forCellWithReuseIdentifier: xib_reuseID.reuseID)
//        })
//    }
//    
//    static func register(_ xib_reuseID: XIB_ReuseID, to tableView: UITableView) {
//        register([xib_reuseID], to: tableView)
//    }
//    
//    static func register(_ xib_reuseIDs: [XIB_ReuseID], to tableView: UITableView) {
//        xib_reuseIDs.forEach({ xib_reuseID in
//            tableView.register(UINib(nibName: xib_reuseID.xibName, bundle: nil), forCellReuseIdentifier: xib_reuseID.reuseID)
//        })
//    }
}
