//
//  VersionNumber.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/18/21.
//

import Foundation

// Parse version strings like "10.5" into {major: 10, minor: 5, point: nil} to facilitate efficient grouping / sorting etc
extension XcodeRelease {
    struct VersionNumber {
        var major: Int
        var minor: Int
        var point: Int?
    }
}

extension XcodeRelease.VersionNumber: Codable {
    // Parse from the given string
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let versionString = try c.decode(String.self)
        let items = versionString.components(separatedBy: ".")
        let numbers = items.compactMap(Int.init)

        guard (2...3).contains(items.count),
              (2...3).contains(numbers.count)
        else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Version number must have 2-3 numeric components, got \(versionString)"))
        }
        major = numbers[0]
        minor = numbers[1]
        point = numbers.count >= 3 ? numbers[2] : nil
    }
    
    // Turn ourselves back into a string when encoding
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(self.description)
    }
}

extension XcodeRelease.VersionNumber: Hashable {}

extension XcodeRelease.VersionNumber: CustomStringConvertible {
    var description: String {
        [major, minor, point]
            .compactMap{$0?.description}
            .joined(separator: ".")
    }
}
