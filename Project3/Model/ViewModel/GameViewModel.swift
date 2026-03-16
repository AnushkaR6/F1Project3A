//
//  GameViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//


import Foundation
import Combine

// Types of questions for game
enum QuestionType: CaseIterable {
    case identifyName // Guessing driver by team
    case identifyByColor // Guessing team by team color
}

// managing game logic and state
@MainActor
class GameViewModel: ObservableObject {
    // Game state vars to update UI
    @Published var currentQuestion: Driver? = nil // Driver being guessed
    @Published var choices: [Driver] = [] // answer choices
    @Published var score: Int = 0 // Tracking score
    @Published var message: String = "" // Text messages
    @Published var questionType: QuestionType = .identifyName

    // Creating new question
    func setupNewQuestion(allDrivers: [Driver]) {
        guard allDrivers.count >= 4 else { return }
        
        // Randomizing questions
        self.questionType = QuestionType.allCases.randomElement()!
        let correct = allDrivers.randomElement()!
        self.currentQuestion = correct
        
        // Creatint prompt based on question type
        switch questionType {
        case .identifyName:
            message = "Who drives for \(correct.team_name)?"
        case .identifyByColor:
            message = "Which team's colors are these?"
        }
        
        // 4 answer choices shuffled
        var options = allDrivers.filter { $0.id != correct.id }.shuffled().prefix(3)
        options.append(correct)
        self.choices = options.shuffled()
    }
    
    // Verifying if selection matches correct answer
    func checkAnswer(_ selected: Driver, allDrivers: [Driver]) {
        guard let current = currentQuestion else { return }
        // Selection is correct
        if selected.id == current.id {
            score += 1
            message = "Correct! 🏎️"
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                setupNewQuestion(allDrivers: allDrivers)
            }
            // Selection is incorrect
        } else {
            message = "Not quite! Try again."
            if score > 0 { score -= 1 }
        }
    }
}
