//
//  FileProviderExtension.swift
//  FileProvider
//
//  Created by Andrew Pouliot on 11/17/21.
//

import FileProvider

class FileProviderExtension: NSObject, NSFileProviderReplicatedExtension {
    
    private(set) var domain: NSFileProviderDomain
    
    required init(domain: NSFileProviderDomain) {
        print("Loaded extension for domain \(domain.identifier.rawValue)")
        self.domain = domain
        super.init()
    }
    
    func invalidate() {
        // TODO: cleanup any resources
        print("Asked to invalidate() for domain \(domain.identifier.rawValue)")
    }
    
    func item(for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) -> Progress {
        // resolve the given identifier to a record in the model
        
        print("Asked for item for identifier \(identifier.rawValue)")
        // TODO: implement the actual lookup
        
        do {
            let model = try XcodeItem(from: identifier)
            // TODO: relate progress to fetching the data! How??
            Task {
                let data = try await XcodeReleasesFetcher.shared.data
                completionHandler(FileProviderItem(model: model, data: data), nil)
            }
        } catch {
            completionHandler(nil, error)
        }
        
        return Progress()
    }
    
    func fetchContents(for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?, request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void) -> Progress {
        // TODO: implement fetching of the contents for the itemIdentifier at the specified version
        
        print("fetchContents for identifier \(itemIdentifier) at version \(requestedVersion?.description ?? "nil")")

        completionHandler(nil, nil, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func createItem(basedOn itemTemplate: NSFileProviderItem, fields: NSFileProviderItemFields, contents url: URL?, options: NSFileProviderCreateItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: a new item was created on disk, process the item's creation
        
        print("createItem for itemTemplate \(itemTemplate.filename)")

        completionHandler(itemTemplate, [], false, nil)
        return Progress()
    }
    
    func modifyItem(_ item: NSFileProviderItem, baseVersion version: NSFileProviderItemVersion, changedFields: NSFileProviderItemFields, contents newContents: URL?, options: NSFileProviderModifyItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: an item was modified on disk, process the item's modification
        
        completionHandler(nil, [], false, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func deleteItem(identifier: NSFileProviderItemIdentifier, baseVersion version: NSFileProviderItemVersion, options: NSFileProviderDeleteItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (Error?) -> Void) -> Progress {
        // TODO: an item was deleted on disk, process the item's deletion
        
        completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest) throws -> NSFileProviderEnumerator {
        print("Asked for enumerator for \(containerItemIdentifier.rawValue)")

        let item = try XcodeItem(from: containerItemIdentifier)
        print("Created enumerator for \(item)")
        return FileProviderEnumerator(model: item)
    }
}
