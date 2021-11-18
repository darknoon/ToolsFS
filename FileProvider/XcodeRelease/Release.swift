//
//  Release.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/18/21.
//

import Foundation

extension XcodeRelease {
    // TODO: should I mirror all of the release types represented by xcodereleases.com?
    // This compresses them to 3 logical categories
    enum Release {
        case release
        case releaseCandidate(Int)
        case beta(Int)
    }
}

extension XcodeRelease.Release: Hashable {}

extension XcodeRelease.Release: CustomStringConvertible {
    var description: String {
        switch self {
        case .release:
            return ""
        case .beta(let n):
            return "Beta \(n)"
        case .releaseCandidate(let n):
            return "RC \(n)"
        }
    }
}

extension XcodeRelease.Release: Codable {
    enum CodingKeys: CodingKey, CaseIterable {
        case release, rc, beta, gm, gmSeed, dp
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first,
              container.allKeys.count == 1
        else {
            let caseNames = CodingKeys.allCases.map{"\"\($0)\""}
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Exactly one of \(caseNames.joined(separator: " ")) is required for release dictionary"))
        }
        
        switch key {
        case .release:
            self = .release
        case .beta:
            let n = try container.decode(Int.self, forKey: .beta)
            self = .beta(n)
        case .gm:
            self = .release
        case .gmSeed:
            let n = try container.decode(Int.self, forKey: .gmSeed)
            self = .releaseCandidate(n)
        case .dp:
            let n = try container.decode(Int.self, forKey: .dp)
            self = .beta(n)
        case .rc:
            let n = try container.decode(Int.self, forKey: .rc)
            self = .releaseCandidate(n)
        }
    }
    
    // TODO: should we not collapse some of these cases to make this 1-1?
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            
        case .release:
            try container.encode(true, forKey: .release)
        case .releaseCandidate(let n):
            try container.encode(n, forKey: .rc)
        case .beta(let n):
            try container.encode(n, forKey: .beta)
        }
    }

}



