//
//  ClubDistance.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 05/03/2025.
//

import SwiftUI

struct GolfClub: Identifiable, Codable {
    let id = UUID()
    var name: String
    var distance: Double
}

struct ClubDistanceView: View {
    @State private var clubs: [GolfClub] = [
        GolfClub(name: "Driver", distance: 0),
        GolfClub(name: "3 Wood", distance: 0),
        GolfClub(name: "5 Wood", distance: 0),
        GolfClub(name: "3 Iron", distance: 0),
        GolfClub(name: "4 Iron", distance: 0),
        GolfClub(name: "5 Iron", distance: 0),
        GolfClub(name: "6 Iron", distance: 0),
        GolfClub(name: "7 Iron", distance: 0),
        GolfClub(name: "8 Iron", distance: 0),
        GolfClub(name: "9 Iron", distance: 0),
        GolfClub(name: "Pitching Wedge", distance: 0),
        GolfClub(name: "Sand Wedge", distance: 0),
        GolfClub(name: "Lob Wedge", distance: 0)
    ]

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($clubs) { $club in
                        HStack {
                            Text(club.name)
                                .font(.headline)
                            Spacer()
                            TextField("Distance (yards)", value: $club.distance, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
                }
                .navigationTitle("Club Distances")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveData()
                            dismiss()
                        }
                    }
                }
            }
            .onAppear(perform: loadData)
        }
    }

    func saveData() {
        if let encoded = try? JSONEncoder().encode(clubs) {
            UserDefaults.standard.set(encoded, forKey: "ClubDistances")
        }
    }

    func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: "ClubDistances"),
           let decodedClubs = try? JSONDecoder().decode([GolfClub].self, from: savedData) {
            clubs = decodedClubs
        }
    }
}
