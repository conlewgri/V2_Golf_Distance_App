//
//  PantryManager.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 06/03/2025.
//

import Foundation

class PantryManager {
    private let pantryURL = "https://getpantry.cloud/apiv1/pantry/c740f18f-e27d-4c8e-ba62-60625bdda031/basket/golf_distance"

    func sendGolfData(golfDistances: [[String: Any]]) {
        guard let url = URL(string: pantryURL) else {
            print("Invalid Pantry URL")
            return
        }

        let clubs = loadClubDistances()

        let golfData: [String: Any] = [
            "golfDistances": golfDistances,
            "clubDistances": clubs.map { ["name": $0.name, "distance": $0.distance] },
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: golfData, options: []) else {
            print("Failed to serialize JSON")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request).resume()
    }

    private func loadClubDistances() -> [GolfClub] {
        if let savedData = UserDefaults.standard.data(forKey: "ClubDistances"),
           let decodedClubs = try? JSONDecoder().decode([GolfClub].self, from: savedData) {
            return decodedClubs
        }
        return []
    }
}
