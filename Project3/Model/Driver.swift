//
//  Driver.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

import Foundation

// Setting up custom struct/ array by defining var to allow iteration and use later
// Just using the main driverr details I found in the F1 API
struct Driver: Codable, Identifiable {
    // OpenF1 API uses 'driver_number' as a unique ID
    var id: Int { driver_number }
    let driver_number: Int
    let full_name: String
    let name_acronym: String
    let team_name: String
    let team_colour: String
    let headshot_url: String? // keeping this optional, might be empty for some
}
