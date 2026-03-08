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

actor F1Service {
    private let baseURL = "https://api.openf1.org/v1/drivers"

    /// Fetches drivers for a specific session using async/await
    func fetchDrivers(sessionKey: Int = 9161) async throws -> [Driver] {
        // 1. Construct URL
        guard let url = URL(string: "\(baseURL)?session_key=\(sessionKey)") else {
            throw NetworkError.invalidURL
        }

        // 2. Perform Network Request (Concurrency)
        // 'await' tells the app to pause this function until the data arrives
        // without freezing the UI.
        let (data, response) = try await URLSession.shared.data(from: url)

        // 3. Validate Response
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.noData
        }

        // 4. Decode JSON
        let decoder = JSONDecoder()
        return try decoder.decode([Driver].self, from: data)
    }
}
