//
//  Persistence.swift
//  fud
//
//  Created by Michael Rippe on 2/15/21.
//

import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Tweaks for Reddit")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.persistentStoreDescriptions.forEach {
            $0.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.bermudalocket.redditweaks")
        }
        container.loadPersistentStores { [self] storeDescription, error in
            if let error = error as NSError? {
                fatalError("- Unresolved error loading persistent store: \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }

    var favoriteSubreddits: [String] {
        let request = NSFetchRequest<FavoriteSubreddit>(entityName: "FavoriteSubreddit")
        return (try? container.viewContext
            .fetch(request)
            .compactMap(\.name)
            .sorted()) ?? []
    }

    var iapState: IAPState {
        let request = NSFetchRequest<IAPState>(entityName: "IAPState")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \IAPState.timestamp, ascending: false)
        ]
        guard let results = try? self.container.viewContext.fetch(request), let result = results.first else {
            let initialState = IAPState(context: self.container.viewContext)
            initialState.timestamp = Date()
            initialState.livecommentpreviews = false
            try? self.container.viewContext.save()
            return initialState
        }
        return result
    }

}
