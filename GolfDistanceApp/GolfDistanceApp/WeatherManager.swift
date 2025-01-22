//
//  WeatherManager.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 21/01/2025.
//

import Foundation
import CoreLocation

class WeatherManager: ObservableObject {
    @Published var windSpeed: Double? // Wind speed in meters/second
    @Published var windDirection: Double? // Wind direction in degrees
    
    private let apiKey = "1a1bca075f3cf177b8f7fbae7da15a34"
    
    func fetchWeather(for location: CLLocationCoordinate2D) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&units=metric&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }

            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.windSpeed = weatherResponse.wind.speed
                    self?.windDirection = weatherResponse.wind.deg
                }
            } catch {
                print("Failed to decode weather data: \(error.localizedDescription)")
            }
        }.resume()
    }
}

