//
//  ExplorePresentationSpecification.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

class ExplorePresentationSpecification: PresentationSpecification {
    
    var viewController: UIViewController = ExploreViewController.Builder<ExploreViewController>(sourcedTableViewManager: IndentedHeaderSourcedTableViewManager())
        .set(sources: [
            [
                CollectionTableViewCellSource.Builder()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: UIImage(systemName: "pencil")!,
                                titleText: "Write Essay",
                                descriptionText: "Learn about a topic in a brand new way.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is the essay about?",
                                        promptPrefix: "Write an essay about")
                                ])
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ]
        ])
        .set(orderedSectionHeaderTitles: [
            "Suggested",
            "Content",
            "Art",
            "Business",
            "Personal",
            "Email",
            "Social",
            "Code",
            "Food",
            "Entertainment"
        ])
        .register(Registry.Common.View.Table.Cell.managedCollectionView)
        .build(managedTableViewNibName: Registry.Common.View.managedTableViewIn)
    
}
