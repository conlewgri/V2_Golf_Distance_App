//
//  ContentView.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 06/03/2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager.sharedInstance
    @State private var showGolfCourseView = false
    @State private var showClubDistanceView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Golf Distance App")
                    .font(.largeTitle)
                    .bold()
                
                // Button to View Golf Course Coordinates
                Button("View Golf Course Coordinates") {
                    showGolfCourseView = true
                }
                .padding()
                .sheet(isPresented: $showGolfCourseView) {
                    GolfCourseView()
                }
                
                // Button to Set Club Distances
                Button("Set Club Distances") {
                    showClubDistanceView = true
                }
                .padding()
                .sheet(isPresented: $showClubDistanceView) {
                    ClubDistanceView()
                }
                
                // Button to Calculate & Send Distances to Pantry
                Button("Calculate and Send Distances") {
                    locationManager.calculateDistances()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                // Live Map with Annotations
                Map(coordinateRegion: $locationManager.region, annotationItems: mapAnnotations()) { annotation in
                    MapPin(coordinate: annotation.coordinate, tint: annotation.name == "Green" ? .green : .orange)
                }
                .frame(height: 300)
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
        }
    }
    
    // Function to Generate Map Annotations
    private func mapAnnotations() -> [MapAnnotation] {
        var annotations = [MapAnnotation]()
        
        if let userLocation = locationManager.userLocation {
            annotations.append(MapAnnotation(name: "User", coordinate: userLocation.coordinate))
        }
        for hole in locationManager.golfCourse {
            annotations.append(MapAnnotation(name: "Front Green (Hole \(hole.holeNumber))", coordinate: hole.frontGreen))
            annotations.append(MapAnnotation(name: "Center Green (Hole \(hole.holeNumber))", coordinate: hole.centerGreen))
            annotations.append(MapAnnotation(name: "Back Green (Hole \(hole.holeNumber))", coordinate: hole.backGreen))
        }
        return annotations
    }
}

// Struct for Map Annotations
struct MapAnnotation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
