//
//  CourseViewSwift.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 06/03/2025.
//

import SwiftUI
import CoreLocation

struct GolfCourseView: View {
    @ObservedObject var locationManager = LocationManager.sharedInstance
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locationManager.golfCourse, id: \.holeNumber) { hole in
                    Section(header: Text("Hole \(hole.holeNumber)")) {
                        CoordinateRow(label: "Front of Green", coordinate: hole.frontGreen)
                        CoordinateRow(label: "Center of Green", coordinate: hole.centerGreen)
                        CoordinateRow(label: "Back of Green", coordinate: hole.backGreen)
                    }
                }
            }
            .navigationTitle("Golf Course Coordinates")
        }
    }
}

struct CoordinateRow: View {
    let label: String
    let coordinate: CLLocationCoordinate2D
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text("Lat: \(coordinate.latitude, specifier: "%.6f")")
            Text("Lon: \(coordinate.longitude, specifier: "%.6f")")
        }
    }
}
