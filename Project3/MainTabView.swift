//
//  MainTabView.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

// Main view for app

import SwiftUI

struct MainTabView: View {
    // Shared point for info
    @StateObject var f1VM = F1ViewModel()

    var body: some View {
        TabView {
            // Creating collection/list of drivers w/ profile pics
            ContentView()
                .tabItem {
                    // Labeling first tab for all drivers
                    Label("Drivers", systemImage: "car.fill")
                }
            
            // Adding posting view
            PostFeedView()
                .tabItem { Label("Feed", systemImage: "photo.stack") }
            
            // Passing the shared f1VM into this view
            GameView(f1VM: f1VM)
                .tabItem {
                    // Labeling second tab view for trivia game
                    Label("Trivia", systemImage: "questionmark.circle.fill")
                }
        }
        // Starting data fetch once TabView exists (also vibe coded so I'm looking
        // more into the use cases and pros/cons of .task)
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
