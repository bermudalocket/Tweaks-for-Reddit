//
//  DebugView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/15/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import CloudKit
import Combine
import SwiftUI

extension NSManagedObjectModel {
    func isActive(url: URL) -> Bool {
        NSManagedObjectModel(contentsOf: url)?.isEqual(to: self) ?? false
    }
}

struct DebugView: View {

    // periphery:ignore
    @Environment(\.managedObjectContext) private var managedObjectContext

    @AppStorage("didPurchaseLiveCommentPreviews", store: Redditweaks.defaults)
    private var didPurchaseLiveCommentPreviews = false

    @FetchRequest<FavoriteSubreddit>(entity: FavoriteSubreddit.entity(), sortDescriptors: [])
    private var favoriteSubreddits: FetchedResults<FavoriteSubreddit>

    @FetchRequest<ThreadCommentCount>(entity: ThreadCommentCount.entity(), sortDescriptors: [])
    private var threadCommentCounts: FetchedResults<ThreadCommentCount>

    @FetchRequest<KarmaMemory>(entity: KarmaMemory.entity(), sortDescriptors: [])
    private var karmaMemories: FetchedResults<KarmaMemory>

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

    private var threadCommentCountSize: Double {
        self.threadCommentCounts.lazy.reduce(into: 0) { agg, next in
            agg += Double(class_getInstanceSize(type(of: next)))
        } / 1_024
    }

    private var karmaMemorySize: Double {
        self.karmaMemories.lazy.reduce(into: 0) { agg, next in
            agg += Double(class_getInstanceSize(type(of: next)))
        } / 1_024
    }

    private var favoriteSubsSize: Double {
        self.favoriteSubreddits.lazy.reduce(into: 0) { agg, next in
            agg += Double(class_getInstanceSize(type(of: next)))
        } / 1_024
    }

    private let columns: [GridItem] = [
        .init(.fixed(175), spacing: 10, alignment: .trailing),
        .init(.fixed(400), spacing: 10, alignment: .leading),
    ]

    private var formatter: NumberFormatter {
        let fmt = NumberFormatter()
        fmt.maximumSignificantDigits = 3
        return fmt
    }

    var body: some View {
        VStack(spacing: 30) {
            LazyVGrid(columns: columns) {
                Group {
                    Text("iCloud Connected").bold()
                    Text("Yes") // always, apparently

                    Text("CoreData Model ID").bold()
                    Text(coreDataModelId)

                    Text("CoreData Model").bold()
                    Text(coreDataModelName)

                    Text("Live Comment Previews").bold()
                    Text("\(didPurchaseLiveCommentPreviews ? "Yes" : "No")")
                }
                Group {
                    Text("Favorite Subreddits").bold()
                    Text("\(favoriteSubreddits.count), totaling \(formatter.string(from: NSNumber(value: favoriteSubsSize))!) Kb")

                    Text("Karma Memories").bold()
                    Text("\(karmaMemories.count), totaling \(formatter.string(from: NSNumber(value: karmaMemorySize))!) Kb")

                    Text("Thread Comment Counts").bold()
                    Text("\(threadCommentCounts.count), totaling \(formatter.string(from: NSNumber(value: threadCommentCountSize))!) Kb")
                }
            }
        }
    }

}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DebugView()
                .environment(\.colorScheme, .light)
            DebugView()
                .environment(\.colorScheme, .dark)
        }.padding()
    }
}
