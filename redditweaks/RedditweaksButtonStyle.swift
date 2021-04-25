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
        configuration
            .label
            .font(.system(.headline))
            .foregroundColor(.blue)
            .padding(.horizontal, 20)
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .foregroundColor(.primary)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1)
                    .animation(.easeInOut)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
            )
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
