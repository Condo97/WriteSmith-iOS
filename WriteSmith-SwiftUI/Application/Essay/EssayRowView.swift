//
//  EssayRowView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/25/23.
//

import SwiftUI

struct EssayRowView: View {
    
    @ObservedObject var essay: Essay
    var isGenerating: Bool
    @Binding var isExpanded: Bool
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var editedText: String = ""
    
    @State private var copyButtonCopyState: CopyStates = .copy
    
    private enum CopyStates: String {
        case copy = "Copy"
        case copied = "Copied"
    }
    
    private let copyButtonAnimationDuration = 1.0
    
    @State private var alertShowingConfirmDeleteEssay: Bool = false
    @State private var alertShowingDiscardChanges: Bool = false
    
    private var hasEdits: Bool {
        editedText != essay.editedEssay
    }
    
    private var formattedEssayWithPromptForCopyingAndSharing: String? {
        guard let prompt = essay.prompt, let essay = essay.essay else {
            // TODO: Handle errors
            return nil
        }
        
        // Return prompt with essay and footer text if not premium on a new line
        return prompt + "\n" + essay + (premiumUpdater.isPremium ? "" : "\n\n" + Constants.copyFooterText)
    }
    
    init(essay: Essay, isGenerating: Bool, isExpanded: Binding<Bool>) {
        self.essay = essay
        self.isGenerating = isGenerating
        self._isExpanded = isExpanded
        
        // If editedEssay is nil or empty, set to essay
        if essay.editedEssay == nil || essay.editedEssay!.isEmpty {
            // Set editedEssay to essay
            essay.editedEssay = essay.essay
            
            // Save view context
            do {
                try viewContext.save()
            } catch {
                // TODO: Handle errors
                print("Error saving edited essay when initializing EssayRowView... \(error)")
            }
        }
        
        // Set editedText to editedEssay
//        self.editedText = essay.editedEssay ?? ""
        self._editedText = State(initialValue: essay.editedEssay ?? "")
    }
    
    var body: some View {
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm a"
            
            return dateFormatter
        }()
        ZStack {
            ZStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(essay.prompt ?? "Missing Prompt")
                                .font(.custom(essay.prompt == nil ? Constants.FontName.bodyOblique : Constants.FontName.body, size: 20.0))
                            Text(essay.date == nil ? "" : "\(dateFormatter.string(from: essay.date!))")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                                .opacity(0.4)
                        }
                        
                        Spacer()
                        
                        // Copy Button
                        KeyboardDismissingButton(action: {
                            // Do light haptic
                            HapticHelper.doLightHaptic()
                            
                            // Unwrap prompt, otherwise return if nil
                            guard let prompt = essay.prompt else {
                                // TODO: Handle errors
                                return
                            }
                            
                            // Copy prompt with footer if not premium
                            PasteboardHelper.copy(formattedEssayWithPromptForCopyingAndSharing ?? "")
                            
                            // Do little "copied" animation for copy button
                            withAnimation {
                                copyButtonCopyState = .copied
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + copyButtonAnimationDuration, execute: {
                                withAnimation {
                                    copyButtonCopyState = .copy
                                }
                            })
                        }) {
                            Text(copyButtonCopyState == .copied ? "Copied" : "\(Image(systemName: "square.on.square.dashed"))")
                                .font(.custom(Constants.FontName.body, size: copyButtonCopyState == .copied ? 17.0 : 22.0))
                        }
                        .foregroundStyle(colorScheme == .dark ? Colors.elementTextColor : Colors.elementBackgroundColor)
                        .disabled(formattedEssayWithPromptForCopyingAndSharing == nil)
                        .opacity(formattedEssayWithPromptForCopyingAndSharing == nil ? 0.4 : 1.0)
                        
                        // Share Button
                        ShareLink(item: formattedEssayWithPromptForCopyingAndSharing ?? "") {
                            Text(Image(systemName: "square.and.arrow.up"))
                                .font(.custom(Constants.FontName.body, size: 22.0))
                        }
                        .foregroundStyle(colorScheme == .dark ? Colors.elementTextColor : Colors.elementBackgroundColor)
                        .disabled(formattedEssayWithPromptForCopyingAndSharing == nil)
                        .opacity(formattedEssayWithPromptForCopyingAndSharing == nil ? 0.4 : 1.0)
                        
                        // Delete Button
                        if premiumUpdater.isPremium {
                            KeyboardDismissingButton(action: {
                                // Do warning haptic
                                HapticHelper.doWarningHaptic()
                                
                                // Show alert to confirm delete essay
                                alertShowingConfirmDeleteEssay = true
                            }) {
                                Text(Image(systemName: "trash"))
                                    .font(.custom(Constants.FontName.body, size: 22.0))
                            }
                            .foregroundStyle(colorScheme == .dark ? Colors.elementTextColor : Colors.elementBackgroundColor)
                            .alert("Delete Essay", isPresented: $alertShowingConfirmDeleteEssay, actions: {
                                Button("Cancel", role: .cancel, action: {
                                    
                                })
                                
                                Button("Delete", role: .destructive, action: {
                                    viewContext.delete(essay)
                                    
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        // TODO: Handle errors
                                        print("Error saving viewContext after deleting essay in EssayRowView... \(error)")
                                    }
                                })
                            })
                        }
                    }
                    
                    if hasEdits && !isGenerating {
                        HStack {
                            KeyboardDismissingButton(action: {
                                // Do warning haptic
                                HapticHelper.doWarningHaptic()
                                
                                // Show discard changes alert
                                alertShowingDiscardChanges = true
                            }) {
                                Spacer()
                                Text("Cancel")
                                    .font(.custom(Constants.FontName.body, size: 17.0))
                                Spacer()
                            }
                            .padding(8)
                            .foregroundStyle(Colors.buttonBackground)
                            .background(
                                ZStack {
                                    let cornerRadius = UIConstants.cornerRadius
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(Colors.buttonBackground, lineWidth: 2.0)
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .fill(Colors.elementTextColor)
                                }
                            )
                            
                            KeyboardDismissingButton(action: {
                                // Do success haptic
                                HapticHelper.doSuccessHaptic()
                                
                                // Save changes
                                saveChanges()
                                
                                // Dismiss keyboard
                                KeyboardDismisser.dismiss()
                            }) {
                                Spacer()
                                Text("Save")
                                    .font(.custom(Constants.FontName.black, size: 17.0))
                                Spacer()
                            }
                            .padding(8)
                            .foregroundStyle(Colors.elementTextColor)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                                        .fill(Colors.buttonBackground)
                                }
                            )
                        }
                    }
                    
                    HStack {
                        TextField("", text: $editedText, axis: .vertical)
                            .textFieldTickerTint(Colors.text)
                            .dismissOnReturn()
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            .disabled(!isExpanded || isGenerating)
                        
                        Spacer()
                    }
                    .foregroundStyle(Colors.text)
                }
                .padding(.bottom, isExpanded ? 80 : 40)
            }
            
            VStack(spacing: 0.0) {
                Spacer()
                
                if !isExpanded {
                    LinearGradient(colors: [Colors.foreground, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 20.0)
                }
                
                KeyboardDismissingButton(action: {
                    // If is exapnded and has edits show discard changes alert, otherwise toggle isExpanded
                    if hasEdits && isExpanded && !isGenerating {
                        // Do warning haptic
                        HapticHelper.doWarningHaptic()
                        
                        // Show discard changes alert
                        alertShowingDiscardChanges = true
                    } else {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Toggle isExpanded
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(isExpanded ? "Show Less" : "Show More...")
                            .font(.custom(isExpanded ? Constants.FontName.body: Constants.FontName.heavy, size: 17.0))
                        Spacer()
                    }
                    .foregroundStyle(Colors.text)
                    .opacity(isExpanded && hasEdits ? 0.4 : 1.0)
                }
                .background(Colors.foreground)
            }
        }
        .padding([.top, .bottom], 4)
        .padding([.leading, .trailing])
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .frame(maxHeight: isExpanded ? .infinity : 140.0)
        .padding([.leading, .trailing])
        .alert("Unsaved Changes", isPresented: $alertShowingDiscardChanges, actions: {
            Button("Discard", role: .destructive, action: {
                discardChanges()
            })
            
            Button("Save", role: nil, action: {
                saveChanges()
            })
        }) {
            Text("There are unsaved changes in your essay. Discard or save?")
        }
        .onChange(of: essay.editedEssay) { editedEssay in
            self.editedText = editedEssay ?? ""
        }
        
        //        Text("Test")
    }
    
    func discardChanges() {
        // Set editedText to essay essayEdited
        editedText = essay.editedEssay ?? ""
    }
    
    func saveChanges() {
        // Set essay editedEssay to editedText
        essay.editedEssay = editedText
        
        // Save essay
        do {
            try viewContext.save()
        } catch {
            // TODO: Handle errors
            print("Error saving edited essay in EssayRowView... \(error)")
        }
    }
    
    
}

#Preview {
    
    var essay = Essay(context: CDClient.mainManagedObjectContext)
    
    essay.prompt = "This is the prompt"
    essay.essay = "This is the essay"
    essay.editedEssay = "This is the edited essay\nasdf\nasdf\n\nasdf"
    essay.date = Date()
    
    try? CDClient.mainManagedObjectContext.save()
    
    struct ContentView: View {
        
        @State var isExpanded: Bool = false
        var essay: Essay
        
        
        var body: some View {
            EssayRowView(
                essay: essay,
                isGenerating: true,
                isExpanded: $isExpanded)
            .background(Colors.background)
            .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        }
    }
    
    return ScrollView {
        ContentView(essay: essay)
            .environmentObject(PremiumUpdater())
            .environmentObject(ProductUpdater())
    }
}
