//
//  GameViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

//import Foundation
//
//@MainActor
//class GameViewModel: ObservableObject {
//    @Published var currentQuestion: Driver?
//    @Published var choices: [Driver] = []
//    @Published var score = 0
//    @Published var message = "Guess the driver?"
//    
//    // We pass in the drivers already loaded from the F1Service
//    func setupNewQuestion(allDrivers: [Driver]) {
//        guard allDrivers.count >= 4 else { return }
//        
//        // 1. Pick a random correct answer
//        let correct = allDrivers.randomElement()!
//        self.currentQuestion = correct
//        
//        // 2. Pick 3 other random drivers for decoys
//        var options = allDrivers.filter { $0.id != correct.id }.shuffled().prefix(3)
//        options.append(correct)
//        
//        // 3. Shuffle the final 4 choices
//        self.choices = options.shuffled()
//        self.message = "Who drives for \(correct.team_name)?"
//    }
//    
//    func checkAnswer(_ selected: Driver, allDrivers: [Driver]) {
//        if selected.id == currentQuestion?.id {
//            score += 1
//            message = "Correct! That's \(selected.full_name)!"
//            // Small delay before next question
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                self.setupNewQuestion(allDrivers: allDrivers)
//            }
//        } else {
//            message = "Wrong! Try again."
//            score = max(0, score - 1)
//        }
//    }
//}

import Foundation
import Combine
//
//@MainActor
//class GameViewModel: ObservableObject {
//    // 1. Added default values to prevent initializer errors
//    @Published var currentQuestion: Driver? = nil
//    @Published var choices: [Driver] = []
//    @Published var score: Int = 0
//    @Published var message: String = "Can you name this driver?"
//    
//    // 2. Explicitly added an empty initializer to make it available to SwiftUI
//    init() {}
//
//    func setupNewQuestion(allDrivers: [Driver]) {
//        // Ensure we have enough drivers to actually play a game
//        guard allDrivers.count >= 4 else {
//            self.message = "Loading the grid..."
//            return
//        }
//        
//        let correct = allDrivers.randomElement()!
//        self.currentQuestion = correct
//        
//        // Filter out the correct driver so they don't appear twice in the choices
//        var options = allDrivers.filter { $0.id != correct.id }.shuffled().prefix(3)
//        options.append(correct)
//        
//        self.choices = options.shuffled()
//        self.message = "Who drives for \(correct.team_name)?"
//    }
//    
//    func checkAnswer(_ selected: Driver, allDrivers: [Driver]) {
//        guard let current = currentQuestion else { return }
//        
//        if selected.id == current.id {
//            score += 1
//            message = "Correct!"
//            
//            // Short delay so the user can see they were right
//            Task {
//                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
//                setupNewQuestion(allDrivers: allDrivers)
//            }
//        } else {
//            message = "Wrong! Try again."
//            // Simple penalty
//            if score > 0 { score -= 1 }
//        }
//    }
//}


import SwiftUI

enum QuestionType: CaseIterable {
    case identifyName      // "Who drives for Ferrari?"
    case identifyByColor   // (Shows team color) "Which team uses this color?"
}

@MainActor
class GameViewModel: ObservableObject {
    @Published var currentQuestion: Driver? = nil
    @Published var choices: [Driver] = []
    @Published var score: Int = 0
    @Published var message: String = ""
    @Published var questionType: QuestionType = .identifyName // New!
    
    init() {}

    func setupNewQuestion(allDrivers: [Driver]) {
        guard allDrivers.count >= 4 else { return }
        
        // 1. Pick a random type and a random driver
        self.questionType = QuestionType.allCases.randomElement()!
        let correct = allDrivers.randomElement()!
        self.currentQuestion = correct
        
        // 2. Set the message based on the type
        switch questionType {
        case .identifyName:
            message = "Who drives for \(correct.team_name)?"
        case .identifyByColor:
            message = "Which team's colors are these?"
        }
        
        // 3. Prepare shuffled choices
        var options = allDrivers.filter { $0.id != correct.id }.shuffled().prefix(3)
        options.append(correct)
        self.choices = options.shuffled()
    }
    
    func checkAnswer(_ selected: Driver, allDrivers: [Driver]) {
        guard let current = currentQuestion else { return }
        
        if selected.id == current.id {
            score += 1
            message = "Correct! 🏎️"
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                setupNewQuestion(allDrivers: allDrivers)
            }
        } else {
            message = "Not quite! Try again."
            if score > 0 { score -= 1 }
        }
    }
}
