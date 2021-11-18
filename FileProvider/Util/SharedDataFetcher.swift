//
//  SharedDataFetcher.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/18/21.
//

import Foundation

actor SharedDataFetcher<Result: Decodable> {
    init(url: URL) {
        self.url = url
    }
    
    // URL to fetch from
    let url: URL
    private var _data: Result? = nil
    private var _etag: String? = nil
    private (set) var error: Error? = nil

    func fetchIfNeeded() async throws {
        if _data != nil {
            print("fetchIfNeeded() -> not needed")
            return
        }
        try await fetch()
    }
    
    private func fetch() async throws {
        do {
            (_data, _etag) = try await loadData()
        } catch {
            print("data loading error: ", error)
            self.error = error
        }
    }
    
    internal func loadData() async throws -> (result: Result, etag: String?) {
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        print("response:", response)
        
        let dec = JSONDecoder()
        let result = try dec.decode(Result.self, from: data)
        
        let hr = response as? HTTPURLResponse
        let etag = hr?.allHeaderFields["ETag"] as? String
        
        return (result, etag)
    }
    
    var data: Result {
        get async throws {
            try await fetchIfNeeded()
            return _data!
        }
    }
    

}

