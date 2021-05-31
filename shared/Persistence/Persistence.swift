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
//            try? container.initializeCloudKitSchema(options: .printSchema)
        }
    }

    var favoriteSubreddits: [String] {
        let request = NSFetchRequest<FavoriteSubreddit>(entityName: "FavoriteSubreddit")
        return (try? container.viewContext
            .fetch(request)
            .compactMap(\.name)
            .sorted()) ?? []
    }

    func userKarma(for user: String) -> Int? {
        let request = NSFetchRequest<KarmaMemory>(entityName: "KarmaMemory")
        request.predicate = NSPredicate(format: "user = %@", user)
        return try? container.viewContext
            .fetch(request)
            .map(\.karma)
            .compactMap { Int($0) }
            .reduce(into: 0) { agg, next in agg += next }
    }

    func saveUserKarma(for user: String, karma: Int) {
        let newKarma = KarmaMemory(context: container.viewContext)
        newKarma.user = user
        newKarma.karma = Int64(karma)
        try? container.viewContext.save()
    }

    func commentCount(for thread: String) -> Int? {
        let request = NSFetchRequest<ThreadCommentCount>(entityName: "ThreadCommentCount")
        request.predicate = NSPredicate(format: "thread = %@", thread)
        request.sortDescriptors = [
            .init(keyPath: \ThreadCommentCount.timestamp, ascending: false)
        ]
        request.fetchLimit = 1
        return try? container.viewContext.fetch(request).map(\.count).first
    }

    func saveCommentCount(for thread: String, count: Int) {
        let threadCommentCount = ThreadCommentCount(context: container.viewContext)
        threadCommentCount.thread = thread
        threadCommentCount.count = count
        threadCommentCount.timestamp = Date()
        do {
            try container.viewContext.save()
        } catch {
            print("Error: \(error)")
        }
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
