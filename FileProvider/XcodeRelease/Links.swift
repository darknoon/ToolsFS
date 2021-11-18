//
//  Links.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/18/21.
//

import Foundation

extension XcodeRelease {
    struct Links {
        let download: Link?
        let notes: Link?
    }
    struct Link {
        let url: URL
    }
}

extension XcodeRelease.Links: Codable {}
extension XcodeRelease.Links: Hashable {}

extension XcodeRelease.Link: Codable {}
extension XcodeRelease.Link: Hashable {}
