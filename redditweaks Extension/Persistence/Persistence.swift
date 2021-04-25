//
//  Persistence.swift
//  fud
//
//  Created by Michael Rippe on 2/15/21.
//

import CoreData

struct PersistenceController {

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Tweaks for Reddit")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("- Unresolved error loading persistent store: \(error), \(error.userInfo)")
            }
        }
    }

    func getFavoriteSubreddits() -> [String]? {
        let request = NSFetchRequest<FavoriteSubreddit>(entityName: "FavoriteSubreddit")
        return try? container.viewContext
            .fetch(request)
            .compactMap(\.name)
            .sorted()
    }

}

extension PersistenceController {

    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let favoriteSub = FavoriteSubreddit(context: viewContext)
        favoriteSub.name = "macOS"

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

}
