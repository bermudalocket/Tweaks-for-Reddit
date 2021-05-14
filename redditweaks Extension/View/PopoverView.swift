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

    private var binding: Binding<Bool> {
        appState.bindingForFeature(.liveCommentPreview)
    }

    var body: some View {
        VStack(spacing: 10) {
            TitleView()
                .padding(.vertical)
                .background(SectionBackgroundView())

            FeaturesListView()
                .environmentObject(appState)

            if IAPHelper.shared.canMakePayments {
                GroupBox(label: Text("In-App Purchases")) {
                    Toggle("Live preview comments in markdown", isOn: binding)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .onChange(of: binding.wrappedValue) { value in
                            if value && !IAPHelper.shared.purchasedLiveCommentPreviews {
                                NSWorkspace.shared.open(URL(string: "rdtwks://iap")!)
                                binding.wrappedValue = false
                            }
                        }
                }

            }

            SettingsView()

        }
        .padding(10)
        .frame(width: 325, alignment: .top)
        .onDisappear {
            do {
                if viewContext.hasChanges {
                    try viewContext.save()
                }
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
