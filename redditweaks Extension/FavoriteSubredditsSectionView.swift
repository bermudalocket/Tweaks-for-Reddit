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

class FavoriteSubredditsSectionViewModel: ObservableObject {

    @Published var favoriteSubreddits: [String] = Redditweaks.favoriteSubreddits

    @Published var isSubredditValid = false

    var isSearching = false

    private var cancelBag = CancelBag()

    var textFieldColor: Color {
        if isSearching {
            return .gray
        }
        if !isSubredditValid {
            if newFavoriteSubredditField == "r/" {
                return .gray
            }
            return .red
        }
        return Color(.textColor)
    }

    var newFavoriteSubredditField: String = "r/" {
        willSet(newValue) {
            self.isSearching = true
            self.objectWillChange.send()
            print("newValue = \(newValue)")
            if newValue == "" || newValue == "r" {
                self.newFavoriteSubredditField = "r/"
                self.objectWillChange.send()
                return
            }
            cancelBag.forEach { $0.cancel() }
            cancelBag.collect {
                Redditweaks.verifySubredditExists(newValue)
                    .receive(on: DispatchQueue.main)
                    .print()
                    .sink { completion in
                        switch completion {
                            case .failure: self.isSubredditValid = false
                            case .finished: break
                        }
                        self.isSearching = false
                    } receiveValue: { value in
                        self.isSubredditValid = value
                    }
            }
        }
    }

}

struct FavoriteSubredditsSectionView: View {

    @ObservedObject private var viewModel = FavoriteSubredditsSectionViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            FeatureToggleView(feature: Feature.customSubredditBar)
            HStack {
                TextField("r/", text: $viewModel.newFavoriteSubredditField)
                    .foregroundColor(self.viewModel.isSubredditValid ? .black : .red)
                ZStack {
                    Button("Add") {
                        Redditweaks.addFavoriteSubreddit(viewModel.newFavoriteSubredditField)
                    }
                        .opacity(self.viewModel.isSearching ? 0 : 1)
                        .disabled(!self.viewModel.isSubredditValid)
                    if #available(OSXApplicationExtension 10.16, *) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .controlSize(.small)
                            .opacity(self.viewModel.isSearching ? 1 : 0)
                    } else {
                        SpinnerView()
                            .opacity(self.viewModel.isSearching ? 1 : 0)
                    }
                }
            }
            ForEach(viewModel.favoriteSubreddits, id: \.self) {
                FavoriteSubredditView(favoriteSubreddit: $0)
            }
        }
        .onReceive(Redditweaks.favoriteSubredditsPublisher) { favs in
            self.viewModel.favoriteSubreddits = favs
        }
    }
}
