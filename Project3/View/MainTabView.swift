//
//  MainTabView.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

// Main view for app

//import SwiftUI
//import Supabase
//
//struct MainTabView: View {
//    // Shared point for info
//    @StateObject private var f1VM = F1ViewModel()
//    @StateObject private var appVM = AppViewModel()
//
//    var body: some View {
//        TabView {
//            // Creating collection/list of drivers w/ profile pics
//            ContentView(viewModel: f1VM)
//                .tabItem {
//                    // Labeling first tab for all drivers
//                    Label("Drivers", systemImage: "car.fill")
//                }
//            
//            // Adding posting view
//            PostFeedView(viewModel: appVM)
//                .tabItem { Label("Feed", systemImage: "photo.stack") }
//            
//            // Passing the shared f1VM into this view
//            GameView(f1VM: f1VM)
//                .tabItem {
//                    // Labeling second tab view for trivia game
//                    Label("Trivia", systemImage: "questionmark.circle.fill")
//                }
//        }
//        // Starting data fetch once TabView exists (also vibe coded so I'm looking
//        // more into the use cases and pros/cons of .task)
//        .task {
//            if f1VM.drivers.isEmpty {
//                await f1VM.loadDrivers()
//            }
//        }
//    }
//}
//
//#Preview {
//    MainTabView()
//}

import SwiftUI
import Supabase

struct MainTabView: View {
    // 1. Get the AuthViewModel from the environment (passed from @main)
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // 2. Change these to be initialized in the init() below
    @StateObject private var f1VM: F1ViewModel
    @StateObject private var appVM: AppViewModel

    // 3. Add an initializer that accepts the supabase client
    init(supabase: SupabaseClient) {
        // We use the underscore _f1VM to initialize the StateObject itself
        _f1VM = StateObject(wrappedValue: F1ViewModel(supabase: supabase))
        _appVM = StateObject(wrappedValue: AppViewModel(supabase: supabase))
    }

    var body: some View {
        TabView {
            // Drivers Collection Tab
            ContentView(viewModel: f1VM)
                .tabItem {
                    Label("Drivers", systemImage: "car.fill")
                }
            
            // Photo Feed Tab
            // Note: Updated to pass the appVM instance to match your PostFeedView init
            PostFeedView(viewModel: appVM, f1VM: f1VM)
                .tabItem {
                    Label("Feed", systemImage: "photo.stack")
                }
            
            // Trivia Game Tab
            GameView(f1VM: f1VM)
                .tabItem {
                    Label("Trivia", systemImage: "questionmark.circle.fill")
                }
        }
        .task {
            // Load drivers from both OpenF1 and Supabase when the app starts
            if f1VM.drivers.isEmpty {
                await f1VM.loadDrivers()
            }
        }
        .task {
            // Load drivers
            if f1VM.drivers.isEmpty {
                await f1VM.loadDrivers()
            }
            
            // NEW: Load the feed posts so they appear after login
            await appVM.fetchPosts()
        }
        .task {
            if f1VM.drivers.isEmpty {
                await f1VM.loadDrivers()
            }
            // Added: Load persistent posts on login
            await appVM.fetchPosts()
        }
    }
}

// Update the preview to fix the error there as well
#Preview {
    // Create a mock client for the preview canvas
    let mockClient = SupabaseClient(supabaseURL: URL(string: "https://x.co")!, supabaseKey: "key")
    return MainTabView(supabase: mockClient)
        .environmentObject(AuthViewModel(client: mockClient))
}
