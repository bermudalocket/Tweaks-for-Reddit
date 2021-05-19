//
//  RedditweaksButtonStyle.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

extension Color {
    public static let redditOrange = Color(red: 1, green: 86.0/255.0, blue: 0.0)
}

struct RedditweaksButtonStyle: ButtonStyle {

    @Environment(\.colorScheme) private var colorScheme

    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.title3)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.accentColor)
            )
            .scaleEffect(configuration.isPressed || isHovering ? 0.9 : 1.0)
            .animation(.linear)
            .contentShape(Rectangle())
            .onHover { self.isHovering = $0 }
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
