//
//  XcodeReleases.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/17/21.
//

import Foundation

struct XcodeRelease: Decodable {
    // Could be "Xcode" or "Xcode Tools" for example
    var name: String
    var version: Version
    var date: PSTDateComponents
    // This refers to a macOS version. Unfortunately there is also a requirement in the other direction, ie a max macOS version, that is not modeled
    var requires: String
    var sdks: SDKs?
    //var compilers: Compilers
    var links: Links?
    var checksums: Checksums?
}

/*
 Example:
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

