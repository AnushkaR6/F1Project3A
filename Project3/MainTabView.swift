//
//  MainTabView.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

import SwiftUI

struct MainTabView: View {
    // 1. Create the shared source of truth
    @StateObject var f1VM = F1ViewModel()

    var body: some View {
        TabView {
            // Tab 1: Driver List
            ContentView()
                .tabItem {
                    Label("Drivers", systemImage: "car.fill")
                }
            
            // Tab 2: Trivia Game
            // 2. Pass the shared f1VM into the GameView
            GameView(f1VM: f1VM)
                .tabItem {
                    Label("Trivia", systemImage: "questionmark.circle.fill")
                }
        }
        // 3. Kick off the data fetch the moment the TabView exists
        .task {
            if f1VM.drivers.isEmpty {
                await f1VM.loadDrivers()
            }
        }
    }
}

#Preview {
    MainTabView()
}
