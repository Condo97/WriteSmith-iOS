////
////  TypewriterLegacy.swift
////  ChitChat
////
////  Created by Alex Coundouriotis on 3/20/23.
////
//
//import Foundation
//
//class TypewriterLegacy: Any {
//
//    private var toTypeString: String
//    var typingString: String
//
//    private var timeInterval: Double
//    private var typingUpdateLetterCount: Int
//
//    private var prevCharacter: Character?
//
//    private lazy var timer: DispatchSourceTimer = {
//        let t = DispatchSource.makeTimerSource()
//        t.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
//        t.setEventHandler(handler: timerTick)
//
//        return t
//    }()
//
//    var updateBlock: (TypewriterLegacy, String)->Void = { typewriter, completedText in }
//
//    @discardableResult
//    static func start(text: String, timeInterval: Double, typingUpdateLetterCount: Int, block: @escaping (TypewriterLegacy, String)->Void) -> TypewriterLegacy {
//        let typewriter = TypewriterLegacy(toTypeString: text, timeInterval: timeInterval, typingUpdateLetterCount: typingUpdateLetterCount)
//        typewriter.resume()
//        typewriter.updateBlock = block
//        typewriter.typingUpdateLetterCount = typingUpdateLetterCount
//
//        return typewriter
//    }
//
//    private init(toTypeString: String, timeInterval: Double, typingUpdateLetterCount: Int) {
//        self.toTypeString = String(toTypeString.reversed()) // Reverse it so we can popLast for O(1) efficiency and have it ordered correctly
//        self.timeInterval = timeInterval
//        self.typingUpdateLetterCount = typingUpdateLetterCount
//
//        typingString = ""
//    }
//
//    deinit {
//        timer.setEventHandler(handler: {})
//        timer.cancel()
//        timer.resume() // If timer is suspended resume must be called after cancel per documentation https://medium.com/over-engineering/a-background-repeating-timer-in-swift-412cecfd2ef9 - https://forums.developer.apple.com/thread/15902
//    }
//
//
//    private enum State {
//        case suspended
//        case resumed
//    }
//
//    private var state: State = .suspended
//
//    func resume() {
//        if state == .resumed {
//            return
//        }
//
//        state = .resumed
//        timer.resume()
//    }
//
//    func suspend() {
//        if state == .suspended {
//            return
//        }
//
//        state = .suspended
//        timer.suspend()
//    }
//
//    func isValid() -> Bool {
//        return state == .resumed
//    }
//
//
//    private func timerTick() {
//        if toTypeString.count <= 0 {
//            suspend()
//        } else {
//            for i in 0..<typingUpdateLetterCount {
//                if let toTypeCharacter = toTypeString.popLast() {
//                    typingString.append(toTypeCharacter)
//
//                    // Stop the loop if there is a \n as it would expand the TableViewCell too fast otherwise
//                    if toTypeCharacter.isNewline {
//                        break
//                    }
//
//                    prevCharacter = toTypeCharacter
//                }
//            }
//        }
//
//        updateBlock(self, typingString)
//    }
//}
