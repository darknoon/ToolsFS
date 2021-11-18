//
//  Version.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/18/21.
//

import Foundation

extension XcodeRelease {
    /*
     {
         "number": "13.2",
         "build": "13C5081f",
         "release": {
             "beta": 2
         }
     }
     */
    struct Version {
        // Some versions don't have a number just a build? Can see in the data
        var number: VersionNumber?
        var build: String?
        var release: Release
        
        var description: String {
            [number?.description, release.description].compactMap{$0}.joined(separator: " ")
        }
    }
}

extension XcodeRelease.Version: Codable {}
extension XcodeRelease.Version: Hashable {}
