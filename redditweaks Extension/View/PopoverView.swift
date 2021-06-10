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

    @EnvironmentObject private var appState: AppState

    private var liveCommentPreviewBinding: Binding<Bool> {
        appState.bindingForFeature(.liveCommentPreview)
    }

    @AppStorage("didPurchaseLiveCommentPreviews") private var didPurchaseLiveCommentPreviews = false

    var body: some View {
        VStack(spacing: 10) {
            TitleView()
                .padding(.vertical)
                .background(SectionBackgroundView())

            FeaturesListView()

            if IAPHelper.shared.canMakePayments {
                Toggle("Live preview comments in markdown", isOn: liveCommentPreviewBinding)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .onChange(of: liveCommentPreviewBinding.wrappedValue) { value in
                        if value && !didPurchaseLiveCommentPreviews {
                            NSWorkspace.shared.open(URL(string: "rdtwks://iap")!)
                            liveCommentPreviewBinding.wrappedValue = false
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
