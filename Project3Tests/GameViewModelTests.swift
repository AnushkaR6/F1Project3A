//
//  GameViewModelTests.swift
//  Project3Tests
//
//  Created by Anushka R on 3/15/26.
//

import Testing
import Foundation
@testable import Project3

@MainActor
struct GameViewModelTests {
    
    /// Simulating API data for testing
    private func createMockDrivers(count: Int) -> [Driver] {
        return (1...count).map { i in
            Driver(
                driver_number: i,
                full_name: "Driver \(i)",
                name_acronym: "D\(i)",
                team_name: "Team \(i)",
                team_colour: "000000",
                headshot_url: nil
            )
        }
    }

    // Logic testing
    @Test("Verify that a valid question state is created with sufficient data")
    func testSetupNewQuestion() async {
        let viewModel = GameViewModel()
        let drivers = createMockDrivers(count: 10)
        
        viewModel.setupNewQuestion(allDrivers: drivers)
        
        // Check that target driver was actually selected
        #expect(viewModel.currentQuestion != nil, "A question should be generated when provided with enough drivers.")
        
        // Check that 4 choices arae given for each question
        #expect(viewModel.choices.count == 4, "The game requires exactly 4 options to be displayed.")
        
        // Check that correct answer is always included in choices
        let correctID = viewModel.currentQuestion?.id
        #expect(viewModel.choices.contains(where: { $0.id == correctID }), "The correct answer must be one of the four choices.")
    }

    @Test("Verify score increases correctly on a right answer")
    func testCheckAnswerCorrect() async {
        let viewModel = GameViewModel()
        let drivers = createMockDrivers(count: 5)
        
        // Manually triggering question setup
        viewModel.setupNewQuestion(allDrivers: drivers)
        let initialScore = viewModel.score
        let correctAnswer = viewModel.currentQuestion!
        
        // Act: Provide the correct answer
        viewModel.checkAnswer(correctAnswer, allDrivers: drivers)
        
        // Assert: Score should increment and message should be positive
        #expect(viewModel.score == initialScore + 1, "The score should increase by 1 for a correct answer.")
        #expect(viewModel.message == "Correct! 🏎️")
    }

    @Test("Verify score decreases on a wrong answer and never goes below zero")
    func testCheckAnswerIncorrect() async {
        let viewModel = GameViewModel()
        let drivers = createMockDrivers(count: 5)
        viewModel.setupNewQuestion(allDrivers: drivers)
        
        // Seting initial score to 1
        viewModel.score = 1
        
        // Finding driver that isn't the correct answer
        let wrongAnswer = drivers.first(where: { $0.id != viewModel.currentQuestion?.id })!
        
        // Act: Provide the wrong answer
        viewModel.checkAnswer(wrongAnswer, allDrivers: drivers)
        
        // Assert: Score should decrease
        #expect(viewModel.score == 0, "Score should decrease by 1 for an incorrect answer.")
        
        // Act again: Provide another wrong answer
        viewModel.checkAnswer(wrongAnswer, allDrivers: drivers)
        
        // Assert: Score should stay at 0, never goes into negative
        #expect(viewModel.score == 0, "Score should never drop below zero.")
        #expect(viewModel.message == "Not quite! Try again.")
    }

    @Test("Verify that setup fails gracefully when not enough drivers are provided")
    func testSetupWithInsufficientData() async {
        let viewModel = GameViewModel()
        let drivers = createMockDrivers(count: 3) // Less than the 4 required
        
        viewModel.setupNewQuestion(allDrivers: drivers)
        
        #expect(viewModel.currentQuestion == nil, "ViewModel should not set a question if there aren't enough drivers to fill choices.")
    }
}
