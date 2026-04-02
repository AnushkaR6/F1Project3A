//
//  GameView.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

import SwiftUI
import AVFoundation
import Combine

struct GameView: View {
    @ObservedObject var f1VM: F1ViewModel // To pass data
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var audioPlayer = GameAudioPlayer()
    
    var body: some View {
        VStack(spacing: 25) {
            headerSection
            
            if let driver = gameVM.currentQuestion {
                // DYNAMIC QUESTION AREA
                VStack(spacing: 20) {
                    questionVisual(for: driver)
                    
                    Text(gameVM.message)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(height: 250)

                // Buttons to show choices for answer
                VStack(spacing: 12) {
                    ForEach(gameVM.choices) { choice in
                        // FIX: Explicitly passing f1VM.drivers ensures the next question can be generated
                        Button(action: { gameVM.checkAnswer(choice, allDrivers: f1VM.drivers) }) {
                            Text(gameVM.questionType == .identifyByColor ? choice.team_name : choice.full_name)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                ProgressView("Preparing the Grid...")
                    .padding()
            }
            Spacer()
        }
        .task {
            // Requirement: Persistence - Initial data check
            if !f1VM.drivers.isEmpty && gameVM.currentQuestion == nil {
                gameVM.setupNewQuestion(allDrivers: f1VM.drivers)
            }
        }
        // Watch for data updates to solve the loading delay
        .onChange(of: f1VM.drivers) { oldValue, newValue in
            if !newValue.isEmpty && gameVM.currentQuestion == nil {
                gameVM.setupNewQuestion(allDrivers: newValue)
            }
        }
        .onAppear { audioPlayer.start() }
        .onDisappear { audioPlayer.stop() }
    }
    
    @ViewBuilder
    func questionVisual(for driver: Driver) -> some View {
        switch gameVM.questionType {
        case .identifyName:
            Text("\(driver.driver_number)")
                .font(.system(size: 80, weight: .black))
                .foregroundColor(.white)
                .frame(width: 150, height: 150)
                .background(Color(hex: driver.team_colour))
                .clipShape(RoundedRectangle(cornerRadius: 20))

        case .identifyByColor:
            Circle()
                .fill(Color(hex: driver.team_colour))
                .frame(width: 120, height: 120)
                .shadow(radius: 10)
        }
    }

    var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("F1 TRIVIA").font(.caption).bold().foregroundColor(.red)
                Text("Score: \(gameVM.score)").font(.title.bold())
            }
            Spacer()
            Button("Skip") {
                if !f1VM.drivers.isEmpty {
                    gameVM.setupNewQuestion(allDrivers: f1VM.drivers)
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

@MainActor
private final class GameAudioPlayer: ObservableObject {
    private var player: AVAudioPlayer?

    func start() {
        guard player == nil else {
            player?.play()
            return
        }
        
        guard let url = Bundle.main.url(forResource: "F1Audio", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true, options: [])
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1
            newPlayer.prepareToPlay()
            newPlayer.play()
            player = newPlayer
        } catch {
            print("Audio Player Error: \(error)")
        }
    }
    
    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [])
    }
}

#Preview {
    GameView(f1VM: F1ViewModel.preview)
}

//import SwiftUI
//import AVFoundation
//import Combine
//
//struct GameView: View {
//    @ObservedObject var f1VM: F1ViewModel // To pass data
//    @StateObject private var gameVM = GameViewModel()
//    @StateObject private var audioPlayer = GameAudioPlayer()
//    
//    var body: some View {
//        // vertically stacking the questions and answers
//        VStack(spacing: 25) {
//            headerSection
//            
//            // Question types and setting up pair so that question
//            // matches correct answer
//            if let driver = gameVM.currentQuestion {
//                // DYNAMIC QUESTION AREA
//                VStack(spacing: 20) {
//                    questionVisual(for: driver)
//                    
//                    Text(gameVM.message)
//                        .font(.title3.bold())
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                }
//                .frame(height: 250)
//
//                // Buttons to show choices for answer
//                VStack(spacing: 12) {
//                    ForEach(gameVM.choices) { choice in
//                        Button(action: { gameVM.checkAnswer(choice, allDrivers: f1VM.drivers) }) {
//                            // If it's a team color question, show Team Name.
//                            // Otherwise, show Driver Name.
//                            Text(gameVM.questionType == .identifyByColor ? choice.team_name : choice.full_name)
//                                .fontWeight(.bold)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.secondary.opacity(0.1))
//                                .cornerRadius(12)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            } else {
//                // Shows if drivers haven't loaded or currentQuestion is nil
//                ProgressView("Preparing the Grid...")
//                    .padding()
//            }
//            Spacer()
//        }
//        // 1. Initial check when the view appears
//        .task {
//            if !f1VM.drivers.isEmpty && gameVM.currentQuestion == nil {
//                gameVM.setupNewQuestion(allDrivers: f1VM.drivers)
//            }
//        }
//        // 2. NEW: Watch for data updates to solve the loading delay
//        .onChange(of: f1VM.drivers) { _, newDrivers in
//            if !newDrivers.isEmpty && gameVM.currentQuestion == nil {
//                gameVM.setupNewQuestion(allDrivers: newDrivers)
//            }
//        }
//        .onAppear { audioPlayer.start() }
//        .onDisappear { audioPlayer.stop() }
//    }
//    
//    // Helper to decide what to show in the middle
//    @ViewBuilder
//    func questionVisual(for driver: Driver) -> some View {
//        switch gameVM.questionType {
//        case .identifyName:
//            // Big Team Badge style
//            Text("\(driver.driver_number)")
//                .font(.system(size: 80, weight: .black))
//                .foregroundColor(.white)
//                .frame(width: 150, height: 150)
//                .background(Color(hex: driver.team_colour))
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//
//        case .identifyByColor:
//            // For team colors
//            Circle()
//                .fill(Color(hex: driver.team_colour))
//                .frame(width: 120, height: 120)
//                .shadow(radius: 10)
//        }
//    }
//
//    // Creating a label for the game view on screen
//    var headerSection: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("F1 TRIVIA").font(.caption).bold().foregroundColor(.red)
//                Text("Score: \(gameVM.score)").font(.title.bold())
//            }
//            Spacer()
//            // Adding more standard trivia features like skip
//            Button("Skip") {
//                if !f1VM.drivers.isEmpty {
//                    gameVM.setupNewQuestion(allDrivers: f1VM.drivers)
//                }
//            }
//            .buttonStyle(.bordered)
//        }
//        .padding()
//    }
//}
//
//@MainActor
//// adding F1 Audio for media interactivity when game is being played
//private final class GameAudioPlayer: ObservableObject {
//    private var player: AVAudioPlayer?
//
//    func start() {
//        guard player == nil else {
//            player?.play()
//            return
//        }
//        let fileName = "F1Audio"
//        let fileExtension = "mp3"
//
//        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
//            print("Audio file not found") // Added debug print
//            return
//        }
//
//        do {
//            let session = AVAudioSession.sharedInstance()
//            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
//            try session.setActive(true, options: [])
//            let newPlayer = try AVAudioPlayer(contentsOf: url)
//            newPlayer.numberOfLoops = -1
//            newPlayer.prepareToPlay()
//            newPlayer.play()
//            player = newPlayer
//        } catch {
//            print("Audio Player Error: \(error)")
//            return
//        }
//    }
//    
//    func stop() {
//        player?.stop()
//        player = nil
//        try? AVAudioSession.sharedInstance().setActive(false, options: [])
//    }
//}
//
//#Preview {
//    GameView(f1VM: F1ViewModel.preview)
//}
