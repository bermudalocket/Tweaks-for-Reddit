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

    private var cancellables = Set<AnyCancellable>()

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
            self.cancellables.forEach { $0.cancel() }
            Redditweaks.verifySubredditExists(newValue)
                .receive(on: DispatchQueue.main)
                .print()
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .failure: self.isSubredditValid = false
                        case .finished: break
                    }
                    self.isSearching = false
                }, receiveValue: { value in
                    self.isSubredditValid = value
                })
                .store(in: &cancellables)
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
                        Redditweaks.addFavoriteSubreddit(self.viewModel.newFavoriteSubredditField)
                    }
                    .opacity(self.viewModel.isSearching ? 0 : 1)
                    .disabled(!self.viewModel.isSubredditValid)
                    SpinnerView()
                        .opacity(self.viewModel.isSearching ? 1 : 0)
                }
            }
            ScrollView(.vertical) {
                ForEach(viewModel.favoriteSubreddits, id: \.self) {
                    FavoriteSubredditView(favoriteSubreddit: $0)
                }
            }.frame(maxHeight: 70)
        }
        .onReceive(Redditweaks.favoriteSubredditsPublisher) { favs in
            self.viewModel.favoriteSubreddits = favs
        }
    }
}
