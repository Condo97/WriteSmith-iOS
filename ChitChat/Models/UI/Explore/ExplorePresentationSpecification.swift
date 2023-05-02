//
//  ExplorePresentationSpecification.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

class ExplorePresentationSpecification: PresentationSpecification {
    
    var viewController: UIViewController = ExploreViewController.Builder<ExploreViewController>(sourcedTableViewManager: ExploreIndentedHeaderSourcedTableViewManager())
        .set(sources: [
            // MARK: Suggested
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: "💬".toImage()!,//UIImage(systemName: "squareshape.squareshape.dashed")!,
                                titleText: "Summarize",
                                descriptionText: "Simplify complex topics in just a few sentences.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What would you like to summarize?",
                                        promptPrefix: "Summarize",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: "🪄".toImage()!,
                                titleText: "Make Interesting",
                                descriptionText: "Add a twist to any topic and make it surprisingly fascinating.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What would you like to make more interesting?",
                                        promptPrefix: "Make the following more interesting:",
                                        required: true) // TODO: - Is there a better way to apply this?
                                ]), // Cmd Shift I for little indents! :)
                            ItemSource(
                                iconImage: "👍".toImage()!,
                                titleText: "Convince",
                                descriptionText: "Use words to convince someone to do something!",
                                behavior: "Write something that will convince someone of something using my input.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What would you like to convince someone to do?",
                                        promptPrefix: "Convince someone to...",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Who are you convincing?",
                                        promptPrefix: "Convince this person:"
                                    )
                                ])
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            
            // MARK: Content
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: "📝".toImage()!,
                                titleText: "Write an Essay",
                                descriptionText: "Learn about a topic in a brand new way.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is the essay about?",
                                        promptPrefix: "Write an essay about",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Tone of voice?",
                                        promptPrefix: "With the tone of voice:",
                                        detailTitle: "Tone of Voice",
                                        detailText: "How would you like your advertisement to come off? (i.e. Fun, Convincing, Trendy, etc.)")
                                ]),
                            ItemSource(
                                iconImage: "📗".toImage()!,
                                titleText: "Create an Outline",
                                descriptionText: "Organize your thoughts and ideas with a structured outline for any topic.",
                                components: [
                                    // TODO: Should be "write an essay about" in the ItemSource
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is the topic for your outline?",
                                        promptPrefix: "Write an outline about",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "How many sections?",
                                        promptPrefix: "number of sections")
                                ]),
                            ItemSource(
                                iconImage: "✅".toImage()!,
                                titleText: "Proofread",
                                descriptionText: "Polish your writing and eliminate errors with the help of an AI proofreader.",
                                behavior: "You are an AI that proofreads a user's text, correcting any grammatical errors.",
                                components: [
                                    // TODO: Should be "write an essay about" in the ItemSource
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What should I proofread?",
                                        promptPrefix: "",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: "✍️".toImage()!,
                                titleText: "Write a Paragraph",
                                descriptionText: "Spark creativity with a captivating paragraph made to inspire.",
                                behavior: "Write a paragraph.",
                                components: [
                                    // TODO: Should be "write an essay about" in the ItemSource
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is your paragraph about?",
                                        promptPrefix: "",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Tone of voice?",
                                        promptPrefix: "With the tone of voice:",
                                        detailTitle: "Tone of Voice",
                                        detailText: "How would you like your paragraph to come off? (i.e. Fun, Convincing, Trendy, etc.)")
                                ]),
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            
            // MARK: Art
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: "🎤".toImage()!,
                                titleText: "Lyrics",
                                descriptionText: "Craft the perfect lyrics for a hit song and leave everyone singing along.",
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
                                iconImage: "📜".toImage()!,
                                titleText: "Poem",
                                descriptionText: "Compose a beautiful poem that speaks to the heart and stirs the soul.",
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
                                iconImage: "📖".toImage()!,
                                titleText: "Story",
                                descriptionText: "Weave a captivating tale that takes readers on an unforgettable journey.",
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
                                iconImage: "🎬".toImage()!,
                                titleText: "Movie Script",
                                descriptionText: "Pen a script that'll have Hollywood knocking on your door.",
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
                                iconImage: "🎶".toImage()!,
                                titleText: "Muscial Notes",
                                descriptionText: "Create enchanting sheet music, tabs, and chords for your next masterpiece.",
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
            ],
            
            // MARK: Business
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: "📣".toImage()!,
                                titleText: "Slogan",
                                descriptionText: "Invent a catchy slogan that sets your company apart.",
                                behavior: "Write a catchy slogan.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "Describe your company...",
                                        promptPrefix: "Write a slogan for the company as described:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is your company named?",
                                        promptPrefix: "The company is named:"),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is your company's main competitor?",
                                        promptPrefix: "The company's main competitor is named:")
                                ]),
                            ItemSource(
                                iconImage: "🌟".toImage()!,
                                titleText: "Advertisement",
                                descriptionText: "Write a persuasive ad that draws in customers and skyrockets your sales.",
                                behavior: "Make a convincing advertsiement",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is your advertisement about?",
                                        promptPrefix: "Write an advertisement about:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What medium are you advertising for?",
                                        promptPrefix: "Using the medium:",
                                        detailTitle: "Advertisement Medium",
                                        detailText: "Where are you advertising? (i.e. Social Media, Print, TV, etc.)"),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Tone of voice?",
                                        promptPrefix: "With the tone of voice:",
                                        detailTitle: "Tone of Voice",
                                        detailText: "How would you like your advertisement to come off? (i.e. Fun, Convincing, Trendy, etc.)")
                                ]),
                            ItemSource(
                                iconImage: "💼".toImage()!,
                                titleText: "Company Bio",
                                descriptionText: "Showcase your company's strengths with an engaging bio.",
                                behavior: "Write a company bio that is enticing to customers.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Briefly describe your company...",
                                        promptPrefix: "Description: ",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Company name?",
                                        promptPrefix: "Company name:"),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Similar companies?",
                                        promptPrefix: "Similar companies:")
                                ]),
                            ItemSource(
                                iconImage: "🔖".toImage()!,
                                titleText: "Name Generator",
                                descriptionText: "Discover the perfect name for your new company that resonates with your vision.",
                                behavior: "Generate a company name from the description provided.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Briefly describe your company...",
                                        promptPrefix: "Description:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Give 3+ words describing the \"vibe\" (i.e. innovative, exciting, inclusive)",
                                        promptPrefix: "Use these words as inspiration:")
                                ]),
                            ItemSource(
                                iconImage: "🧑‍💻".toImage()!,
                                titleText: "Job Post",
                                descriptionText: "Attract top talent with a well-crafted job post that showcases the perfect role.",
                                behavior: "Write a convincing job post.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What job are you looking for?",
                                        promptPrefix: "The job I am looking for is:",
                                        required: true),
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "Describe yourself...",
                                        promptPrefix: "This is the description of myself:",
                                        detailTitle: "Describe Yourself",
                                        detailText: "Around a paragraph, include skills and interesting points. You can also just copy/paste your resume.")
                                ])
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            
            // MARK: Personal
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: "🎂".toImage()!,
                                titleText: "Birthday",
                                descriptionText: "Create unforgettable birthday messages or plan the ultimate surprise party.",
                                behavior: "You are amazing at everything pertaining to birthdays.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Who's birthday is it?",
                                        promptPrefix: "It is this person's birthday:",
                                        required: true),
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What would you like help with?",
                                        promptPrefix: "")
                                ]),
                            ItemSource(
                                iconImage: "🥺".toImage()!,
                                titleText: "Apology",
                                descriptionText: "Get help writing a sincere apology to someone you care about.",
                                behavior: "Help write a sincere apology.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is the apology for?",
                                        promptPrefix: "The apology is for:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Who is the apology for?",
                                        promptPrefix: "The person the apology is for is:")
                                ]),
                            ItemSource(
                                iconImage: "🔥".toImage()!,
                                titleText: "Rizz",
                                descriptionText: "Master the art of flirting and become a rizz lord in no time.",
                                behavior: "You are a rizz lord and help with picking up girls or men.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Who are you trying to rizz?",
                                        promptPrefix: "Rizz this person:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What are they like?",
                                        promptPrefix: "They are like:",
                                        required: true),
                                ]),
                            ItemSource(
                                iconImage: "📩".toImage()!,
                                titleText: "Invitation",
                                descriptionText: "Get inspiration for an invitation that nobody can refuse.",
                                behavior: "Write an invitation that is kind and convincing.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What is the invitation for?",
                                        promptPrefix: "The invitation is for:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Who is the invitation for?",
                                        promptPrefix: "The person the invitation is for is:")
                                ]),
                            ItemSource(
                                iconImage: "🗣️".toImage()!,
                                titleText: "Speech",
                                descriptionText: "Write a powerful speech that engages and inspires your audience.",
                                behavior: "Write an unforgettable and engaging and interesting speech.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is your speech about?",
                                        promptPrefix: "The speech is about:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Tone of voice?",
                                        promptPrefix: "The tone of voice is:",
                                        detailTitle: "Tone of Voice",
                                        detailText: "This is the \"vibe\" your speech is going for. (i.e. Funny, Serious, Dark, etc.)")
                                ])
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            
            // MARK: Email
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: "📧".toImage()!,
                                titleText: "Email",
                                descriptionText: "Craft the perfect email that gets your message across and garners a response.",
                                behavior: "Write an email.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is the email about?",
                                        promptPrefix: "The email is about:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Who is the email for?",
                                        promptPrefix: "The email is for...")
                                ]),
                            ItemSource(
                                iconImage: "✒️".toImage()!,
                                titleText: "Write a Subject",
                                descriptionText: "Write a subject that ensures the receiver will open it.",
                                behavior: "Write a subject to an email that convinces the receiver to open it and read it.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is the email about?",
                                        promptPrefix: "The email is about:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Who is the email for?",
                                        promptPrefix: "The email is for...")
                                ]),
                            ItemSource(
                                iconImage: "🤔".toImage()!,
                                titleText: "Improve Email",
                                descriptionText: "Improve an email so that the reader \"gets the message.\"",
                                behavior: "Improve an email..",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What email would you like to improve?",
                                        promptPrefix: "The email to improve is:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Who is the email for?",
                                        promptPrefix: "The email is for...")
                                ])
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            
            // MARK: Social
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: UIImage(named: Constants.ImageName.ItemSourceImages.twitter)!,
                                titleText: "Tweet",
                                descriptionText: "Compose attention-grabbing tweets that boost your followers and likes.",
                                behavior: "Write a interesting and convincing tweet that is sure to go viral.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is the tweet about?",
                                        promptPrefix: "The tweet is about:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Tone of voice?",
                                        promptPrefix: "The tone of voice is:",
                                        detailTitle: "Tone of Voice",
                                        detailText: "This is the \"vibe\" your tweet is going for. (i.e. Funny, Serious, Dark, etc.)")
                                ]),
                            ItemSource(
                                iconImage: UIImage(named: Constants.ImageName.ItemSourceImages.twitter)!,
                                titleText: "Turn into Tweet",
                                descriptionText: "Turn blog posts, articles, even other social media posts into a tweet.",
                                behavior: "Turn something into an interesting and convincing tweet.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "Write what you want to turn into a tweet...",
                                        promptPrefix: "Turn this into a tweet:",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: UIImage(named: Constants.ImageName.ItemSourceImages.linkedIn)!,
                                titleText: "LinkedIn Post",
                                descriptionText: "Engage professionals with a well-crafted LinkedIn post that stands out.",
                                behavior: "Write a LinkedIn post that engages businesses.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is the post about?",
                                        promptPrefix: "The post is about:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Tone of voice?",
                                        promptPrefix: "The tone of voice is:",
                                        detailTitle: "Tone of Voice",
                                        detailText: "This is the \"vibe\" your post is going for. (i.e. Funny, Serious, Dark, etc.)")
                                ]),
                            ItemSource(
                                iconImage: UIImage(named: Constants.ImageName.ItemSourceImages.instagram)!,
                                titleText: "Instagram Caption",
                                descriptionText: "Capture the perfect vibe with an Instagram caption that reels in likes.",
                                behavior: "Create an engaging and interesting Instagram caption that engages viewers and will get millions of likes.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is your post about?",
                                        promptPrefix: "The Instagram caption is about an image as described:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Tone of voice?",
                                        promptPrefix: "The tone of voice is:",
                                        detailTitle: "Tone of Voice",
                                        detailText: "This is the \"vibe\" your caption is going for. (i.e. Funny, Serious, Dark, etc.)")
                                ]),
                            ItemSource(
                                iconImage: UIImage(named: Constants.ImageName.ItemSourceImages.tikTok)!,
                                titleText: "TikTok Caption",
                                descriptionText: "Craft a TikTok caption that grabs attention and sends your views soaring.",
                                behavior: "Create an engaging and interesting TikTok caption that engages viewers and will get millions of likes.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is the TikTok about?",
                                        promptPrefix: "The TikTok caption is about a video as described:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Tone of voice?",
                                        promptPrefix: "The tone of voice is:",
                                        detailTitle: "Tone of Voice",
                                        detailText: "This is the \"vibe\" your caption is going for. (i.e. Funny, Serious, Dark, etc.)")
                                ]),
                            ItemSource(
                                iconImage: "💯".toImage()!,
                                titleText: "Viral Video Ideas",
                                descriptionText: "Get creative with unique viral video ideas that'll skyrocket your popularity.",
                                behavior: "Create a list of viral video ideas.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What genre is your video for?",
                                        promptPrefix: "The genre for the video is:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Creators for inspiration?",
                                        promptPrefix: "Creators for inspiration:"),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Additional guidance?",
                                        promptPrefix: "",
                                        detailTitle: "Additional Guidance",
                                        detailText: "Provide additional instructions for your AI to work with. (i.e. Format ideas for vertial video.)"
                                    )
                                ]),
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            
            // MARK: Code
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: "💻".toImage()!,
                                titleText: "Write Code",
                                descriptionText: "Generate code for any task or problem and watch your ideas come to life.",
                                behavior: "Write code for the given task or problem.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What task or problem should the code solve?",
                                        promptPrefix: "Write code to solve:",
                                        required: true),
                                    DropdownComponentItemExploreTableViewCellSource(
                                        headerText: "Choose a programming language...",
                                        promptPrefix: "using the programming language",
                                        dropdownItems: ["Python", "JavaScript", "Java", "C++", "Swift"])
                                ]),
                            ItemSource(
                                iconImage: "📚".toImage()!,
                                titleText: "Explain Code",
                                descriptionText: "Understand the functionality of a code snippet.",
                                behavior: "Explain the given code snippet and its functionality.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "Paste the code snippet you want explained...",
                                        promptPrefix: "Explain the following code snippet:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What language is the code in?",
                                        promptPrefix: "The code given is in the language:")
                                ]),
                            ItemSource(
                                iconImage: "🤝".toImage()!,
                                titleText: "Code Interview Question",
                                descriptionText: "Tackle code interview questions with confidence and land your dream job.",
                                behavior: "Help me answer a code interview question.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "What is the code interview question?",
                                        promptPrefix: "The code interview question is:",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: "🛠️".toImage()!,
                                titleText: "Code Refactoring",
                                descriptionText: "Optimize your code for peak performance.",
                                behavior: "Refactor the given code snippet for better performance.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "Paste the code snippet you want refactored...",
                                        promptPrefix: "Refactor the following code snippet:",
                                        required: true)
                                ])
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            
            // MARK: Food
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: "👩‍🍳".toImage()!,
                                titleText: "Recipe",
                                descriptionText: "Whip up the perfect dish with a custom recipe tailored to your taste buds.",
                                behavior: "Generate a recipe based on the given dish or ingredient.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What dish or ingredient do you want a recipe for?",
                                        promptPrefix: "Create a recipe for:",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: "🥗".toImage()!,
                                titleText: "Diet Plan",
                                descriptionText: "Achieve your health goals with a personalized diet plan crafted just for you.",
                                behavior: "Create a personalized diet plan.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What are your dietary preferences?",
                                        promptPrefix: "Dietary preferences:",
                                        required: true),
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What are your health goals?",
                                        promptPrefix: "Health goals:")
                                ]),
                            ItemSource(
                                iconImage: "🍳".toImage()!,
                                titleText: "Cooking Techniques",
                                descriptionText: "Master the art of cooking any dish or ingredient with expert techniques.",
                                behavior: "Explain cooking techniques for the given dish or ingredient.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What dish or ingredient do you want to learn techniques for?",
                                        promptPrefix: "Explain cooking techniques for:",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: "🍲".toImage()!,
                                titleText: "Food Pairing",
                                descriptionText: "Uncover perfect food pairings that elevate your dishes to new heights.",
                                behavior: "Suggest food pairings for the given ingredient or dish.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What ingredient or dish do you want to find pairings for?",
                                        promptPrefix: "Find food pairings for:",
                                        required: true)
                                ])
                        ]
                    ])
                    .register(collectionXIB_ReuseID: Registry.Explore.View.Collection.Cell.item)
                    .build()
            ],
            
            // MARK: Entertainment
            [
                ExploreCollectionTableViewCellSource.Builder<ExploreCollectionTableViewCellSource>()
                    .set(collectionSources: [
                        [
                            ItemSource(
                                iconImage: "🍿".toImage()!,
                                titleText: "Movies to Emoji",
                                descriptionText: "Describe your favorite movies using just emojis!",
                                behavior: "Describe the given movie using only emojis.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What movie do you want to describe with emojis?",
                                        promptPrefix: "Describe the movie using only emojis",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: "😂".toImage()!,
                                titleText: "Tell Joke",
                                descriptionText: "Brighten someone's day with a hilarious joke they won't see coming.",
                                behavior: "Tell a joke.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Any specific topic for the joke?",
                                        promptPrefix: "Tell a joke about")
                                ]),
                            ItemSource(
                                iconImage: "✏️".toImage()!,
                                titleText: "Complete Sentence",
                                descriptionText: "Fill in the blanks with the perfect words to complete any sentence or phrase.",
                                behavior: "Complete the given sentence or phrase.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "Write the incomplete sentence or phrase...",
                                        promptPrefix: "Complete the sentence or phrase:",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: "👥".toImage()!,
                                titleText: "Create Conversation",
                                descriptionText: "Invent engaging dialogues between characters with a touch of AI magic.",
                                behavior: "Create a conversation between two or more characters.",
                                components: [
                                    TextViewComponentItemExploreTableViewCellSource(
                                        headerText: "Describe the characters and the context...",
                                        promptPrefix: "Create a conversation with the following context:",
                                        required: true)
                                ]),
                            ItemSource(
                                iconImage: "🦛".toImage()!,
                                titleText: "Made Up Words",
                                descriptionText: "Invent quirky new words and their meanings for a world of linguistic fun.",
                                behavior: "Create new words and their meanings.",
                                components: [
                                    TextFieldComponentItemExploreTableViewCellSource(
                                        headerText: "What's the theme or context for the new words?",
                                        promptPrefix: "Create new words for the theme or context:")
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
        .register(Registry.Explore.View.Table.Cell.collection)
        .build(managedTableViewNibName: Registry.Explore.View.explore)
    
}
