//
//  Project3App.swift
//  Project3
//
//  Created by Anushka R on 3/7/26.
//

import SwiftUI
import Supabase

//@main
//struct Project3App: App {
//    var body: some Scene {
//        WindowGroup {
//            // Changes this instead of ContentView() because the main page is MainTabView()
//            MainTabView()
//        }
//    }
//}

import SwiftUI
import Supabase

@main
struct Project3App: App {
    // 1. Keep the property but don't initialize it here
    let supabase: SupabaseClient
    @StateObject var authViewModel: AuthViewModel
    
    init() {
        // 2. Initialize the client
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://uawlvuoakvdlzwjrzrfn.supabase.co")!,
            supabaseKey: "sb_publishable_2CWSXyD0xh-yhE4CqkaW9A_NR_RJauc"
        )
        self.supabase = client
        
        // 3. Initialize the ViewModel with that same client
        _authViewModel = StateObject(wrappedValue: AuthViewModel(client: client))
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.session != nil {
                    // Passes the shared client and injects authViewModel into the environment
                    MainTabView(supabase: supabase)
                        .environmentObject(authViewModel)
                } else {
                    LoginView(viewModel: authViewModel)
                }
            }
            .onAppear {
            }
        }
    }
}
