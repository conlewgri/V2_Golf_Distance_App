
//
//  LocationManager.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 05/03/2025.
//

import Foundation
import CoreLocation
import MapKit

// Struct for storing hole locations with Codable support
struct GolfHole: Identifiable, Codable {
    let id = UUID()
    let holeNumber: Int
    var frontGreen: CLLocationCoordinate2D
    var centerGreen: CLLocationCoordinate2D
    var backGreen: CLLocationCoordinate2D

    // Custom Initializer to allow direct instance creation
    init(holeNumber: Int, frontGreen: CLLocationCoordinate2D, centerGreen: CLLocationCoordinate2D, backGreen: CLLocationCoordinate2D) {
        self.holeNumber = holeNumber
        self.frontGreen = frontGreen
        self.centerGreen = centerGreen
        self.backGreen = backGreen
    }

    // Custom CodingKeys to store CLLocationCoordinate2D as lat/lon
    enum CodingKeys: String, CodingKey {
        case id, holeNumber, frontLat, frontLon, centerLat, centerLon, backLat, backLon
    }

    // Custom Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        holeNumber = try container.decode(Int.self, forKey: .holeNumber)

        let frontLat = try container.decode(Double.self, forKey: .frontLat)
        let frontLon = try container.decode(Double.self, forKey: .frontLon)
        frontGreen = CLLocationCoordinate2D(latitude: frontLat, longitude: frontLon)

        let centerLat = try container.decode(Double.self, forKey: .centerLat)
        let centerLon = try container.decode(Double.self, forKey: .centerLon)
        centerGreen = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)

        let backLat = try container.decode(Double.self, forKey: .backLat)
        let backLon = try container.decode(Double.self, forKey: .backLon)
        backGreen = CLLocationCoordinate2D(latitude: backLat, longitude: backLon)
    }

    // Custom Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(holeNumber, forKey: .holeNumber)

        try container.encode(frontGreen.latitude, forKey: .frontLat)
        try container.encode(frontGreen.longitude, forKey: .frontLon)

        try container.encode(centerGreen.latitude, forKey: .centerLat)
        try container.encode(centerGreen.longitude, forKey: .centerLon)

        try container.encode(backGreen.latitude, forKey: .backLat)
        try container.encode(backGreen.longitude, forKey: .backLon)
    }
}

// LocationManager: Manages GPS and Preloaded Coordinates
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let sharedInstance = LocationManager()
    
    private let locationManager = CLLocationManager()

    @Published var userLocation: CLLocation?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    // Preloaded Golf Course Coordinates for 18 Holes
    @Published var golfCourse: [GolfHole] = [
        GolfHole(holeNumber: 1, frontGreen: CLLocationCoordinate2D(latitude: 51.396308, longitude: -0.155970),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.396422, longitude: -0.155929),
                 backGreen: CLLocationCoordinate2D(latitude: 51.396542, longitude: -0.155856)),
        GolfHole(holeNumber: 2, frontGreen: CLLocationCoordinate2D(latitude: 51.393808, longitude: -0.157557),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.393682, longitude: -0.157619),
                 backGreen: CLLocationCoordinate2D(latitude: 51.39355, longitude: -0.157675)),
        GolfHole(holeNumber: 3, frontGreen: CLLocationCoordinate2D(latitude: 51.394314, longitude: -0.155379),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.394421, longitude: -0.155289),
                 backGreen: CLLocationCoordinate2D(latitude: 51.394542, longitude: -0.155197)),
        GolfHole(holeNumber: 4, frontGreen: CLLocationCoordinate2D(latitude: 51.396091, longitude: -0.153170),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.396070, longitude: -0.153017),
                 backGreen: CLLocationCoordinate2D(latitude: 51.396058, longitude: -0.152823)),
        GolfHole(holeNumber: 5, frontGreen: CLLocationCoordinate2D(latitude: 51.392561, longitude: -0.152644),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.392479, longitude: -0.152684),
                 backGreen: CLLocationCoordinate2D(latitude: 51.392398, longitude: -0.152713)),
        GolfHole(holeNumber: 6, frontGreen: CLLocationCoordinate2D(latitude: 51.390405, longitude: -0.151437),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.390391, longitude: -0.151228),
                 backGreen: CLLocationCoordinate2D(latitude: 51.390427, longitude: -0.151058)),
        GolfHole(holeNumber: 7, frontGreen: CLLocationCoordinate2D(latitude: 51.390458, longitude: -0.148738),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.390466, longitude: -0.148462),
                 backGreen: CLLocationCoordinate2D(latitude: 51.390478, longitude: -0.148194)),
        GolfHole(holeNumber: 8, frontGreen: CLLocationCoordinate2D(latitude: 51.390616, longitude: -0.150296),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.390626, longitude: -0.150528),
                 backGreen: CLLocationCoordinate2D(latitude: 51.390634, longitude: -0.150810)),
        GolfHole(holeNumber: 9, frontGreen: CLLocationCoordinate2D(latitude: 51.391532, longitude: -0.152851),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.391587, longitude: -0.153015),
                 backGreen: CLLocationCoordinate2D(latitude: 51.391652, longitude: -0.153178)),
        GolfHole(holeNumber: 10, frontGreen: CLLocationCoordinate2D(latitude: 51.393182, longitude: -0.147403),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.393265, longitude: -0.147288),
                 backGreen: CLLocationCoordinate2D(latitude: 51.393362, longitude: -0.147173)),
        GolfHole(holeNumber: 11, frontGreen: CLLocationCoordinate2D(latitude: 51.391417, longitude: -0.149025),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.391333, longitude: -0.149169),
                 backGreen: CLLocationCoordinate2D(latitude: 51.391251, longitude: -0.149333)),
        GolfHole(holeNumber: 12, frontGreen: CLLocationCoordinate2D(latitude: 51.391112, longitude: -0.144649),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.391125, longitude: -0.144493),
                 backGreen: CLLocationCoordinate2D(latitude: 51.391146, longitude: -0.144348)),
        GolfHole(holeNumber: 13, frontGreen: CLLocationCoordinate2D(latitude: 51.393641, longitude: -0.146317),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.393733, longitude: -0.146399),
                 backGreen: CLLocationCoordinate2D(latitude: 51.393805, longitude: -0.146520)),
        GolfHole(holeNumber: 14, frontGreen: CLLocationCoordinate2D(latitude: 51.392472, longitude: -0.150344),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.392401, longitude: -0.150496),
                 backGreen: CLLocationCoordinate2D(latitude: 51.392343, longitude: -0.150647)),
        GolfHole(holeNumber: 15, frontGreen: CLLocationCoordinate2D(latitude: 51.394402, longitude: -0.150899),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.394519, longitude: -0.150951),
                 backGreen: CLLocationCoordinate2D(latitude: 51.394637, longitude: -0.150984)),
        GolfHole(holeNumber: 16, frontGreen: CLLocationCoordinate2D(latitude: 51.395054, longitude: -0.151506),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.395102, longitude: -0.151629),
                 backGreen: CLLocationCoordinate2D(latitude: 51.395154, longitude: -0.151755)),
        GolfHole(holeNumber: 17, frontGreen: CLLocationCoordinate2D(latitude: 51.392717, longitude: -0.153210),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.392612, longitude: -0.153217),
                 backGreen: CLLocationCoordinate2D(latitude: 51.392506, longitude: -0.153242)),
        GolfHole(holeNumber: 18, frontGreen: CLLocationCoordinate2D(latitude: 51.393139, longitude: -0.155654),
                 centerGreen: CLLocationCoordinate2D(latitude: 51.393185, longitude: -0.155855),
                 backGreen: CLLocationCoordinate2D(latitude: 51.393254, longitude: -0.156092)),
    ]

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Update user location in real-time
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        region.center = location.coordinate
    }
    
    // Function to calculate distances to all 54 points
    func calculateDistances() {
        guard let userLoc = userLocation else { return }
        calculateDistances(userLocation: userLoc.coordinate)
    }

    func calculateDistances(userLocation: CLLocationCoordinate2D) {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        var allDistances: [String] = []

        for hole in golfCourse {
            let distances = [
                ("frontGreen", hole.frontGreen),
                ("centerGreen", hole.centerGreen),
                ("backGreen", hole.backGreen)
            ]

            for (locationType, greenLocation) in distances {
                let greenCLLocation = CLLocation(latitude: greenLocation.latitude, longitude: greenLocation.longitude)
                let distanceInYards = userCLLocation.distance(from: greenCLLocation) * 1.09361 // Convert meters to yards

                allDistances.append(
                    "{ hole: " + String(hole.holeNumber)
                    + ", location: " + locationType
                    + ", distance: " + String(format: "%.2f", distanceInYards)
                    + "}"
                )
            }
        }

        let pantryManager = PantryManager()
        pantryManager.sendGolfData(golfDistances: allDistances)
    }

    // Function to update a hole's coordinates
    func updateHoleCoordinates(holeNumber: Int, front: CLLocationCoordinate2D, center: CLLocationCoordinate2D, back: CLLocationCoordinate2D) {
        if let index = golfCourse.firstIndex(where: { $0.holeNumber == holeNumber }) {
            golfCourse[index].frontGreen = front
            golfCourse[index].centerGreen = center
            golfCourse[index].backGreen = back
        }
    }
}
