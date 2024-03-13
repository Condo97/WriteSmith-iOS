//
//  SuggestionsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/3/24.
//

import Foundation
import SwiftUI

// Load with some chats, or it can pull them itself
// It can have one boolean that triggers it to hide and show, but when it shows it will always load... so like, isActive or something
// So when isPresented is false, it will just hide it, then when isActive is true it will get the suggestions from the server using the current chats and then display them when it is ready
// TODO: Allow for more suggestions to be loaded, using "Different Than" in the GenerateSuggestionsRequest

struct SuggestionsView: View {
    
    @Binding var isActive: Bool
    @Binding var selected: String
    @Binding var conversation: Conversation
    
    
    private let numberOfChatsToIncludeInRequest: Int = 3
    private let numberOfSuggestionsToLoad: Int = 5
    
    @FetchRequest<Chat> var chats: FetchedResults<Chat>
    
    @Environment(\.managedObjectContext) var managedContext
    
    
//    (
//        sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: false)]
//        predicate: <#T##NSPredicate?#>
//    )
//    private var chats
    
    
//    @State private var isPresented: Bool = false
    @State private var suggestions: [String] = []
    
    
    init(isActive: Binding<Bool>, selected: Binding<String>, conversation: Binding<Conversation>) {
        self._chats = FetchRequest<Chat>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: false)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.wrappedValue.objectID),
            animation: .default)
        
        self._conversation = conversation
        self._isActive = isActive
        self._selected = selected
    }
    
    var body: some View {
        // Should show up automatically if suggestions is not empty and isPresented is true, and not show if suggestions is empty OR isPresented is false meaning it will not show if isPresented is true but suggestions is empty or vice versa
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: {
                        // Set selected to suggestion
                        selected = suggestion
                    }) {
                        Text(suggestion)
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            .foregroundStyle(Colors.text)
                    }
                    .padding([.leading, .trailing], 6)
                    .padding(6)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            }
            .padding([.leading, .trailing])
        }
        .onChange(of: isActive, perform: { value in
            if value {
                // If isActive, clear suggestions, dismiss, and load new ones
                suggestions = []
//                isPresented = false
                
                Task {
                    do {
                        suggestions = try await generateSuggestions()
                    } catch {
                        print("Error generating suggestions in SuggestionsView... \(error)")
                    }
                }
            } else {
                // If not isActive, clear suggestions and dismiss
                suggestions = []
//                isPresented = false
            }
        })
    }
    
    func generateSuggestions() async throws -> [String] {
        // Ensure there is at least one chat, otherwise return
        guard chats.count > 0 else {
            return []
        }
        
        // Get numberOfChatsToIncludeInRequestInRange as chats count or numberOfChatsToIncludeInRequest, whichever is less
        let numberOfChatsToIncludeInRequestInRange = min(chats.count, numberOfChatsToIncludeInRequest)
        
        // Transform the chats array to a string array of the numberOfChatsToIncludeInRequest most recent chat content
        let chatStrings = chats[0..<numberOfChatsToIncludeInRequestInRange].compactMap({ s in s.text})
        
        // Ensure and unwrap authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            print("Error ensuring authToken in SuggestionsView... \(error)")
            throw error
        }
        
        // Create generateSuggestionsRequest
        let generateSuggestionsRequest = GenerateSuggestionsRequest(
            authToken: authToken,
            conversation: chatStrings,
            count: numberOfSuggestionsToLoad)
        
        // Get generateSuggestionsResponse from server
        let generateSuggestionsResponse: GenerateSuggestionsResponse
        do {
            generateSuggestionsResponse = try await HTTPSConnector.generateSuggestions(request: generateSuggestionsRequest)
        } catch {
            print("Error getting GenerateSuggestionsResponse from server in SuggestionsView... \(error)")
            throw error
        }
        
        // Return suggestions from generaetSuggestionsResponse
        return generateSuggestionsResponse.body.suggestions
    }
    
}

#Preview {
    
    struct TestView: View {
        
        @State private var isActive: Bool = false
        @State private var selected: String = ""
        
        @State private var conversation: Conversation
        
//        let fetchRequest = FetchRequest<Chat>(
//            sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: false)]
//        )
        
        init() {
            self.conversation = Conversation(context: CDClient.mainManagedObjectContext)
            
            try? CDClient.mainManagedObjectContext.save()
        }
        
        var body: some View {
            VStack {
                Spacer()
                
                VStack {
                    SuggestionsView(
                        isActive: $isActive,
                        selected: $selected,
                        conversation: .constant(conversation)
                    )
                    .background(.white)
                    
                    Text("Tap Me")
                }
                .background(.gray)
                
                Spacer()
            }
            .onTapGesture {
                isActive.toggle()
                
                print(isActive)
            }
            .onChange(of: selected, perform: { value in
                print(value ?? "")
            })
        }
        
    }
    
    return TestView()
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        .background(Color.blue)
    
}
