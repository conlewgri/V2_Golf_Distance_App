//
//  PantryManager.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 06/03/2025.
//

import Foundation

class PantryManager {
    static let sharedInstance = PantryManager()
    
    private let pantryURL = "https://getpantry.cloud/apiv1/pantry/c740f18f-e27d-4c8e-ba62-60625bdda031/basket/golf_distance"

    func windDirectionToString(direction: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((direction + 22.5) / 45) % 8
        return directions[index]
    }
    
    func sendGolfData(golfDistances: [String]) {
        guard let url = URL(string: pantryURL) else {
            print("Invalid Pantry URL")
            return
        }
        
        let clubs = loadClubDistances()

        let clubsMap = clubs.map { $0.name + ": " + String($0.distance) }
        
        let golfInfo = GolfInfoData()

        let golfData: [String: Any] = [
            "golfDistances": golfDistances.joined(separator: ", "),
            "clubDistances": clubsMap.joined(separator: ", "),
            "golfInfo": golfInfo.getGolfInfo(),
            "windspeed": String(WeatherManager.sharedInstance.windSpeed ?? 0.0),
            "winddir": String(WeatherManager.sharedInstance.windDirection ?? 0.0),
            "windstr" : windDirectionToString(direction: WeatherManager.sharedInstance.windDirection ?? 0.0),
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
