//
//  F1ViewModelTests.swift
//  Project3Tests
//
//  Created by Anushka R on 3/16/26.
//

import Testing
import Foundation
@testable import Project3


// Making sure the F1 API and user selection stay synced
@MainActor
struct F1ViewModelTests {

    // Generating a dummy driver
    private func createDriver(id: Int, name: String) -> Driver {
        Driver(
            driver_number: id,
            full_name: name,
            name_acronym: String(name.prefix(3)).uppercased(),
            team_name: "Test Team",
            team_colour: "000000",
            headshot_url: nil
        )
    }

    @Test("Verify that availableDrivers correctly filters out drivers already in the user's list")
    func testAvailableDriversFiltering() {
        let viewModel = F1ViewModel.preview
        
        let driverA = viewModel.allDrivers[0]
        let driverB = viewModel.allDrivers[1]
        
        // Scenario: The API gives 2 drivers, but user already chose 1
        viewModel.drivers = [driverA]
        
        // Assert: The 'available' list only contain the driver NOT selected
        #expect(viewModel.availableDrivers.count == 1, "Should only show drivers not already selected.")
        #expect(viewModel.availableDrivers.contains(where: { $0.id == driverB.id }))
        #expect(!viewModel.availableDrivers.contains(where: { $0.id == driverA.id }), "Already selected drivers should be hidden.")
    }

    @Test("Verify that addDriver does not allow duplicate entries")
    func testPreventDuplicateSelection() {
        let viewModel = F1ViewModel()
        let driver = createDriver(id: 1, name: "Max Verstappen")
        
        // Act: Trying to add same driver twice
        viewModel.addDriver(driver)
        viewModel.addDriver(driver)
        
        // Assert: The list should still only have 1 entry for each driver (no repeats)
        #expect(viewModel.drivers.count == 1, "The ViewModel should guard against duplicate additions.")
    }

    @Test("Verify removeDrivers correctly updates the selection state")
    func testRemoveDriverLogic() {
        let viewModel = F1ViewModel()
        let driver = createDriver(id: 1, name: "Max Verstappen")
        viewModel.drivers = [driver]
        
        // Act: Removing the driver at the first index
        viewModel.removeDrivers(at: IndexSet(integer: 0))
        
        // Assert: The selection should be empty (removded from view)
        #expect(viewModel.drivers.isEmpty, "Removing a driver should update the ViewModel state immediately.")
    }
}
