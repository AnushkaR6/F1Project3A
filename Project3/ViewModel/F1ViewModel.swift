//
//  F1ViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//


import Foundation
import Combine
import SwiftUI

// Fetching F1 drivers list
@MainActor
class F1ViewModel: ObservableObject {
    // Storing data
    @Published private(set) var allDrivers: [Driver] = [] // All drivers list
    @Published var drivers: [Driver] = [] // User selection
    @Published var isLoading = false
    
    // API networking service
    private let service = F1Service()

    // Fetching driver data from API
    func loadDrivers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let fetchedDrivers = try await service.fetchDrivers()
            self.allDrivers = fetchedDrivers
            self.drivers = fetchedDrivers
        } catch {
            // Message to confirm error
            print("Error fetching F1 data: \(error)")
        }
    }

    // Returning drivers not in the user list
    var availableDrivers: [Driver] {
        let selectedIDs = Set(drivers.map { $0.id })
        return allDrivers.filter { !selectedIDs.contains($0.id) }
    }

    // Verify if driver is already in list
    func isDriverSelected(_ driver: Driver) -> Bool {
        drivers.contains(where: { $0.id == driver.id })
    }

    // Adding driver to collection
    func addDriver(_ driver: Driver) {
        guard !drivers.contains(where: { $0.id == driver.id }) else { return }
        drivers.append(driver)
    }

    // Removing drivers using swipe action
    func removeDrivers(at offsets: IndexSet) {
        drivers.remove(atOffsets: offsets)
    }
}

// Sample dummy code for testing
extension F1ViewModel {
    static var preview: F1ViewModel {
        let vm = F1ViewModel()
        let previewDrivers = [
            Driver(driver_number: 1, full_name: "Max Verstappen", name_acronym: "VER", team_name: "Red Bull Racing", team_colour: "3671C6", headshot_url: "https://api.openf1.org/images/drivers/1.png"),
            Driver(driver_number: 23, full_name: "Alexander Albon", name_acronym: "ALB", team_name: "Williams", team_colour: "00A0DE", headshot_url: "https://api.openf1.org/images/drivers/23.png")
        ]
        vm.allDrivers = previewDrivers
        vm.drivers = previewDrivers
        return vm
    }
}
