//
//  GameViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

import Foundation
import Combine
import SwiftUI

enum QuestionType: CaseIterable {
    case identifyName      // For specific driver info
    case identifyByColor   // For team color info
}

@MainActor
class GameViewModel: ObservableObject {
    // property wrapper for variables to indicate changes
    @Published var currentQuestion: Driver? = nil
    @Published var choices: [Driver] = []
    @Published var score: Int = 0
    @Published var message: String = ""
    @Published var questionType: QuestionType = .identifyName // New!
    
    // init() {}

    // creating new questions
    func setupNewQuestion(allDrivers: [Driver]) {
        guard allDrivers.count >= 4 else { return }
        
        // randomizing the question type and drivers using driver list from API
        self.questionType = QuestionType.allCases.randomElement()!
        let correct = allDrivers.randomElement()!
        self.currentQuestion = correct
        
        // 2 Main question types: guess driver or guess team based on color
        switch questionType {
        case .identifyName:
            message = "Who drives for \(correct.team_name)?"
        case .identifyByColor:
            message = "Which team's colors are these?"
        }
        
        // Randomizing the 4 answer choices
        var options = allDrivers.filter { $0.id != correct.id }.shuffled().prefix(3)
        options.append(correct)
        self.choices = options.shuffled()
    }
    
    // Validating user input to determine if it's correct
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
