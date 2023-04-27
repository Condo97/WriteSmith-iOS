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
                                iconImage: UIImage(systemName: "squareshape.squareshape.dashed")!,
                                titleText: "Summarize",
                                descriptionText: "Make a complex topic easy to understand.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What would you like to summarize?",
                                        promptPrefix: "Summarize",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: UIImage(systemName: "exclamationmark.questionmark")!,
                                titleText: "Make Interesting",
                                descriptionText: "You'll be surprised.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What would you like to make more interesting",
                                        promptPrefix: "Make the following more interesting",
                                        required: true) // TODO: - Is there a better way to apply this?
                                ]),
                            
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            [
                CollectionTableViewCellSource.Builder()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: UIImage(systemName: "pencil")!,
                                titleText: "Write an Essay",
                                descriptionText: "Learn about a topic in a brand new way.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is the essay about?",
                                        promptPrefix: "Write an essay about",
                                        required: true),
                                    DropdownComponentItemExploreTableViewCellSource(
                                        headerText: "Header Text!",
                                        promptPrefix: "Some prompt prefix",
                                        dropdownItems: ["Test1", "test2", "Test 3!"])
                                ]),
                            ItemSource(
                                iconImage: UIImage(systemName: "list.bullet")!,
                                titleText: "Create an Outline",
                                descriptionText: "Create an outline for any topic.",
                                components: [
                                    // TODO: Should be "write an essay about" in the ItemSource
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is the topic for your outline?",
                                        promptPrefix: "Write an outline about",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "How many sections?",
                                        promptPrefix: "number of sections")
                                ])
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            [
                CollectionTableViewCellSource.Builder()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: UIImage(systemName: "music.mic")!,
                                titleText: "Lyrics",
                                descriptionText: "Write lyrics for a hit song.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is the song about?",
                                        promptPrefix: "Write a song about",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Artist of inspiration?",
                                        promptPrefix: "with the artist of inspiration") // TODO: - Artist needs to be optional, and there need to be optional fields
                                ]),
                            ItemSource(
                                iconImage: UIImage(systemName: "scroll")!,
                                titleText: "Poem",
                                descriptionText: "Write a bespoke poem.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is the poem about?",
                                        promptPrefix: "Write a poem about",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Any words of inspiration?",
                                        promptPrefix: "with these words of inspiration")
                                ]),
                            ItemSource(
                                iconImage: UIImage(systemName: "book")!,
                                titleText: "Story",
                                descriptionText: "Write a story about a topic.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is the story about?",
                                        promptPrefix: "Write a story about",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Any authors for inspiration?",
                                        promptPrefix: "with these authors as inspiration")
                                ]),
                            ItemSource(
                                iconImage: UIImage(systemName: "film")!,
                                titleText: "Movie Script",
                                descriptionText: "Generate a script to an award winning movie.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is the movie about?",
                                        promptPrefix: "Write a movie script about",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Any writers for inspiration?",
                                        promptPrefix: "with these writers as inspiration")
                                ]),
                            ItemSource(
                                iconImage: UIImage(systemName: "music.note.list")!,
                                titleText: "Muscial Notes",
                                descriptionText: "Create sheet music, tab, and chords!",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "Describe your song in detail...",
                                        promptPrefix: "write music for a song with this description",
                                        required: true),
                                    DropdownComponentItemExploreTableViewCellSource(
                                        headerText: "Select a format...",
                                        promptPrefix: "output the request in musical", dropdownItems: [
                                            "Sheet Music",
                                            "Tab",
                                            "Chords",
                                            "Notes"
                                        ])
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
