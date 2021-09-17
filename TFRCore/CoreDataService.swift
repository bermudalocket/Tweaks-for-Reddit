//
//  CoreDataService.swift
//  TFRCore
//
//  Created by Michael Rippe on 2/15/21.
//

import Combine
import CoreData

public class CoreDataService: ObservableObject {

    public static let shared = CoreDataService(inMemory: false)

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        let bundle = Bundle.allFrameworks.first { $0.bundleIdentifier == "com.bermudalocket.TFRCore" }
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
            log("NSPersistentContainer successfully created, persistent stores loaded.")
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        self.container = container
    }

    public var favoriteSubreddits: [FavoriteSubreddit] {
        do {
            let request = NSFetchRequest<FavoriteSubreddit>(entityName: "FavoriteSubreddit")
            return try container.viewContext.fetch(request)
        } catch {
            logError("Failed to fetch favorite subreddits: \(error)")
            return []
        }
    }

    public func userKarma(for user: String) -> Int? {
        let request = NSFetchRequest<KarmaMemory>(entityName: "KarmaMemory")
        request.predicate = NSPredicate(format: "user = %@", user)
        do {
            return try container.viewContext
                .fetch(request)
                .map(\.karma)
                .compactMap { Int($0) }
                .reduce(0, +) // i love swift so much
        } catch {
            logError("Failed to fetch user karma for user \(user): \(error)")
            return nil
        }
    }

    public func saveUserKarma(for user: String, karma: Int) {
        let newKarma = KarmaMemory(context: container.viewContext)
        newKarma.user = user
        newKarma.karma = Int64(karma)
        do {
            try container.viewContext.save()
        } catch {
            logError("Error saving user karma: \(error)")
        }
    }

    public func commentCount(for thread: String) -> Int? {
        let request = NSFetchRequest<ThreadCommentCount>(entityName: "ThreadCommentCount")
        request.predicate = NSPredicate(format: "thread = %@", thread)
        request.sortDescriptors = [
            .init(keyPath: \ThreadCommentCount.timestamp, ascending: false)
        ]
        request.fetchLimit = 1
        do {
            return try container.viewContext.fetch(request).map(\.count).first
        } catch {
            logError("Failed to fetch comment count for thread \(thread): \(error)")
            return nil
        }
    }

    public func saveCommentCount(for thread: String, count: Int) {
        let threadCommentCount = ThreadCommentCount(context: container.viewContext)
        threadCommentCount.thread = thread
        threadCommentCount.count = count
        threadCommentCount.timestamp = Date()
        do {
            try container.viewContext.save()
        } catch {
            logError("Failed to save comment count: \(error)")
        }
    }

}
