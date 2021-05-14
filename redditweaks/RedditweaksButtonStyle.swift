//
//  RedditweaksButtonStyle.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct RedditweaksButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
    }

}

struct RedditweaksButtonStyle_Preview: PreviewProvider {

    static var previews: some View {
        Button { } label: {
            Text("Preview")
        }
        .buttonStyle(RedditweaksButtonStyle())
        .padding()
        Button { } label: {
            Text("Preview")
        }
        .buttonStyle(RedditweaksButtonStyle())
        .disabled(true)
        .padding()
    }
}
