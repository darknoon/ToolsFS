//
//  SDKs.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/18/21.
//

import Foundation

extension XcodeRelease {
    
    public struct SDKs: Codable, Equatable, Hashable {
        public let macOS: [Version]?
        public let iOS: [Version]?
        public let watchOS: [Version]?
        public let tvOS: [Version]?
    }
    
}
