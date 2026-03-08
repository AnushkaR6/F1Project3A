//
//  F1ViewModel.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor // Ensures UI updates always happen on the main thread
class F1ViewModel: ObservableObject {
    @Published private(set) var allDrivers: [Driver] = []
    @Published var drivers: [Driver] = []
    @Published var isLoading = false
    
    private let service = F1Service()

    func loadDrivers() async {
        isLoading = true
        defer { isLoading = false } // Runs when the function finishes
        
        do {
            let fetchedDrivers = try await service.fetchDrivers()
            self.allDrivers = fetchedDrivers
            self.drivers = fetchedDrivers
        } catch {
            print("Error fetching F1 data: \(error)")
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
        drivers.append(driver)
    }

    func removeDrivers(at offsets: IndexSet) {
        drivers.remove(atOffsets: offsets)
    }
}

extension F1ViewModel {
    static var preview: F1ViewModel {
        let vm = F1ViewModel()
        let previewDrivers = [
            Driver(driver_number: 1, full_name: "Max Verstappen", name_acronym: "VER", team_name: "Red Bull Racing", team_colour: "3671C6", headshot_url: "https://api.openf1.org/images/drivers/1.png"),
            Driver(driver_number: 23, full_name: "Alexander Albon", name_acronym: "ALB", team_name: "Williams", team_colour: "00A0DE", headshot_url: "https://api.openf1.org/images/drivers/23.png"),
            Driver(driver_number: 4, full_name: "Lando Norris", name_acronym: "NOR", team_name: "McLaren", team_colour: "FF8000", headshot_url: "https://api.openf1.org/images/drivers/4.png"),
            Driver(driver_number: 16, full_name: "Charles Leclerc", name_acronym: "LEC", team_name: "Ferrari", team_colour: "E80020", headshot_url: "https://api.openf1.org/images/drivers/16.png")
        ]
        vm.allDrivers = previewDrivers
        vm.drivers = previewDrivers
        return vm
    }
}
