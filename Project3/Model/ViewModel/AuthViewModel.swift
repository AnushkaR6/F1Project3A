//
//  AuthViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/30/26.
//

import Foundation
import Combine
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var authError: String?
    
    // Tracks the current session. If this is not nil, the user is logged in.
    @Published var session: Session?
    
    let client: SupabaseClient
    
    // Initialize with your Supabase Client
    init(client: SupabaseClient) {
        self.client = client
        
        // Listen for auth state changes (e.g., automatic login on app restart)
        Task {
            for await (event, session) in client.auth.authStateChanges {
                if event == .signedIn || event == .initialSession {
                    self.session = session
                } else if event == .signedOut {
                    self.session = nil
                }
            }
        }
    }
    
    // MARK: - Public Actions
    
//    /// Logic for creating a new account
//    func signUp() async {
//        guard validateInputs() else { return }
//        
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            try await client.auth.signUp(email: email, password: password)
//            authError = nil
//        } catch {
//            authError = error.localizedDescription
//        }
//    }
    
    func signUp() async {
        guard validateInputs() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Create the user
            let response = try await client.auth.signUp(email: email, password: password)
            
            // Manually update the session if it was returned in the response
            // This ensures Project3App's 'if session != nil' check triggers immediately
            if let session = response.session {
                self.session = session
            }
            
            authError = nil
        } catch {
            authError = error.localizedDescription
        }
    }
    
    /// Logic for logging into an existing account
    func signIn() async {
        guard validateInputs() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await client.auth.signIn(email: email, password: password)
            authError = nil
        } catch {
            authError = "Invalid email or password."
        }
    }
    
    /// Logic for logging out and clearing the session
    func signOut(f1VM: F1ViewModel) async { // Accept the VM as a parameter
        isLoading = true
        do {
            try await client.auth.signOut()
            
            // CRITICAL: Wipe the drivers list immediately
            f1VM.clearData()
            
            self.session = nil
            email = ""
            password = ""
        } catch {
            authError = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Private Helpers
    
    private func validateInputs() -> Bool {
        if email.isEmpty || password.isEmpty {
            authError = "Please fill in all fields."
            return false
        }
        if password.count < 6 {
            authError = "Password must be at least 6 characters."
            return false
        }
        return true
    }
}
