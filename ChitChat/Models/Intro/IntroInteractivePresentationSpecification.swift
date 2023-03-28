//
//  IntroInteractivePresentationSpecification.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

struct IntroInteractivePresentationSpecification: PresentationSpecification {
    
    let introInteractiveViewControllers: [any LoadableViewController & IntroInteractiveViewController]
    
    let storiesViewController: ChatIntroInteractiveViewController = ChatIntroInteractiveViewController()
        .set(rootView: RegistryHelper.instantiateAsView(nibName: Registry.View.IntroInteractiveView.chat) as! ChatIntroInteractiveView) // TODO: - Should this be generated without an instance?
        .add(headerLabelSource: LabelTableViewCellSource(
            text: "Create",
            font: UIFont(name: Constants.primaryFontNameBlack, size: 90.0)!,
            color: Colors.headerTextColor,
            heightConstraintConstant: 90.0,
            topSpaceConstraintConstant: 14.0,
            bottomSpaceConstraintConstant: 0.0))
        .add(headerLabelSource: LabelTableViewCellSource(
            text: "Unique Stories",
            font: UIFont(name: Constants.primaryFontName, size: 40.0)!,
            color: Colors.headerTextColor,
            heightConstraintConstant: 40.0))
        .add(headerLabelSource: LabelTableViewCellSource(
            text: "+ more!",
            font: UIFont(name: Constants.primaryFontName, size: 20)!,
            color: Colors.headerTextColor,
            heightConstraintConstant: 20,
            topSpaceConstraintConstant: 14.0,
            bottomSpaceConstraintConstant: 0.0))
        .add(chat: ChatObject(
            text: "Write a narrative on loss and war from the viewpoint of a dog.",
            sender: .user))
        .add(chat: ChatObject(
            text: "I watched my master leave for war, never to return. I waited faithfully, but he never came back. I mourned his loss, and the loss of my home. War had taken away everything I loved.",
            sender: .ai))
        .add(choice: PreloadedResponseChatObject(
            text: "Write a limerick about cats...",
            responseText: "There once was a cat from the city\nWho loved to lounge in the sun so pretty\nHe'd nap in the day\nAnd play in the hay\nAnd purr when he felt really witty",
            sender: .user,
            responseSender: .ai))
        .add(choice: PreloadedResponseChatObject(
            text: "Tell me a silly story about ducks",
            responseText: "Once upon a time, a group of ducks decided to start a band. They called themselves \"The Quack Pack\" and played only duck-themed songs. Unfortunately, they were terrible musicians and their only fan was a confused cat. They eventually disbanded and went back to their day jobs of swimming and quacking. The end.",
            sender: .user,
            responseSender: .ai))
    
    let essaysAsChatViewController: ChatIntroInteractiveViewController = ChatIntroInteractiveViewController()
        .set(rootView: RegistryHelper.instantiateAsView(nibName: Registry.View.IntroInteractiveView.chat) as! ChatIntroInteractiveView) // TODO: - Should this be generated without an instance?
        .add(headerLabelSource: LabelTableViewCellSource(
            text: "Write",
            font: UIFont(name: Constants.primaryFontNameBlack, size: 90.0)!,
            color: Colors.headerTextColor,
            heightConstraintConstant: 90.0,
            topSpaceConstraintConstant: 14.0,
            bottomSpaceConstraintConstant: 0.0))
        .add(headerLabelSource: LabelTableViewCellSource(
            text: "Smart Essays",
            font: UIFont(name: Constants.primaryFontName, size: 40.0)!,
            color: Colors.headerTextColor,
            heightConstraintConstant: 40.0))
        .add(headerLabelSource: LabelTableViewCellSource(
            text: "With the Latest AI Algorithm",
            font: UIFont(name: Constants.primaryFontName, size: 20)!,
            color: Colors.headerTextColor,
            heightConstraintConstant: 22,
            topSpaceConstraintConstant: 14.0,
            bottomSpaceConstraintConstant: 0.0))
        .add(chat: ChatObject(
            text: "Summarize To Kill a Mockingbird",
            sender: .user))
        .add(chat: ChatObject(
            text: "To Kill a Mockingbird is a novel by Harper Lee set in the 1930s in a small town in Alabama. The story is narrated by Scout Finch, a young girl who learns about racism and injustice through the trial of Tom Robinson, a black man falsely accused of sexual assault. The novel explores themes of prejudice, courage, and the loss of innocence.",
            sender: .ai))
        .add(choice: PreloadedResponseChatObject(
            text: "Write an essay on the bill of rights...",
            responseText: "The Bill of Rights is a crucial document that outlines the fundamental rights and freedoms of American citizens. It was added to the United States Constitution in 1791, and it has since served as a cornerstone of American democracy. The Bill of Rights is a testament to the values of the American people and their commitment to individual liberty and justice.\n\nThe Bill of Rights consists of ten amendments that limit the power of the federal government and protect the rights of citizens. These amendments include the freedom of speech, religion, and the press, the right to bear arms, the right to a fair trial, and protection against unreasonable searches and seizures. These rights are essential to the functioning of a free and democratic society, and they ensure that the government cannot infringe upon the basic rights of its citizens.\n\nThe Bill of Rights has been a source of controversy and debate throughout American history. Some argue that it is too restrictive and limits the power of the government too much, while others believe that it is necessary to protect individual rights and prevent tyranny. Regardless of one's opinion, the Bill of Rights remains a vital document that reflects the values and principles of the American people. It is a reminder that the government exists to serve the people, not the other way around, and that individual liberty and justice are the foundation of a free and democratic society.",
            sender: .user,
            responseSender: .ai))
        .add(choice: PreloadedResponseChatObject(
            text: "Paper on quantum mechanics...",
            responseText: "Quantum mechanics is the branch of physics that studies the behavior of matter and energy at the smallest scales, such as atoms and subatomic particles. It's a weird and fascinating world where particles can exist in multiple places at once, and their behavior is determined by probabilities rather than definite outcomes. Quantum mechanics has led to the development of technologies like lasers, transistors, and MRI machines, and it's also challenged our understanding of reality itself. It's a field that continues to push the boundaries of what we know and what we thought was possible.",
            sender: .user,
            responseSender: .ai))
        .add(choice: PreloadedResponseChatObject(
            text: "Explain the TikTok ban...",
            responseText: "The TikTok ban has been making headlines all over the world, leaving millions of users in a state of shock and confusion. But what exactly is the TikTok ban and why is it happening?\n\nWell, it all started when the Indian government decided to ban TikTok and 58 other Chinese apps, citing national security concerns. This move came after a deadly border clash between Indian and Chinese troops in the Himalayas, which led to a surge in anti-China sentiment in India.\n\nBut the ban didn't stop there. The United States also announced plans to ban TikTok, citing concerns over data privacy and security. President Trump even went as far as to sign an executive order that would effectively ban TikTok from operating in the US unless it was sold to an American company.\n\nThis sparked a frenzy of activity, with tech giants like Microsoft and Oracle vying to buy TikTok's US operations. But the drama didn't end there. TikTok filed a lawsuit against the US government, claiming that the ban was unconstitutional and violated their rights.\n\nSo, what does all of this mean for TikTok users? Well, it's still unclear. The ban in India has already taken effect, leaving millions of users without access to the app. The ban in the US is set to take effect on September 20th, but there's still a chance that a deal could be reached to save the app.\n\nIn the meantime, TikTok users are left wondering what the future holds for their beloved app. Will it be banned forever? Will it be sold to an American company? Only time will tell. But one thing's for sure – the TikTok ban has certainly caused a stir in the tech world, and it's not over yet.",
            sender: .user,
            responseSender: .ai))
    
//    let essaysViewController: EssayIntroInteractiveViewController = EssayIntroInteractiveViewController()
//        .addChoice(choice: PreloadedResponseChatObject(
//            text: "Write me a 500 word essay about the Bill of Rights",
//            responseText: <#T##String#>,
//            sender: .user,
//            responseSender: .ai))
    
    init() {
        introInteractiveViewControllers = [
            storiesViewController,
            essaysAsChatViewController
        ]
    }
}
