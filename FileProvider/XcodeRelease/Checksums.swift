//
//  Checksums.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/18/21.
//

import Foundation

extension XcodeRelease {
    struct Checksums {
        let sha1: String?
    }
}


extension XcodeRelease.Checksums: Codable {}
extension XcodeRelease.Checksums: Hashable {}
