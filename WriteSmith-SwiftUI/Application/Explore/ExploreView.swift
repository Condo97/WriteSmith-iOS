//
//  ExploreView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct ExploreView: View {
    
    @ObservedObject var premiumUpdater: PremiumUpdater
    @ObservedObject var remainingUpdater: RemainingUpdater
    @State var panelGroups: [PanelGroup]
    
    
    @Namespace private var namespace
    
    @State private var selectedSection: String = allSectionFilter
    
    @State private var presentingPanel: Panel?
    
    @State private var isShowingSettingsView: Bool = false
    
    private let panelSize = CGSize(width: 170.0, height: 120.0)
    private let selectedSectionUnderlineMatchedGeometryEffectID = "selectedSectionUnderline"
    private static let allSectionFilter = "All"
    private let allSectionFilter = ExploreView.allSectionFilter
    
    private var sections: [String] {
        [allSectionFilter] + panelGroups.map({$0.name})
    }
    
    private var isShowingPresentingPanelView: Binding<Bool> {
        Binding(
            get: {
                presentingPanel != nil
            },
            set: { newValue in
                if !newValue {
                    presentingPanel = nil
                }
            })
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                if !premiumUpdater.isPremium {
                    BannerView(bannerID: Keys.Ads.Banner.exploreView)
                }
                
                filterDisplay
                
                if selectedSection == allSectionFilter {
                    sectionedPanelsDisplay
                } else {
                    filteredPanelsDisplay
                }
            }
        }
        .background(Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            SettingsToolbarItem(
                elementColor: .constant(Colors.elementTextColor),
                placement: .topBarLeading,
                tightenLeadingSpacing: true,
                tightenTrailingSpacing: true,
                action: {
                isShowingSettingsView = true
            })
            
            ShareToolbarItem(
                elementColor: .constant(Colors.elementTextColor),
                placement: .topBarLeading,
                tightenLeadingSpacing: true)
            
            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
            
            if !premiumUpdater.isPremium {
                UltraToolbarItem(
                    premiumUpdater: premiumUpdater,
                    remainingUpdater: remainingUpdater)
            }
        }
        .toolbarBackground(Colors.topBarBackgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingSettingsView, destination: {
            SettingsView(premiumUpdater: premiumUpdater)
        })
        .navigationDestination(isPresented: isShowingPresentingPanelView, destination: {
            if let presentingPanel = presentingPanel {
                PanelView(
                    premiumUpdater: premiumUpdater,
                    remainingUpdater: remainingUpdater,
                    panel: presentingPanel)
            }
        })
    }
    
    var filterDisplay: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(sections, id: \.self) { section in
                    ZStack {
                        KeyboardDismissingButton(action: {
                            // Do light haptic
                            HapticHelper.doLightHaptic()
                            
                            withAnimation {
                                // Set selected section to section
                                selectedSection = section
                            }
                        }) {
                            Text(section)
                                .font(.custom(selectedSection == section ? Constants.FontName.black : Constants.FontName.body, size: 17.0))
                                .animation(.easeInOut(duration: 0.0))
                        }
                        .foregroundStyle(Colors.textOnBackgroundColor)
                    }
                    .padding([.top, .bottom], 16)
                    .padding([.leading, .trailing], 8)
                    .background(
                        VStack {
                            Spacer()
                            
                            if selectedSection == section {
                                Rectangle()
                                    .frame(height: 2.0)
                                    .matchedGeometryEffect(id: selectedSectionUnderlineMatchedGeometryEffectID, in: namespace)
                            }
                        }
                    )
                }
            }
            .padding([.leading, .trailing])
        }
    }
    
    var sectionedPanelsDisplay: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8.0) {
                ForEach(panelGroups) { panelGroup in
                    Text(panelGroup.name)
                        .font(.custom(Constants.FontName.black, size: 24.0))
                        .padding(.top, 8)
                        .padding([.leading, .trailing])
                        .foregroundStyle(Colors.textOnBackgroundColor)
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(panelGroup.panels) { panel in
                                KeyboardDismissingButton(action: {
                                    // Do light haptic
                                    HapticHelper.doLightHaptic()
                                    
                                    // Set presentingPanel to panel
                                    presentingPanel = panel
                                }) {
                                    PanelMiniView(
                                        imageName: panel.imageName,
                                        emoji: panel.emoji,
                                        title: panel.title,
                                        description: panel.description)
                                }
                                .foregroundStyle(Colors.text)
                                .frame(width: panelSize.width, height: panelSize.height)
//                                .bounceable()
                            }
                        }
                        .padding([.leading, .trailing])
                    }
                    .scrollIndicators(.never)
                }
            }
            
            Spacer(minLength: 140.0)
        }
        .scrollIndicators(.never)
    }
    
    var filteredPanelsDisplay: some View {
        ScrollView(.vertical) {
            if let selectedPanelGroup = panelGroups.first(where: {$0.name == selectedSection}) {
                LazyVStack(alignment: .leading) {
                    Text(selectedPanelGroup.name)
                        .font(.custom(Constants.FontName.black, size: 24.0))
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8.0) {
                        ForEach(selectedPanelGroup.panels) { panel in
                            KeyboardDismissingButton(action: {
                                // Do light haptic
                                HapticHelper.doLightHaptic()
                                
                                // Set presentingPanel to panel
                                presentingPanel = panel
                            }) {
                                PanelMiniView(
                                    emoji: panel.emoji,
                                    title: panel.title,
                                    description: panel.description)
                            }
                            .foregroundStyle(Colors.text)
                            .frame(width: panelSize.width, height: panelSize.height)
                            .bounceable()
                        }
                    }
                }
                .padding()
            }
            
            Spacer(minLength: 140.0)
        }
    }
    
}

#Preview {
    NavigationStack {
        ExploreView(
            premiumUpdater: PremiumUpdater(),
            remainingUpdater: RemainingUpdater(),
            panelGroups: try! PanelParser.parsePanelGroups(fromJson: PanelPersistenceManager.get()!)!)
        .toolbar {
            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
        }
        .toolbarBackground(Colors.topBarBackgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}
