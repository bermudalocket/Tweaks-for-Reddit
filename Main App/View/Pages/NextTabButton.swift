//
//  NextTabButton.swift
//  NextTabButton
//
//  Created by Michael Rippe on 8/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct NextTabButton: View {

    @EnvironmentObject private var store: MainAppStore

    var body: some View {
        Button(action: {
            store.send(.nextTab)
        }, label: {
            Text("Next \(Image(systemName: "arrow.right"))")
        })
        .buttonStyle(RedditweaksButtonStyle())
    }
}

struct NextTabButton_Previews: PreviewProvider {
    static var previews: some View {
        NextTabButton()
    }
}
