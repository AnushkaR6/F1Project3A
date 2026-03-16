//
//  F1Service.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
}

// creating a mutable format to be reused for esch driver
actor F1Service {
    private let baseURL = "https://api.openf1.org/v1/drivers"

    /// Fetches drivers for a specific session using async/await
    func fetchDrivers(sessionKey: Int = 9161) async throws -> [Driver] {
        // Creating URL
        guard let url = URL(string: "\(baseURL)?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        // Concurrency/ network request
        // waiting for data to come before moving forward or gettng stuck on load page
        let (data, response) = try await URLSession.shared.data(from: url)

        // Validating response
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.noData
        }

        // Decoding the response/ data into format that SWift can read
        let decoder = JSONDecoder()
        return try decoder.decode([Driver].self, from: data)
    }
}
