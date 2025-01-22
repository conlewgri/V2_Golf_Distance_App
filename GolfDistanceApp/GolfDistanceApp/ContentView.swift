
//  ContentView.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 18/01/2025.
//

import SwiftUI
import CoreLocation
import MapKit
import MetaWearablesSDK

// Location Manager for GPS data
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static public let sharedInstance = LocationManager()
    private let locationManager = CLLocationManager()

    @Published var greenLocation: CLLocationCoordinate2D?
    @Published var bunkerLocation: CLLocationCoordinate2D?
    @Published var distanceToGreen: Double?
    @Published var distanceToBunker: Double?
    @Published var isGreenSet: Bool = false
    @Published var isBunkerSet: Bool = false
    @Published var userLocation: CLLocation?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 2 // Updates only after moving 2 meters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        region.center = location.coordinate
    }
    
    func calculateDistances() {
        if let userLoc = userLocation {
            calculateDistances(userLocation: userLoc.coordinate)
        }
    }
    
    func calculateDistances(userLocation: CLLocationCoordinate2D) {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        // Calculate distance to green
        if let greenLocation = greenLocation {
            let greenCLLocation = CLLocation(latitude: greenLocation.latitude, longitude: greenLocation.longitude)
            let distanceInMeters = userCLLocation.distance(from: greenCLLocation)
            distanceToGreen = distanceInMeters * 1.09361 // Convert to yards
        }

        // Calculate distance to bunker
        if let bunkerLocation = bunkerLocation {
            let bunkerCLLocation = CLLocation(latitude: bunkerLocation.latitude, longitude: bunkerLocation.longitude)
            let distanceInMeters = userCLLocation.distance(from: bunkerCLLocation)
            distanceToBunker = distanceInMeters * 1.09361 // Convert to yards
        }

        // Push data to Pantry
        if let distanceToGreen = distanceToGreen, let distanceToBunker = distanceToBunker {
            let pantryManager = PantryManager()
            pantryManager.sendGolfData(distanceToGreen: distanceToGreen, distanceToBunker: distanceToBunker)
        }
    }

    
}

// Pantry Manager for handling Pantry API requests
class PantryManager {
    private let pantryURL = "https://getpantry.cloud/apiv1/pantry/c740f18f-e27d-4c8e-ba62-60625bdda031/basket/golf_distance"

    func sendGolfData(distanceToGreen: Double, distanceToBunker: Double) {
        guard let url = URL(string: pantryURL) else {
            print("Invalid Pantry URL")
            return
        }

        // Prepare JSON payload
        let golfData: [String: Any] = [
            "distanceToGreen": distanceToGreen,
            "distanceToBunker": distanceToBunker,
            "timestamp": ISO8601DateFormatter().string(from: Date()) // timestamp
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: golfData, options: []) else {
            print("Failed to serialize JSON")
            return
        }

        // Create a PUT request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send data to Pantry: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Successfully sent data to Pantry!")
            } else {
                print("Failed to send data to Pantry.")
            }
        }.resume()
    }
}

// Structs for decoding weather data
struct WeatherResponse: Codable {
    let wind: Wind
}

struct Wind: Codable {
    let speed: Double
    let deg: Double
}

struct ContentView: View {
    @StateObject var locationManager = LocationManager.sharedInstance
    @StateObject private var weatherManager = WeatherManager()

    @State private var showConnectionAlert = false
    @State private var url: URL?
    @State private var deviceManager = MWSDKDeviceManager.sharedInstance()
    
    
   
   
    var body: some View {
        VStack {
            // Live Map
            Map(coordinateRegion: $locationManager.region, annotationItems: mapAnnotations()) { annotation in
                MapPin(coordinate: annotation.coordinate, tint: annotation.name == "Green" ? .green : .orange)
            }
            .frame(height: 300)
            .cornerRadius(10)
            .padding()

            Spacer()

            // Weather Section
            if let windSpeed = weatherManager.windSpeed, let windDirection = weatherManager.windDirection {
                VStack(spacing: 5) {
                    Text("Wind Speed: \(String(format: "%.2f", windSpeed * 2.23694)) mph") // Convert m/s to mph
                        .font(.headline)
                    Text("Wind Direction: \(String(format: "%.1f", windDirection))° (\(compassDirection(from: windDirection)))")
                        .font(.subheadline)
                }
                .padding()
            } else {
                Text("Fetching wind data...")
                    .padding()
            }

            // Distance Calculation and Actions
            VStack(spacing: 20) {
                if let userLocation = locationManager.userLocation {
                    
                    Text("Your Location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
                        .font(.caption)
                                    
                    // Fetch weather data when location is available
                    Button("Get Weather Data") {
                        weatherManager.fetchWeather(for: userLocation.coordinate)
                    }
                    .padding()

                    // Set Green Location
                    if !locationManager.isGreenSet {
                        Button("Set Current Location as Green") {
                            locationManager.greenLocation = userLocation.coordinate
                            locationManager.isGreenSet = true
                        }
                        .padding()
                    }

                    // Set Bunker Location
                    if locationManager.isGreenSet && !locationManager.isBunkerSet {
                        Button("Set Current Location as Bunker") {
                            locationManager.bunkerLocation = userLocation.coordinate
                            locationManager.isBunkerSet = true
                        }
                        .padding()
                    }

                    // Calculate Distances and Push to Pantry
                    if locationManager.isGreenSet && locationManager.isBunkerSet {
                        Button("Calculate and Send Distances") {
                            locationManager.calculateDistances()
                        }
                        .padding()

                        VStack(spacing: 10) {
                            if let distance = locationManager.distanceToGreen {
                                Text("Distance to Green: \(String(format: "%.2f", distance)) yards")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }

                            if let distance = locationManager.distanceToBunker {
                                Text("Distance to Bunker: \(String(format: "%.2f", distance)) yards")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                        }

                        Button("Reset Locations") {
                            resetLocations()
                        }
                        .padding()
                        .foregroundColor(.red)
                    }
                } else {
                    Text("Fetching GPS data...")
                }
            }
            .padding()
            .onOpenURL(perform: { url in
              self.url = url
              self.showConnectionAlert = true
            })
            .alert(Text("Connect to Glasses"), isPresented: $showConnectionAlert, presenting: url
            ) { details in
              Button {
                if let url {
                  deviceManager.handleRegistrationIntent(from: url, success: { action, continueCallback in
                    switch action {
                    case .startRegistration:
                      continueCallback?(true, { error in
                        if let error {
                          NSLog("Error when handling start registration intent : \(error)")
                        }
                      })
                    case .deleteRegistration:
                      continueCallback?(true, { error in
                        if let error {
                          NSLog("Error when handling delete registration intent : \(error)")
                        }
                      })
                    @unknown default:
                      NSLog("Error when handling registration intent")
                    }
                  }, failure: { error in
                    NSLog("Failed to handle registration intent")
                  })
                  showConnectionAlert = false
                }
              } label: {
                Text("Link Device")
              }
              Button(role: .cancel) {
                showConnectionAlert = false
              } label: {
                Text("Cancel")
              }
            } message: { details in
              Text("Do you want to securely connect your app to your glasses?")
            }

            
        }
    }

    private func resetLocations() {
        locationManager.greenLocation = nil
        locationManager.bunkerLocation = nil
        locationManager.distanceToGreen = nil
        locationManager.distanceToBunker = nil
        locationManager.isGreenSet = false
        locationManager.isBunkerSet = false
    }

    private func mapAnnotations() -> [MapAnnotation] {
        var annotations = [MapAnnotation]()
        if let userLocation = locationManager.userLocation {
            annotations.append(MapAnnotation(name: "User", coordinate: userLocation.coordinate))
        }
        if let greenLocation = locationManager.greenLocation {
            annotations.append(MapAnnotation(name: "Green", coordinate: greenLocation))
        }
        if let bunkerLocation = locationManager.bunkerLocation {
            annotations.append(MapAnnotation(name: "Bunker", coordinate: bunkerLocation))
        }
        return annotations
    }

    private func compassDirection(from degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
        let index = Int((degrees + 22.5) / 45.0) % 8
        return directions[index]
    }
}

struct MapAnnotation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
