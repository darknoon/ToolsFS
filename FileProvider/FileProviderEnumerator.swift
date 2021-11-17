//
//  FileProviderEnumerator.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/17/21.
//

import FileProvider


extension XcodeRelease {
    var itemIdentifier: NSFileProviderItemIdentifier {
        NSFileProviderItemIdentifier(rawValue: self.version.description)
    }
}

// Always enumerates just plain files
class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    
    let model: XcodeItem
    
    private let anchor = NSFileProviderSyncAnchor("an anchor".data(using: .utf8)!)
    
    init(model: XcodeItem) {
        self.model = model
        super.init()
    }

    func invalidate() {
        // TODO: perform invalidation of server connection if necessary
        print("Asked to invalidate enumerator for \(model)")
        enumerateTask?.cancel()
    }
    
    var enumerateTask: Task<Void, Never>? = nil

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        /* TODO:
         - inspect the page to determine whether this is an initial or a follow-up request
         
         If this is an enumerator for a directory, the root container or all directories:
         - perform a server request to fetch directory contents
         If this is an enumerator for the active set:
         - perform a server request to update your local database
         - fetch the active set from your local database
         
         - inform the observer about the items returned by the server (possibly multiple times)
         - inform the observer that you are finished with this page
         */
        print("Asked to enumerate items for \(model) observer: \(observer) page: \(page) pageSize: \(String(describing: observer.suggestedPageSize))")
        
        enumerateTask = Task {
            print("Inside task enumerating items")
            guard let data = try? await XcodeReleasesFetcher.shared.data
            else {
                print("Do not have releases. Error?")
                //                observer.finishEnumeratingWithError(<#T##error: Error##Error#>)
                return
            }
            print("Have releases")
            let items: [FileProviderItem]
            switch model {
            case .root:
                items = data.releases
                    .compactMap{$0.version.number?.major}
                    .map(XcodeItem.versionMajor)
                    .map{FileProviderItem(model: $0, data: data)}
            case .versionMajor(let majorVersion):
                items = data.releases
                    .filter{$0.version.number?.major == majorVersion}
                    .map(\.version)
                    .map(XcodeItem.versionItem)
                    .map{FileProviderItem(model: $0, data: data)}

            case .versionItem(_):
                fatalError("Should not be enumerating inside the Xcode file")
            }
            print("Returning items to observer \(items.map(\.itemIdentifier))")
            observer.didEnumerate(items)
            observer.finishEnumerating(upTo: nil)
            print("Done returning items to observer \(items)")

        }
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        print("Asked for changes from \(anchor.rawValue)")

        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
        observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
    }

    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        print("Asked for sync anchor: \(String(data: anchor.rawValue, encoding: .utf8)!)")
        completionHandler(anchor)
    }
}
