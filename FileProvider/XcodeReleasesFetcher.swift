import Foundation
import FileProvider

struct XcodeReleasesData {
    var releases: [XcodeRelease]
    var releaseIdentifierMap: [NSFileProviderItemIdentifier: XcodeItem]
    var etag: String?
    
    func release(for version: XcodeRelease.Version) -> XcodeRelease? {
        releases.first{ $0.version == version }
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

actor XcodeReleasesFetcher {
    
    static let shared = XcodeReleasesFetcher()
    
    init() {}
    
    func fetchIfNeeded() async throws {
        if _data != nil {
            print("fetchIfNeeded() -> not needed")
            return
        }
        try await fetch()
    }
    
    private func fetch() async throws {
        do {
            _data = try await Self.loadData()
        } catch {
            print("data loading error: ", error)
            self.error = error
        }
    }
    
    // TODO: abstract this!
    internal static func loadData() async throws -> XcodeReleasesData {
        // TODO: stream data?
        guard let url = Bundle(for: Self.self)
            .url(forResource: "XcodeReleases.json", withExtension: nil)
        else {
            fatalError("Missing XcodeReleases.json in bundle")
        }
        // I think we can't load data from this process?
        // Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found."
        // let url = URL(string: "https://xcodereleases.com/data.json")!
        
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        print("response:", response)
        
        let dec = JSONDecoder()
        let releases = try dec.decode([XcodeRelease].self, from: data)
        
        let hr = response as? HTTPURLResponse
        let etag = hr?.allHeaderFields["ETag"] as? String
        
        return .init(releases: releases, releaseIdentifierMap: XcodeReleasesData.makeReleaseIdentifierMap(releases), etag: etag)
    }
    
    private var _data: XcodeReleasesData? = nil
    
    var data: XcodeReleasesData {
        get async throws {
            try await fetchIfNeeded()
            return _data!
        }
    }
    
    var error: Error?
}
