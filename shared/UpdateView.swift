//
//  UpdateView.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/4/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct UpdateView: View {

    @StateObject private var updateHelper: UpdateHelper = UpdateHelper()

    private var icon: some View {
        if updateHelper.updateIsAvailable {
            return Image(systemName: "exclamationmark.circle")
                .foregroundColor(.orange)
                .imageScale(.large)
        } else {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(.gray)
                .imageScale(.large)
        }
    }

    private var headline: String {
        if updateHelper.isCheckingForUpdate {
            return "Checking for update..."
        } else {
            if updateHelper.updateIsAvailable {
                return "An update is available"
            } else {
                return "You're up to date"
            }
        }
    }

    private var subheadline: String? {
        if !updateHelper.isCheckingForUpdate && !updateHelper.updateIsAvailable {
            return lastCheckedForUpdateDescriptor
        }
        return nil
    }

    private var lastCheckedForUpdateDescriptor: String {
        if updateHelper.lastCheckedForUpdate == -1 {
            updateHelper.pollUpdate(forced: true)
            return "Checking..."
        }
        let date = Date(timeIntervalSince1970: updateHelper.lastCheckedForUpdate)
        return "Last checked: \(DateFormatter.relativeShort.string(from: date))"
    }

    var body: some View {
        HStack {
            if updateHelper.isCheckingForUpdate {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.small)
                    .padding(5)
            } else {
                icon
            }
            VStack(alignment: .leading) {
                Text(headline)
                    .bold()
                    .font(.callout)
                if let subheadline = subheadline {
                    Text(subheadline)
                        .font(.footnote)
                }
            }
            .foregroundColor(.gray)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            updateHelper.pollUpdate(forced: true)
        }
        .onAppear {
            updateHelper.pollUpdate()
        }
    }
}

struct UpdateView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateView()
    }
}
