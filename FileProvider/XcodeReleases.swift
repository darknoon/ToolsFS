//
//  XcodeReleases.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/17/21.
//

import Foundation

/*
 {
     "compilers": {
         "clang": [
             {
                 "number": "13.0.0",
                 "build": "1300.0.29.30",
                 "release": {
                     "release": true
                 }
             }
         ],
         "swift": [
             {
                 "number": "5.5.2",
                 "build": "1300.0.47.2",
                 "release": {
                     "release": true
                 }
             }
         ]
     },
     "requires": "11.3",
     "date": {
         "year": 2021,
         "month": 11,
         "day": 16
     },
     "links": {
         "notes": {
             "url": "https://developer.apple.com/documentation/xcode-release-notes/xcode-13_2-release-notes"
         },
         "download": {
             "url": "https://download.developer.apple.com/Developer_Tools/Xcode_13.2_beta_2/Xcode_13.2_beta_2.xip"
         }
     },
     "version": {
         "number": "13.2",
         "build": "13C5081f",
         "release": {
             "beta": 2
         }
     },
     "sdks": {
         "macOS": [
             {
                 "number": "12.1",
                 "build": "21C5039a",
                 "release": {
                     "release": true
                 }
             }
         ],
         "tvOS": [
             {
                 "number": "15.2",
                 "build": "19K5043a",
                 "release": {
                     "release": true
                 }
             }
         ],
         "iOS": [
             {
                 "number": "15.2",
                 "build": "19C5044a",
                 "release": {
                     "release": true
                 }
             }
         ],
         "watchOS": [
             {
                 "number": "8.3",
                 "build": "19S5044a",
                 "release": {
                     "release": true
                 }
             }
         ]
     },
     "name": "Xcode",
     "checksums": {
         "sha1": "95ce1aed7b1874efd97b40596674968257faece4"
     }
 },
 */

struct XcodeRelease: Decodable {
    // Could be "Xcode" or "Xcode Tools" for example
    var name: String
    var checksums: Checksums?
    var version: Version
    var sdks: [String: [Version]]?
}

extension XcodeRelease {
    typealias Checksums = [String: String]
    
    /*
     {
         "number": "13.2",
         "build": "13C5081f",
         "release": {
             "beta": 2
         }
     }
     */
    struct Version: Codable, Equatable {
        // Some versions don't have a number just a build? Can see in the data
        var number: VersionNumber?
        var build: String?
        var release: Release
        
        var description: String {
            [number?.description, release.description].compactMap{$0}.joined(separator: " ")
        }
    }
    
    struct VersionNumber: Codable, Equatable {
        var major: Int
        var minor: Int
        var point: Int?
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
        
        func encode(to encoder: Encoder) throws {
            var c = encoder.singleValueContainer()
            try c.encode(self.description)
        }
        
        var description: String {
            [major, minor, point]
                .compactMap{$0?.description}
                .joined(separator: ".")
        }
    }
    
}

extension XcodeRelease {
    enum Release {
        case release
        case releaseCandidate(Int)
        case beta(Int)

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
}

extension XcodeRelease.Release: Equatable {}

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




