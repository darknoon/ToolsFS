//
//  FileProviderItem.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/17/21.
//

import FileProvider
import UniformTypeIdentifiers

enum XcodeItem {
    case root
    case versionMajor(majorVersion: Int)
    case versionItem(version: XcodeRelease.Version)
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        switch self {
        case .root:
            return .rootContainer
        default:
            let enc = JSONEncoder()
            let jsonString = String(data: try! enc.encode(self), encoding: .utf8)!
            return .init(rawValue: jsonString)
        }
    }
    
    init(from identifier: NSFileProviderItemIdentifier) throws {
        switch identifier{
        case .rootContainer:
            self = .root
        case .trashContainer:
            // TODO: have to handle trashing? Not actually possible but yeah
            self = .root
        case .workingSet:
            // TODO: have to handle working set? Yikes.
            self = .root
        default:
            let dec = JSONDecoder()
            let dat = identifier.rawValue.data(using: .utf8)!
            self = try dec.decode(Self.self, from: dat)
        }
    }
}

extension XcodeItem: Codable {
    // {r: true} -> root
    // {v: 1} -> versionMajor(1)
    // {i: "13.1"} -> versionItem(13.1)
    enum CodingKeys: String, CodingKey {
        case root = "r"
        case versionMajor = "v"
        case versionItem = "i"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = c.allKeys.first
        else {
            throw DecodingError.keyNotFound(CodingKeys.versionItem, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Empty container?", underlyingError: nil))
        }
        switch key {
        case .root:
            guard let value = try? c.decode(Bool.self, forKey: .root), value == true
            else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath,
                                          debugDescription: "Invalid .root encoding",
                                          underlyingError: nil)
                )
            }
            self = .root
        case .versionMajor:
            self = .versionMajor(majorVersion: try c.decode(Int.self, forKey: key))
        case .versionItem:
            self = .versionItem(version: try c.decode(XcodeRelease.Version.self, forKey: key))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .root:
            try container.encode(true, forKey: .root)
        case .versionMajor(let majorVersion):
            try container.encode(majorVersion, forKey: .versionMajor)
        case .versionItem(let version):
            try container.encode(version, forKey: .versionItem)
        }
    }
    
    
}

class FileProviderItem: NSObject, NSFileProviderItem {

    private let data: XcodeReleasesData
    private let model: XcodeItem

    init(model: XcodeItem, data: XcodeReleasesData) {
        self.model = model
        self.data = data
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        model.itemIdentifier
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        switch model {
        case .root:
            return .rootContainer
        case .versionMajor(let majorVersion):
            return .rootContainer
        case .versionItem(let version):
            return XcodeItem.versionMajor(majorVersion: version.number!.major).itemIdentifier
        }
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading, .allowsEvicting]
    }
    
    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }
    
    var filename: String {
        switch model {
        case .root:
            return "Root"
        case .versionMajor(let majorVersion):
            return "Xcode \(majorVersion).X Versions"
        case .versionItem(let version):
            // Better have a release!
            let r = data.release(for: version)!
            return "\(r.name) \(r.version.description)"
        }
    }

    var extendedAttributes: [String: Data] {
        return ["com.apple.FinderInfo": Data()]
    }

    var contentType: UTType {
        switch model {
        case .root:
            return .folder
        case .versionMajor:
            return .folder
        case .versionItem:
            // TODO: app bundle
//            return .applicationBundle
            return .plainText
        }
    }
}
