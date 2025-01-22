//  GolfDistanceAppApp.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 18/01/2025.
//
import SwiftUI
import MetaWearablesSDK

@main
struct GolfDistanceApp: App {
    @State private var impl = GolfDeviceManager.sharedInstance
    @State private var deviceManager = MWSDKDeviceManager.sharedInstance()

    init() {
      deviceManager.setKeychainAccessGroup("T84QZS65DQ.conlewgri.GolfDistanceApp")
      deviceManager.add(impl)
      deviceManager.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

