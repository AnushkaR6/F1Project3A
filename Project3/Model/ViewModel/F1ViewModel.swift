//
//  F1ViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

import Foundation
import Combine
import SwiftUI
import Supabase

// Structures for database communication
private struct BookmarkRecord: Decodable {
    let driver_id: Int
}

private struct BookmarkInsert: Encodable {
    let user_id: UUID
    let driver_id: Int
}

@MainActor
class F1ViewModel: ObservableObject {
    @Published var allDrivers: [Driver] = []
    @Published var drivers: [Driver] = [] // This will hold the "Master List" the user sees
//    @Published var bookmarkedDrivers; [Driver] = []
    @Published var isLoading = false
    
    private let service = F1Service()
    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    /// Loads all drivers from the API and then checks for user bookmarks
    func loadDrivers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedDrivers = try await service.fetchDrivers()
            self.allDrivers = fetchedDrivers
            
            // Show all drivers by default so the screen isn't white
            self.drivers = fetchedDrivers
            
            // Then try to sync bookmarks in the background
            await fetchBookmarks()
        } catch {
            print("Error fetching F1 data: \(error)")
        }
    }
    
//    func loadDrivers() async {
//            do {
//                let allDrivers: [Driver] = try await supabase
//                    .from("drivers")
//                    .select("*")
//                    .execute()
//                    .value
//                self.drivers = allDrivers
//            } catch {
//                print("Error loading drivers: \(error)")
//            }
//        }
//    }
    
    /// Fetches saved driver IDs to sync state (Scoping Logic)
    private func fetchBookmarks() async {
        // Use currentUser for a safer session check
        guard let userId = supabase.auth.currentUser?.id else { return }
        
        do {
            let bookmarks: [BookmarkRecord] = try await supabase
                .from("bookmarks")
                .select("driver_id")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            // Note: If you want the main list to ONLY show bookmarks,
            // uncomment the line below. Otherwise, keep it showing allDrivers.
             let bookmarkedIDs = bookmarks.map(\.driver_id)
             self.drivers = allDrivers.filter { bookmarkedIDs.contains($0.id) }
            
        } catch {
            print("Error fetching bookmarks: \(error)")
        }
    }

    var availableDrivers: [Driver] {
        let selectedIDs = Set(drivers.map { $0.id })
        return allDrivers.filter { !selectedIDs.contains($0.id) }
    }

    func isDriverSelected(_ driver: Driver) -> Bool {
        drivers.contains(where: { $0.id == driver.id })
    }

//    /// Saves a driver to the backend for the current user
//    func addDriver(_ driver: Driver) {
//        guard !drivers.contains(where: { $0.id == driver.id }) else { return }
//        
//        guard let userId = supabase.auth.currentUser?.id else {
//            print("Login required to add drivers")
//            return
//        }
//        
//        Task {
//            do {
//                try await supabase
//                    .from("bookmarks")
//                    .insert(BookmarkInsert(user_id: userId, driver_id: driver.id))
//                    .execute()
//                
//                // Only add to local list if backend succeeds
//                self.drivers.append(driver)
//            } catch {
//                print("Failed to save bookmark: \(error)")
//            }
//        }
//    }
    
    func addDriver(_ driver: Driver) {
        guard !drivers.contains(where: { $0.id == driver.id }) else { return }
        
        // Use currentUser for the most reliable ID access
        guard let userId = supabase.auth.currentUser?.id else { return }
        
        Task {
            do {
                try await supabase
                    .from("bookmarks")
                    .insert(BookmarkInsert(user_id: userId, driver_id: driver.id))
                    .execute()
                
                self.drivers.append(driver)
            } catch {
                print("Failed to save bookmark: \(error)")
            }
        }
    }

    /// Removes a driver from the backend for the current user
    func removeDrivers(at offsets: IndexSet) {
        let driversToRemove = offsets.map { drivers[$0] }
        guard let userId = supabase.auth.currentUser?.id else { return }
        
        Task {
            for driver in driversToRemove {
                do {
                    try await supabase
                        .from("bookmarks")
                        .delete()
                        .eq("user_id", value: userId.uuidString)
                        .eq("driver_id", value: driver.id)
                        .execute()
                } catch {
                    print("Failed to remove bookmark: \(error)")
                }
            }
            drivers.remove(atOffsets: offsets)
        }
    }
    
    /// Wipes data on logout to prevent "Ghost Data"
    func clearData() {
        self.drivers = []
        self.allDrivers = []
    }
}

// Preview provider for SwiftUI Canvas
extension F1ViewModel {
    static var preview: F1ViewModel {
        let mockClient = SupabaseClient(supabaseURL: URL(string: "https://x.co")!, supabaseKey: "key")
        let vm = F1ViewModel(supabase: mockClient)
        vm.allDrivers = [
            Driver(driver_number: 1, full_name: "Max Verstappen", name_acronym: "VER", team_name: "Red Bull", team_colour: "3671C6", headshot_url: nil)
        ]
        vm.drivers = vm.allDrivers
        return vm
    }
}

//import Foundation
//import Combine
//import SwiftUI
//import Supabase // Added: Import your backend SDK
//
//private struct BookmarkRecord: Decodable {
//    let driver_id: Int
//}
//
//private struct BookmarkInsert: Encodable {
//    let user_id: UUID
//    let driver_id: Int
//}
//
//@MainActor
//class F1ViewModel: ObservableObject {
//    @Published private(set) var allDrivers: [Driver] = []
//    @Published var drivers: [Driver] = []
//    @Published var isLoading = false
//    
//    private let service = F1Service()
//    private let supabase: SupabaseClient // Added: Reference to backend
//
//    // Updated: Pass the supabase client in the initializer
//    init(supabase: SupabaseClient) {
//        self.supabase = supabase
//    }
//
////    func loadDrivers() async {
////        isLoading = true
////        defer { isLoading = false }
////        
////        do {
////            // 1. Fetch the public data from OpenF1 API (The "Master List")
////            let fetchedDrivers = try await service.fetchDrivers()
////            self.allDrivers = fetchedDrivers
////            
////            // 2. IMPORTANT: Default 'drivers' to the full list so the UI isn't empty
////            // until the user starts customizing it.
////            if self.drivers.isEmpty {
////                self.drivers = fetchedDrivers
////            }
////            
////            // 3. Try to fetch bookmarks from Supabase to sync the "selected" state
////            try? await fetchBookmarks()
////            
////        } catch {
////            print("Error fetching F1 data: \(error)")
////        }
////    }
//    
//    func loadDrivers() async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            // 1. Fetch the master list from the OpenF1 API
//            let fetchedDrivers = try await service.fetchDrivers()
//            self.allDrivers = fetchedDrivers
//            
//            // 2. Default the 'drivers' list to the full fetched list
//            // so the screen isn't empty on the first login.
//            self.drivers = fetchedDrivers
//            
//            // 3. Sync with Supabase bookmarks
//            // This will let you know which ones the user has "saved"
//            try? await fetchBookmarks()
//            
//        } catch {
//            print("Error fetching F1 data: \(error)")
//        }
//    }
//    
//    // NEW: Fetches saved driver IDs from the backend and filters the list
//    private func fetchBookmarks() async throws {
//        // Requirement: Logic scoped to the logged-in user
//        let userId = try await supabase.auth.session.user.id
//        
//        // Query the 'bookmarks' table for this user
//        let bookmarks: [BookmarkRecord] = try await supabase
//            .from("bookmarks")
//            .select("driver_id")
//            .eq("user_id", value: userId)
//            .execute()
//            .value
//        
//        // Update the 'drivers' array to only include what is in the backend
//        let bookmarkedIDs = bookmarks.map(\.driver_id)
//        self.drivers = allDrivers.filter { bookmarkedIDs.contains($0.id) }
//    }
//
//    var availableDrivers: [Driver] {
//        let selectedIDs = Set(drivers.map { $0.id })
//        return allDrivers.filter { !selectedIDs.contains($0.id) }
//    }
//
//    func isDriverSelected(_ driver: Driver) -> Bool {
//        drivers.contains(where: { $0.id == driver.id })
//    }
//
//    func addDriver(_ driver: Driver) {
//        guard !drivers.contains(where: { $0.id == driver.id }) else { return }
//        
//        // Use the current user from the existing session
//        guard let userId = supabase.auth.currentUser?.id else {
//            print("No active user session found")
//            return
//        }
//        
//        Task {
//            do {
//                try await supabase
//                    .from("bookmarks")
//                    .insert(BookmarkInsert(user_id: userId, driver_id: driver.id))
//                    .execute()
//                
//                // Update local UI
//                self.drivers.append(driver)
//            } catch {
//                print("Failed to save bookmark: \(error)")
//            }
//        }
//    }
//    
////    // UPDATED: Save to backend when adding
////    func addDriver(_ driver: Driver) {
////        guard !drivers.contains(where: { $0.id == driver.id }) else { return }
////        
////        Task {
////            do {
////                let userId = try await supabase.auth.session.user.id
////                
////                // Insert into Supabase 'bookmarks' table
////                try await supabase
////                    .from("bookmarks")
////                    .insert(BookmarkInsert(user_id: userId, driver_id: driver.id))
////                    .execute()
////                
////                // Update local UI only after backend success
////                self.drivers.append(driver)
////            } catch {
////                print("Failed to save bookmark: \(error)")
////            }
////        }
////    }
//
//    // UPDATED: Remove from backend when deleting
//    func removeDrivers(at offsets: IndexSet) {
//        let driversToRemove = offsets.map { drivers[$0] }
//        
//        Task {
//            for driver in driversToRemove {
//                do {
//                    let userId = try await supabase.auth.session.user.id
//                    
//                    try await supabase
//                        .from("bookmarks")
//                        .delete()
//                        .eq("user_id", value: userId)
//                        .eq("driver_id", value: driver.id)
//                        .execute()
//                } catch {
//                    print("Failed to remove bookmark: \(error)")
//                }
//            }
//            // Update local UI
//            drivers.remove(atOffsets: offsets)
//        }
//    }
//    
//    // NEW: Clears data on logout to ensure no session conflation
//    func clearData() {
//        self.drivers = []
//    }
//}
//
//// This extension restores the 'preview' property that the SwiftUI Canvas looks for
//extension F1ViewModel {
//    static var preview: F1ViewModel {
//        // Create a dummy client just for the preview environment
//        let mockClient = SupabaseClient(supabaseURL: URL(string: "https://example.supabase.co")!, supabaseKey: "mock-key")
//        let vm = F1ViewModel(supabase: mockClient)
//        
//        // Provide some sample data so the preview isn't empty
//        let previewDrivers = [
//            Driver(driver_number: 1, full_name: "Max Verstappen", name_acronym: "VER", team_name: "Red Bull Racing", team_colour: "3671C6", headshot_url: nil),
//            Driver(driver_number: 44, full_name: "Lewis Hamilton", name_acronym: "HAM", team_name: "Mercedes", team_colour: "27F4D2", headshot_url: nil)
//        ]
//        
//        vm.allDrivers = previewDrivers
//        vm.drivers = previewDrivers
//        return vm
//    }
//}
