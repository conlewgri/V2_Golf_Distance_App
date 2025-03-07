//
//  ContentView.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 06/03/2025.
//

import SwiftUI
import MapKit
import MetaWearablesSDK

struct ContentView: View {
    @StateObject var locationManager = LocationManager.sharedInstance
    @State private var showGolfCourseView = false
    @State private var showClubDistanceView = false
    
    @State private var showConnectionAlert = false
    @State private var url: URL?
    @State private var deviceManager = MWSDKDeviceManager.sharedInstance()
    
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
