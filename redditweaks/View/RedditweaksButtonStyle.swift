//
//  Tweaks for RedditButtonStyle.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

struct RedditweaksButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) private var isEnabled

    @State private var isHovering = false

    private func calculateScale(with configuration: Configuration) -> CGFloat {
        var scale: CGFloat = 1.0
        if isEnabled {
            if configuration.isPressed { scale -= 0.4 }
            if isHovering { scale -= 0.05 }
        }
        return scale
    }

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
            .scaleEffect(calculateScale(with: configuration))
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
