//
//  GolfInfo.swift
//  GolfDistanceApp
//
//  Created by David Jamie Thomas on 07/03/2025.
//

import Foundation

class FileReader {
    /// Reads the contents of a .txt file at the specified path into a String.
    ///
    /// - Parameter filePath: The path to the .txt file to read from.
    /// - Returns: The contents of the file as a String, or nil if an error occurs.
    func readTextFile(atPath filePath: String) -> String? {
        do {
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            return contents
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }
}

struct GolfInfoData {

    func getGolfInfo() -> String {
        let filePath = Bundle.main.path(forResource: "GolfInfo", ofType: "txt")!
        let fileReader = FileReader()
        if let fileContents = fileReader.readTextFile(atPath: filePath) {
            return fileContents;
        } else {
            print("Failed to read file")
            return "";
        }
    }
}
