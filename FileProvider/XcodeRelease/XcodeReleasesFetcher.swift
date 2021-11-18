import Foundation
import FileProvider

@MainActor
class XcodeReleasesFetcher: ObservableObject {

    static let shared = XcodeReleasesFetcher()
    
    // Nil while fetching, resolves after
    @Published var result: Result<XcodeReleasesData, Error>? = nil

    @Published var loading: Bool = false
    
    private var fetchTask: Task<XcodeReleasesData, Error>? = nil
    
    init() {
        fetchTask = fetch()
    }
    
    // This might not be the correct way to make this a Task, thinking about it. Hmm
    func fetch() -> Task<XcodeReleasesData, Error> {
        self.loading = true
        return Task { [fetcher] in
            do {
                let (releases, etag) = try await fetcher.loadData()
                let data = XcodeReleasesData(releases: releases, releaseIdentifierMap: XcodeReleasesData.makeReleaseIdentifierMap(releases), etag: etag)
                await MainActor.run{
                    self.result = .success(data)
                    self.loading = false
                }
                return data
            } catch {
                await MainActor.run{
                    self.result = .failure(error)
                    self.loading = false
                }
                throw error
            }
        }
    }
    
    func cancel() {
        // If we have never succeeded, cancelling the first load means we are in an error state
        if result == nil {
            self.result = .failure(CancellationError())
        }
        fetchTask?.cancel()
    }

    // TODO: stream data?
    static let url = Bundle(for: XcodeReleasesFetcher.self)
        .url(forResource: "XcodeReleases.json", withExtension: nil)!

    // I think we can't load data from this process?
    // Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found."
    // static let url = URL(string: "https://xcodereleases.com/data.json")!

    let fetcher = SharedDataFetcher<[XcodeRelease]>(url: XcodeReleasesFetcher.url)
    
    var data: XcodeReleasesData {
        get async throws {
            // Either task or result should be non-nil
            if let result = result {
                return try result.get()
            } else if let fetchTask = fetchTask {
                return try await fetchTask.result.get()
            } else {
                // No result, no operation to fetch it. Unexpected state.
                fatalError("Unexpected: neither a result or a fetch task. Should have set CancellationError() as the result.")
            }
        }
    }
}
