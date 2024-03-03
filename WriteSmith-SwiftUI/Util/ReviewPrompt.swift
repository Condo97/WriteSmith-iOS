//
//  ReviewPrompt.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import Foundation
import SwiftUI

// Show a "Do not Show Again" after 2 "no"s
// Don't show again after 3 "no"s
// Don't show do you like WriteSmith just request review after 1 "yes"

struct ReviewPrompt: View {
    
    @Binding var isPresented: Bool
    
    
    private static let likeCount_Key = "likeCount_ReviewManager"
    private static let dislikeCount_Key = "dislikeCount_ReviewManager"
    private static let stopAsking_Key = "stopShowing_ReviewManager"
    
    private let showStopShowingAfterDislikeCount = 2
    
    private let showReviewImmediatelyAfterLikeOdds = 3
    
    
    @Environment(\.requestReview) private var requestReview
    
    @State private var isShowingRequestReview: Bool = false
    @State private var isShowingSubmitFeedback: Bool = false
    
    static var likeCount: Int {
        get {
            UserDefaults.standard.integer(forKey: likeCount_Key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: likeCount_Key)
        }
    }
    
    static var dislikeCount: Int {
        get {
            UserDefaults.standard.integer(forKey: dislikeCount_Key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dislikeCount_Key)
        }
    }
    
    static var stopShowing: Bool {
        get {
            UserDefaults.standard.bool(forKey: stopAsking_Key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: stopAsking_Key)
        }
    }
    
    var body: some View {
        ZStack {
            FeedbackAlert(isPresented: $isShowingSubmitFeedback)
        }
        .onChange(of: isPresented, perform: { value in
            if ReviewPrompt.stopShowing {
                // Shouldn't show, so cancel presentation
                isPresented = false
            } else {
                if ReviewPrompt.likeCount > 0 {
                    // Already likes it, so just show the review request. This may trigger if the user says "yes" they like WriteSmith but does not review the app the first time
                    requestReview()
                } else {
                    // Does not like it but should show, so ask again if the user likes it or not. This may happen because the user has never seen this message as like WriteSmith will be defaulted to false, or maybe if the user does not like WriteSmith but did not submit feedback
                    isShowingRequestReview = true
                }
            }
        })
        .alert("WriteSmith Feedback", isPresented: $isShowingRequestReview, actions: {
            Button("Yes", action: {
                // Increment likeCount and requestReview.. only requesting the review after this in a 1/3 chance if likeCount is <= 1 andalways if likeCount is > 1 (since it adds one before) though this should not happen since the user has indicated they like the app so the review should just show directly instead of the are you liking the app screen :D :) :O
                ReviewPrompt.likeCount += 1
                
                if ReviewPrompt.likeCount > 1 {
                    // Shouldn't be called ever becuase the review prmopt popup wouldn't show if the user tapped they like the app and it would have directly gone to review, but here it is as a redundancy :)
                    requestReview()
                } else {
                    if Int.random(in: 0..<showReviewImmediatelyAfterLikeOdds) == 0 {
                        // Request the review in a 1 / showReviewImmediatelyAfterLikeOdds chance !
                        requestReview()
                    }
                }
                    
            })
            
            Button("No", role: .cancel, action: {
                // Increment dislikeCount and show feedback
                ReviewPrompt.dislikeCount += 1
                
                isShowingSubmitFeedback = true
            })
            
            if ReviewPrompt.dislikeCount >= 2 {
                Button("Do Not Show Again", action: {
                    ReviewPrompt.stopShowing = true
                })
            }
        }) {
            Text("How are you enjoying WriteSmith?")
        }
        
    }
    
}


//@available(iOS 17.0, *)
#Preview {
    
    struct TestView: View {
        
        @State var isPresented = false
        
        var body: some View {
            ReviewPrompt(isPresented: $isPresented)
                .onAppear {
//                    ReviewManager.likeCount = 0
//                    ReviewManager.dislikeCount = 0
                    
                    isPresented = true
                }
                .onChange(of: isPresented, perform: { value in
                    if !value {
                        Task {
                            try await Task.sleep(nanoseconds:1_000_000*2)
                            
                            isPresented = true
                        }
                    }
                })
        }
    }
    
    return TestView()
    
}
