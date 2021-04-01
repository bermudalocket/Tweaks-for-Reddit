//
//  PopoverView.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/6/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Combine
import SwiftUI

struct PopoverView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 10) {
            TitleView()
                .padding(.vertical)
                .background(SectionBackgroundView())

            FeaturesListView()
                .environmentObject(appState)

            SettingsView()

            if !Redditweaks.isFromMacAppStore {
                UpdateView()
            }
        }
        .padding(10)
        .frame(width: 300, alignment: .top)
        .onDisappear {
            do {
                print("- Saving to CoreData...")
                try PersistenceController.shared.container.viewContext.save()
                print("- Saved!")
            } catch {
                print("- Error saving to CoreData store: \(error)")
            }
        }
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
            .environmentObject(AppState.preview)
    }
}
