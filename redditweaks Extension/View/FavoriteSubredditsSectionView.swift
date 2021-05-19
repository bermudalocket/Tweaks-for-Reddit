//
//  FavoriteSubredditsSectionView.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/9/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Combine
import SwiftUI

// TODO
// https://stackoverflow.com/questions/60454752/swiftui-background-color-of-list-mac-os
extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView?.drawsBackground = false
  }
}

class SubredditVerifier: ObservableObject {

    @Published var subreddit = ""
    @Published var isSearching = false
    @Published var isValid = false
    private var cancellables = [AnyCancellable]()

    func verify() {
        isSearching = true
        let url = URL(string: "https://www.reddit.com/r/\(subreddit)")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in
                guard let res = response as? HTTPURLResponse, res.statusCode == 200,
                      let decodedData = String(data: data, encoding: .utf8)
                else {
                    return false
                }
                return !decodedData.contains("there doesn't seem to be anything here")
            }
            .replaceError(with: false)
            .receive(on: DispatchQueue.main)
            .sink { [self] result in
                isSearching = false
                isValid = result
                if result {
                    let vc = PersistenceController.shared.container.viewContext
                    let fetch = NSFetchRequest<FavoriteSubreddit>(entityName: "FavoriteSubreddit")
                    let count = (try? vc.fetch(fetch))?.count ?? 0
                    let sub = FavoriteSubreddit(context: vc)
                    sub.name = subreddit
                    sub.position = Int16(count)
                    subreddit = ""
                }
            }
            .store(in: &cancellables)
    }

}

struct FavoriteSubredditsSectionView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var appState: AppState

    @StateObject private var subVerifier = SubredditVerifier()

    @State private var favoriteSubredditField = ""

    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \FavoriteSubreddit.position, ascending: true),
        NSSortDescriptor(keyPath: \FavoriteSubreddit.name, ascending: true)
    ]) private var favoriteSubreddits: FetchedResults<FavoriteSubreddit>

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                if subVerifier.isSearching {
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle())
                } else {
                    TextField("r/", text: $favoriteSubredditField) { _ in
                    } onCommit: {
                        if favoriteSubredditField == "" { return }
                        subVerifier.subreddit = favoriteSubredditField
                        if !favoriteSubreddits.compactMap(\.name).contains(subVerifier.subreddit) {
                            subVerifier.verify()
                        }
                    }
                    .foregroundColor(subVerifier.isValid ? .black : .red)
                    .onReceive(subVerifier.$subreddit) { favoriteSubredditField = $0 }
                }
            }
            List {
                ForEach(favoriteSubreddits, id: \.self) {
                    FavoriteSubredditView(subreddit: $0)
                }
                .onMove(perform: onMove)
            }
            .listStyle(PlainListStyle())
            .frame(height: min(CGFloat(appState.favoriteSubredditListHeight.rawValue), 25 * CGFloat(favoriteSubreddits.count)))
        }
    }

    private func onMove(indices: IndexSet, newOffset: Int) {
        guard let oldOffset = indices.first else {
            return
        }
        let sub = favoriteSubreddits[oldOffset]
        sub.position = Int16(newOffset)
    }

}

struct FavoriteSubredditsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteSubredditsSectionView()
            .environmentObject(AppState.preview)
    }
}
