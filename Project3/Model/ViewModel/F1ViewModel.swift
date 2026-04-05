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
    @Published var bookmarkedDrivers: [Driver] = []
    @Published var isLoading = false
    
    private let service = F1Service()
    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    // Loads all drivers from the API and then checks for user bookmarks
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
//            isLoading = true
//            defer { isLoading = false }
//            
//            do {
//                // 1. Fetch from the 'drivers' table in Supabase
//                let fetched: [Driver] = try await supabase
//                    .from("drivers")
//                    .select("*")
//                    .execute()
//                    .value
//                
//                // 2. Set both lists so the game has data immediately
//                self.allDrivers = fetched
//                self.drivers = fetched
//                
//                // 3. Sync bookmarks without overwriting the main list
//                await fetchBookmarks()
//            } catch {
//                print("Error loading drivers: \(error)")
//            }
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
