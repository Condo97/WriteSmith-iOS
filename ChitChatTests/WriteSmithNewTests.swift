//
//  WriteSmithNewTests.swift
//  ChitChatTests
//
//  Created by Alex Coundouriotis on 3/20/23.
//

import XCTest
@testable import ChitChat

final class WriteSmithNewTests: XCTestCase {
    
    // Test the typewriter class
    func testTypewriter() throws {
        let text = "this is some text"
        let t = Typewriter.start(text: text, timeInterval: 1.0, block: { typewriter, compltedText in
            
        })
        
        let group = DispatchGroup()
        
        group.enter()
        
        let block: (Typewriter, String)->Void = { typewriter, completedText in
            if !typewriter.isValid() {
                group.leave()
            }
            
            print(completedText)
        }
        
        t.updateBlock = block
        
        group.wait()
    }
    
    // Test misc stuff
    func testMisc() throws {
        
    }
}
