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

    @EnvironmentObject private var iapHelper: IAPHelper

    @EnvironmentObject private var appState: AppState

    @State private var isCheckingInAppPurchase = false

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
                    if isCheckingInAppPurchase {
                        ProgressView()
                            .scaleEffect(0.5)
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    } else {
                        Toggle("Live preview comments in markdown", isOn: binding)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .onChange(of: appState.bindingForFeature(.liveCommentPreview).wrappedValue) { value in
                                isCheckingInAppPurchase = true
                                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
                                    if value && !PersistenceController.shared.iapState.livecommentpreviews {
                                        NSWorkspace.shared.open(URL(string: "rdtwks://iap")!)
                                        binding.wrappedValue = false
                                    }
                                    isCheckingInAppPurchase = false
                                }
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
