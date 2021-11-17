//
//  Manager.swift
//  ToolsFS
//
//  Created by Andrew Pouliot on 11/17/21.
//

import Foundation
import FileProvider

actor Manager {
    
    static let identifier: NSFileProviderDomainIdentifier = .init(rawValue: "com.darknoon.Xcode-Releases")
    
    let domain = NSFileProviderDomain(identifier: Manager.identifier, displayName: "Xcode Releases")
    
    func addDomain() async throws {
        try await NSFileProviderManager.add(domain)
        print("Created domain", domain)
    }
    
    func removeDomain() async throws {
        try await NSFileProviderManager.remove(domain)
        print("Removed domain", domain)
    }
    
    func signalChange() async throws {
        print("signalling for \(domain.identifier.rawValue)")
        try await NSFileProviderManager(for: domain)?.signalEnumerator(for: .rootContainer)
    }
}
