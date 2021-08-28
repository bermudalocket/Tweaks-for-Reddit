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

    @State private var isHovered = false

    private var textColor: Color {
        if isEnabled {
            return isHovered ? Color(.highlightColor) : Color(.windowBackgroundColor)
        }
        return Color(.placeholderTextColor)
    }

    private func calculateScale(with configuration: Configuration) -> CGFloat {
        var scale: CGFloat = 1.0
        if isEnabled {
            if configuration.isPressed { scale -= 0.1 }
        }
        return scale
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3).bold())
            .padding(10)
            .foregroundColor(textColor)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(isEnabled ? .redditOrange : Color(.disabledControlTextColor))
            )
            .onHover { isHovered = $0 }
            .scaleEffect(calculateScale(with: configuration))
            .animation(.linear)
    }

}

// swiftlint:disable:next type_name
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
