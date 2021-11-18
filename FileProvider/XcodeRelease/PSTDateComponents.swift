//
//  PSTDateComponents.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/18/21.
//

import Foundation

// This needs to be custom codable b/c
extension XcodeRelease {
    struct PSTDateComponents {
        // Store Swift Foundation interchange type instead of YMD directly for convenience
        var components: DateComponents
    }
}

extension XcodeRelease.PSTDateComponents {
    
    static let calendar = Calendar(identifier: .gregorian)

    // We enforce that this is a valid date in decoding
    var date: Date! {
        Self.calendar.date(from: components)
    }
}


extension XcodeRelease.PSTDateComponents: Hashable {}

extension XcodeRelease.PSTDateComponents: Codable {
    enum CodingKeys: CodingKey {
        case year, month, day
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let year = try container.decode(Int.self, forKey: .year)
        let month = try container.decode(Int.self, forKey: .month)
        let day = try container.decode(Int.self, forKey: .day)
        // Assume that these date components are relative to a non-daylight-saving california calendar.
        // Hacky but idk what else is practical.
        let refTZ = TimeZone(identifier: "PST")
        components = DateComponents(calendar: Self.calendar, timeZone: refTZ, era: 1 /* Year is AD */, year: year, month: month, day: day)
        guard components.isValidDate(in: Self.calendar)
        else {
            throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: decoder.codingPath, debugDescription: "Invalid date") )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(components.year, forKey: .year)
        try container.encode(components.month, forKey: .month)
        try container.encode(components.day, forKey: .day)
    }
}

