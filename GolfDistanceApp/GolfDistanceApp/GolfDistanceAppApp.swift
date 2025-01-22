//  GolfDistanceAppApp.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 18/01/2025.
//
import SwiftUI
import MetaWearablesSDK

@main
struct GolfDistanceApp: App {
    @StateObject private var locationManager = LocationManager() // Initialize the LocationManager here
    @State private var impl = GolfDeviceManager.sharedInstance
    @State private var deviceManager = MWSDKDeviceManager.sharedInstance()

    init() {
      deviceManager.setKeychainAccessGroup("8Y9CW4W2BY.conlewgri.GolfDistanceApp")
      deviceManager.add(impl)
      deviceManager.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
    }
}

