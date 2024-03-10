//
//  HTTPSConnector.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

class HTTPSConnector {
    
    static func deleteChat(request: DeleteChatRequest) async throws -> StatusResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.deleteChat)")!,
            body: request,
            headers: nil)
        
        let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
        
        return statusResponse
    }
    
    static func registerUser() async throws -> RegisterUserResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.registerUser)")!,
            body: BlankRequest(),
            headers: nil)
        
        do {
            let registerUserResponse = try JSONDecoder().decode(RegisterUserResponse.self, from: data)
            
            return registerUserResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    static func generateSuggestions(request: GenerateSuggestionsRequest) async throws -> GenerateSuggestionsResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.generateSuggestions)")!,
            body: request,
            headers: nil)
        
        do {
            let generateSuggestionsResponse = try JSONDecoder().decode(GenerateSuggestionsResponse.self, from: data)
            
            return generateSuggestionsResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    static func getIsPremium(request: AuthRequest) async throws -> IsPremiumResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getIsPremium)")!,
            body: request,
            headers: nil)
        
        do {
            let isPremiumResponse = try JSONDecoder().decode(IsPremiumResponse.self, from: data)
            
            return isPremiumResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    static func getRemaining(request: AuthRequest) async throws -> GetRemainingResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getRemaining)")!,
            body: request,
            headers: nil)
        
        do {
            let getRemainingResponse = try JSONDecoder().decode(GetRemainingResponse.self, from: data)
            
            return getRemainingResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    static func getImportantConstants() async throws -> GetImportantConstantsResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getImportantConstants)")!,
            body: BlankRequest(),
            headers: nil)
        
        do {
            let getImportantConstantsResponse = try JSONDecoder().decode(GetImportantConstantsResponse.self, from: data)
            
            return getImportantConstantsResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    static func submitFeedback(request: SubmitFeedbackRequest) async throws -> StatusResponse {
        let (data, respnose) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.submitFeedback)")!,
            body: request,
            headers: nil)
        
        do {
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            return statusResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    static func validateAuthToken(request: AuthRequest) async throws -> StatusResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.validateAuthToken)")!,
            body: request,
            headers: nil)
        
        let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
        
        return statusResponse
    }
    
    
    
    // MARK: - Legacy
    
    // TODO: Legacy so need to delete
    static func registerUser(completion: @escaping (RegisterUserResponse)->Void) {
        do {
            try HTTPSClient.post(
                url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.registerUser)")!,
                body: BlankRequest(),
                headers: nil,
                completion: {data, error in
                    if let error = error {
                        print("Error registering user")
                        print(error)
                    } else if let data = data {
                        do {
                            // Try decoding to RegisterUserResponse
                            let registerUserResponse = try JSONDecoder().decode(RegisterUserResponse.self, from: data)
                            
                            // Call completion block
                            completion(registerUserResponse)
                        } catch {
                            print("Error decoding to RegisterUserResponse")
                            print(error.localizedDescription)
                        }
                    }
                }
            )
        } catch {
            print("Error making POST request in registerUser")
            print(error.localizedDescription)
        }
    }
    
    static func getChat(request: GetChatRequest, completion: @escaping (GetChatResponse)->Void) {
        do {
            try HTTPSClient.post(
                url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getChat)")!,
                body: request,
                headers: nil,
                completion: {data, error in
                    if let error = error {
                        print("Error getting chat")
                        print(error)
                    } else if let data = data {
                        do {
                            // Try decoding to GetChatResponse
                            let getChatResponse = try JSONDecoder().decode(GetChatResponse.self, from: data)
                            
                            // Call completion block
                            completion(getChatResponse)
                        } catch {
                            print("Error decoding to GetChatResponse")
                            print(error.localizedDescription)
                        }
                    }
                }
            )
        } catch {
            print("Error making POST request in getChat")
            print(error.localizedDescription)
        }
    }
    
    // TODO: Legacy need to delete
    static func getRemaining(request: AuthRequest, completion: @escaping (GetRemainingResponse)->Void) {
        do {
            try HTTPSClient.post(
                url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getRemaining)")!,
                body: request,
                headers: nil,
                completion: {data, error in
                    if let error = error {
                        print("Error getting remaining")
                        print(error.localizedDescription)
                    } else if let data = data {
                        do {
                            // Try decoding to GetRemainingResponse
                            let getRemainingResponse = try JSONDecoder().decode(GetRemainingResponse.self, from: data)
                            
                            // Call completion block
                            completion(getRemainingResponse)
                        } catch {
                            print("Error decoding to GetRemainingResponse")
                            print(error.localizedDescription)
                        }
                    }
                }
            )
        } catch {
            print("Error making POST request in getRemaining")
            print(error.localizedDescription)
        }
    }
    
    static func getImportantConstants(completion: @escaping (GetImportantConstantsResponse)->Void) {
        do {
            try HTTPSClient.post(
                url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getImportantConstants)")!,
                body: BlankRequest(),
                headers: nil,
                completion: {data, error in
                    if let error = error {
                        print("Error getting important constants")
                        print(error.localizedDescription)
                    } else if let data = data {
                        do {
                            // Try decoding to GetImportantConstantsResponse
                            let getImportantConstantsResponse = try JSONDecoder().decode(GetImportantConstantsResponse.self, from: data)
                            
                            // Call completion block
                            completion(getImportantConstantsResponse)
                        } catch {
                            print("Error decoding to GetImportantConstantsResponse")
                            print(error.localizedDescription)
                        }
                    }
                }
            )
        } catch {
            print("Error making POST request in getImportantConstants")
            print(error.localizedDescription)
        }
    }
    
    static func getIAPStuff(completion: @escaping (GetIAPStuffResponse)->Void) {
        do {
            try HTTPSClient.post(
                url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getIAPStuff)")!,
                body: BlankRequest(),
                headers: nil,
                completion: {data, error in
                    if let error = error {
                        print("Error getting IAP stuff")
                        print(error.localizedDescription)
                    } else if let data = data {
                        do {
                            // Try decoding to GetIAPStuffResponse
                            let getIAPStuffResponse = try JSONDecoder().decode(GetIAPStuffResponse.self, from: data)
                            
                            // Call completion block
                            completion(getIAPStuffResponse)
                        } catch {
                            print("Error decoding to GetIAPStuffResponse")
                            print(error.localizedDescription)
                        }
                    }
                }
            )
        } catch {
            print("Error making POST requet in getIAPStuff")
            print(error.localizedDescription)
        }
    }
    
}
