//
//  Persistence.swift
//  fud
//
//  Created by Michael Rippe on 2/15/21.
//

import CoreData

extension CoreDataService {
    public static let live = CoreDataService()
    public static let mock = CoreDataService(inMemory: true)
}

public class CoreDataService {

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        let bundle = Bundle.allFrameworks.first { $0.bundleIdentifier == "com.bermudalocket.Tweaks-for-Reddit-Core" }
        let url = bundle!.url(forResource: "Tweaks for Reddit", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!

        let container = NSPersistentContainer(name: "Tweaks for Reddit", managedObjectModel: model)
        container.persistentStoreDescriptions.forEach {
            if inMemory {
                $0.url = URL(fileURLWithPath: "/dev/null")
            } else {
                $0.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                $0.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                $0.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.bermudalocket.redditweaks")
            }
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("\(error)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        self.container = container
    }

    public var favoriteSubreddits: [FavoriteSubreddit] {
        (try? container.viewContext.fetch(FavoriteSubreddit.fetchRequest())) ?? []
    }

    public var iapState: IAPState? {
        let req = NSFetchRequest<IAPState>(entityName: "IAPState")
        req.sortDescriptors = [ NSSortDescriptor(keyPath: \IAPState.timestamp, ascending: false) ]
        return try? container.viewContext.fetch(req).first
    }

    public func userKarma(for user: String) -> Int? {
        let request = NSFetchRequest<KarmaMemory>(entityName: "KarmaMemory")
        request.predicate = NSPredicate(format: "user = %@", user)
        return try? container.viewContext
            .fetch(request)
            .map(\.karma)
            .compactMap { Int($0) }
            .reduce(0, +) // i love swift so much
    }

    public func saveUserKarma(for user: String, karma: Int) {
        let newKarma = KarmaMemory(context: container.viewContext)
        newKarma.user = user
        newKarma.karma = Int64(karma)
        try? container.viewContext.save()
    }

    public func commentCount(for thread: String) -> Int? {
        let request = NSFetchRequest<ThreadCommentCount>(entityName: "ThreadCommentCount")
        request.predicate = NSPredicate(format: "thread = %@", thread)
        request.sortDescriptors = [
            .init(keyPath: \ThreadCommentCount.timestamp, ascending: false)
        ]
        request.fetchLimit = 1
        return try? container.viewContext.fetch(request).map(\.count).first
    }

    public func saveCommentCount(for thread: String, count: Int) {
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

}
