//
//  PopoverView.swift
//  Tweaks for Reddit Extension
//  5.0
//  10.16
//
//  Created by Michael Rippe on 7/6/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import Combine
import SwiftUI

struct PopoverView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var iapHelper: IAPHelper
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

            if iapHelper.canMakePayments {
                GroupBox(label: Text("In-App Purchases")) {
                    Toggle("Live preview comments in markdown", isOn: binding)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .onChange(of: binding.wrappedValue) { value in
                            if value && !iapHelper.didPurchaseLiveCommentPreviews {
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
            if viewContext.hasChanges {
                try? viewContext.save()
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
