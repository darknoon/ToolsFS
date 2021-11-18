//
//  Data.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/18/21.
//

import Foundation
import FileProvider

struct XcodeReleasesData {
    var releases: [XcodeRelease]
    var releaseIdentifierMap: [NSFileProviderItemIdentifier: XcodeItem]
    var etag: String?
    
    func release(for version: XcodeRelease.Version) -> XcodeRelease? {
        releases.first{ $0.version == version }
    }
    
    func releases(for majorVersion: Int) -> [XcodeRelease] {
        releases.filter{ $0.version.number?.major == majorVersion }
    }
    
    func firstRelease(for majorVersion: Int) -> Date? {
        let firstRelease = releases(for: majorVersion).min { a, b in
            a.date.date < b.date.date
        }
        return firstRelease?.date.date
    }
        
    func mostRecentRelease(for majorVersion: Int) -> Date? {
        let latestRelease = releases(for: majorVersion).max { a, b in
            a.date.date < b.date.date
        }
        return latestRelease?.date.date
    }
}

extension XcodeReleasesData {
    static func makeReleaseIdentifierMap(_ releases: [XcodeRelease]) -> [NSFileProviderItemIdentifier: XcodeItem] {
        func makeTuple(_ item: XcodeItem) -> (NSFileProviderItemIdentifier, XcodeItem) {
            (item.itemIdentifier, item)
        }
        let items = releases
            .map(\.version)
            .map(XcodeItem.versionItem)
        let majorVersions = releases.compactMap{$0.version.number?.major}.map(XcodeItem.versionMajor)
        let root = [XcodeItem.root]
        let all = items + majorVersions + root
        return Dictionary(all.map(makeTuple), uniquingKeysWith: { (first, _) in first })
    }
}

