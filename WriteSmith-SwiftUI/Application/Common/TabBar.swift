//
//  TabBar.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import FaceAnimation
import SwiftUI

struct TabBar: View, KeyboardReadable {
    
    @Environment(\.managedObjectContext) var viewContext
    @State private var selectedTab: Tab = .chat
    
    @ObservedObject private var premiumUpdater: PremiumUpdater
    @ObservedObject private var remainingUpdater: RemainingUpdater
    
    @State private var isShowingGPTModelSelectionView: Bool = false
    
    @State private var isKeyboardVisible: Bool = false
    
    @State private var pushToLatestConversationOrClose: Bool = true
    
    @State private var alertShowingExploreUnderMaintenance: Bool = false
    
    @State private var faceAnimationViewRepresentable: FaceAnimationRepresentable? = FaceAnimationRepresentable(
        frame: CGRect(x: 0, y: 0, width: faceFrameDiameter, height: faceFrameDiameter),
        faceImageName: "face_background",
        color: UIColor(Colors.elementBackgroundColor),
        startAnimation: SmileCenterFaceAnimation(duration: 0.0)
    )
    
    private let buttonWidth: CGFloat = 58.0
    
    private let faceEdgeInset: CGFloat = 8.0
    private static let faceFrameDiameter: CGFloat = 84.0
    private let faceFrameDiameter = faceFrameDiameter
    private let faceBackgroundDiameterScaleFactor: CGFloat = 1.2
    private let faceButtonBottomOffset: CGFloat = 40.0
    
    private var panelGroups: [PanelGroup]? {
        if let panelJson = PanelPersistenceManager.get() {
            do {
                return try PanelParser.parsePanelGroups(fromJson: panelJson)
            } catch {
                // TODO: Handle errors if necessary
                print("Error parsing panel groups from panelJson in TabBar... \(error)")
            }
        }
        
        return nil
    }
    
    init(premiumUpdater: PremiumUpdater, remainingUpdater: RemainingUpdater) {
        self.premiumUpdater = premiumUpdater
        self.remainingUpdater = remainingUpdater
        
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            // Tab Bar Selection
            VStack {
                VStack {
                    TabView(selection: $selectedTab) {
                        ZStack {
                            if let panelGroups = panelGroups {
                                NavigationStack {
                                    ExploreView(
                                        premiumUpdater: premiumUpdater,
                                        remainingUpdater: remainingUpdater,
                                        panelGroups: panelGroups)
                                }
                            } else {
                                MaintenanceView()
                            }
                        }
                        .tag(Tab.explore)
//                        .padding(.bottom, 80)
                        
                        NavigationStack {
                            ConversationView(
                                premiumUpdater: premiumUpdater,
                                remainingUpdater: remainingUpdater,
                                faceAnimationController: $faceAnimationViewRepresentable,
                                isShowingGPTModelSelectionView: $isShowingGPTModelSelectionView,
                                pushToLatestConversationOrClose: $pushToLatestConversationOrClose)
                        }
                        .tag(Tab.chat)
    //                    .padding(.bottom, 80)
                        
                        NavigationStack {
                            EssayView(
                                premiumUpdater: premiumUpdater,
                                remainingUpdater: remainingUpdater)
                        }
                        .tag(Tab.essay)
//                        .padding(.bottom, 80)
                    }
                    
                    VStack(spacing: 0.0) {
        //                Spacer()
                        
                        ZStack {
                            VStack {
                                Spacer()
                                Colors.bottomBarBackgroundColor
        //                            .ignoresSafeArea()
                                    .frame(height: 64.0)
                            }
                            
                            HStack(alignment: .bottom) {
                                HStack {
                                    Spacer()
                                    createButton
                                        .frame(width: buttonWidth)
                                    Spacer()
                                }
                                
                                HStack {
                                    writeButton
                                }
                                
                                HStack {
                                    Spacer()
                                    essayButton
                                        .frame(width: buttonWidth)
                                    Spacer()
                                }
                            }
        //                    .ignoresSafeArea()
                        }
                        .frame(height: 120.0)
                        .background(.clear)
                        
                        Colors.bottomBarBackgroundColor
                            .ignoresSafeArea()
                            .frame(height: 14.0)
                    }
                    .padding(.top, -64)

                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
//                .padding(.bottom, 80)
            }
            
            
            
            // Blur Background View
            if isShowingGPTModelSelectionView {
                MaterialView(.systemMaterialDark)
                    .zIndex(1.0)
                    .animation(.easeInOut, value: isShowingGPTModelSelectionView)
                    .transition(.opacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowingGPTModelSelectionView = false
                        }
                    }
            }
            
            // GPT Model Selection View
            if isShowingGPTModelSelectionView {
                VStack {
                    Spacer()
                    GPTModelSelectionView(
                        premiumUpdater: premiumUpdater,
                        isShowing: $isShowingGPTModelSelectionView)
                    .background(FullScreenCoverBackgroundCleanerView())
//                    .transition(.move(edge: .bottom))
                }
                .zIndex(2.0)
                .padding()
                .animation(.easeInOut, value: isShowingGPTModelSelectionView)
                .transition(.move(edge: .bottom))
                .ignoresSafeArea()
            }
        }
//        .safeAreaInset(edge: .bottom, content: {
//            // Tab Bar Buttons
//            VStack(spacing: 0.0) {
////                Spacer()
//                
//                ZStack {
//                    VStack {
//                        Spacer()
//                        Colors.bottomBarBackgroundColor
////                            .ignoresSafeArea()
//                            .frame(height: 64.0)
//                    }
//                    
//                    HStack(alignment: .bottom) {
//                        HStack {
//                            Spacer()
//                            createButton
//                                .frame(width: buttonWidth)
//                            Spacer()
//                        }
//                        
//                        HStack {
//                            writeButton
//                        }
//                        
//                        HStack {
//                            Spacer()
//                            essayButton
//                                .frame(width: buttonWidth)
//                            Spacer()
//                        }
//                    }
////                    .ignoresSafeArea()
//                }
//                .frame(height: 120.0)
//                .background(.clear)
//                
//                Colors.bottomBarBackgroundColor
////                    .ignoresSafeArea()
//                    .frame(height: 14.0)
//            }
//        })
//        .ignoresSafeArea(.keyboard, edges: .bottom)
//        .ignoresSafeArea(.keyboard,)
//        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: selectedTab, perform: { value in
            // Change faceIdleAnimation
            switch value {
            case .explore:
                faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.deselected)
            case .chat:
                faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.smile)
            case .essay:
                faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.deselected)
            }
        })
        .onReceive(keyboardPublisher, perform: { value in
            isKeyboardVisible = value
        })
        .onAppear {
            // Set face idle animation to smile
            faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.smile)
        }
        .alert("Under Maintenance", isPresented: $alertShowingExploreUnderMaintenance, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text("The Create tab is under maintenance. Please check back later.")
        }
    }
    
    var createButton: some View {
        ZStack {
            Button(action: {
                withAnimation(.none) {
                    if panelGroups == nil {
                        alertShowingExploreUnderMaintenance = true
                    } else {
                        self.selectedTab = .explore
                    }
                }
            }) {
                Image(selectedTab == .explore ? Constants.ImageName.BottomBarImages.createBottomButtonSelected : Constants.ImageName.BottomBarImages.createBottomButton)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Colors.elementTextColor)
            }
            .opacity(panelGroups == nil ? 0.4 : 1.0)
        }
    }
    
    var writeButton: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(selectedTab == .chat ? Colors.elementTextColor : Colors.elementBackgroundColor)
                    .frame(width: faceFrameDiameter * faceBackgroundDiameterScaleFactor)
                if selectedTab != .chat {
                    let lineWidth = 2.0
                    Circle()
                        .stroke(Colors.elementTextColor, lineWidth: lineWidth)
                        .frame(width: faceFrameDiameter * faceBackgroundDiameterScaleFactor - lineWidth)
                }
                faceAnimationViewRepresentable
                    .onChange(of: selectedTab, perform: { value in
                        faceAnimationViewRepresentable?.setColor(selectedTab == .chat ? UIColor(Colors.elementBackgroundColor) : UIColor(Colors.elementTextColor))
                    })
//                        .tint(selectedTab == .chat ? Colors.elementBackgroundColor : Colors.elementTextColor)
                    .frame(width: faceFrameDiameter, height: faceFrameDiameter)
            }
            .onTapGesture {
                // If not selected set the selectedTab to chat, otherwise set pushToLatestConversationOrClose to true
                if selectedTab != .chat {
                    withAnimation(.none) {
                        self.selectedTab = .chat
                    }
                } else {
                    pushToLatestConversationOrClose = true
                }
            }
        }
    }
    
    var essayButton: some View {
        ZStack {
            Button(action: {
                withAnimation(.none) {
                    self.selectedTab = .essay
                }
            }) {
                VStack {
                    Spacer()
                    
                    Image(selectedTab == .essay ? Constants.ImageName.BottomBarImages.essayBottomButtonSelected : Constants.ImageName.BottomBarImages.essayBottomButtonNotSelected)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Colors.elementTextColor)
                }
            }
        }
    }
    
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
//    VStack {
//        Spacer()
        
        TabBar(
            premiumUpdater: PremiumUpdater(),
            remainingUpdater: RemainingUpdater())
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    }
//    .ignoresSafeArea()
}
