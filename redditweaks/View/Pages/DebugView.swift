//
//  DebugView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/15/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import CloudKit

extension NSManagedObjectModel {
    func isActive(url: URL) -> Bool {
        NSManagedObjectModel(contentsOf: url)?.isEqual(to: self) ?? false
    }
}

struct DebugView: View {

    @EnvironmentObject private var iapHelper: IAPHelper

    private var coreDataModelId: String {
        PersistenceController.shared.container.managedObjectModel.versionIdentifiers.first as? String ?? "N/A"
    }

    private var coreDataModelName: String {
        var paths = [String]()
        Bundle.main.urls(forResourcesWithExtension: "momd", subdirectory: nil)?.forEach { url in
            Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: url.lastPathComponent)?.forEach { path in
                if PersistenceController.shared.container.managedObjectModel.isActive(url: path) {
                    paths.append(path.lastPathComponent.replacingOccurrences(of: ".mom", with: ""))
                }
            }
        }
        return paths.joined()
    }

    private var numberOfPermalinks: Int {
        let req = NSFetchRequest<SeenPermalink>(entityName: "SeenPermalink")
        guard let results = try? PersistenceController.shared.container.viewContext.fetch(req) else {
            return -2
        }
        return results.count
    }

    private var numberOfFavoriteSubreddits: Int {
        let req = NSFetchRequest<FavoriteSubreddit>(entityName: "FavoriteSubreddit")
        guard let results = try? PersistenceController.shared.container.viewContext.fetch(req) else {
            return -2
        }
        return results.count
    }

    private var columns: [GridItem] = [
        .init(GridItem.Size.fixed(150), spacing: 10, alignment: .leading),
        .init(GridItem.Size.flexible(minimum: 10, maximum: 250), alignment: .leading)
    ]

    @State private var iCloudAvailable = false
    @State private var isLiveCommentPreviewsAvailable = false

    var body: some View {
        LazyVGrid(columns: columns) {
            Text("iCloud Connected").bold()
            Text(iCloudAvailable ? "Yes" : "No")

            Text("CoreData Model ID").bold()
            Text(coreDataModelId)

            Text("CoreData Model").bold()
            Text(coreDataModelName)

            Text("Live Comment Previews").bold()
            Text("\(isLiveCommentPreviewsAvailable ? "Yes" : "No")")

            Text("Favorite Subreddits").bold()
            Text("\(numberOfFavoriteSubreddits)")
        }.onReceive(PersistenceController.shared.state.$isReady) { ready in
            self.iCloudAvailable = ready
        }.onReceive(iapHelper.$purchasedLiveCommentPreviews) { state in
            self.isLiveCommentPreviewsAvailable = state
        }
    }

}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
            .padding()
            .environmentObject(IAPHelper.shared)
    }
}
