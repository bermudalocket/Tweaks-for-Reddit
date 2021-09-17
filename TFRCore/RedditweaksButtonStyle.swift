//
//  Tweaks for RedditButtonStyle.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

public struct RedditweaksButtonStyle: ButtonStyle {

    @Environment(\.colorScheme) private var colorScheme

    @Environment(\.isEnabled) private var isEnabled

    @State private var isHovered = false

    private var textColor: Color {
        if isEnabled {
            return isHovered ? Color(.windowBackgroundColor) : .white
        }
        return Color(.placeholderTextColor)
    }

    private func calculateScale(with configuration: Configuration) -> CGFloat {
        var scale: CGFloat = 1.0
        if isEnabled {
            if configuration.isPressed {
                scale -= 0.1
            } else if isHovered {
                scale -= 0.05
            }
        }
        return scale
    }

    public init() { }

    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.system(.title3).bold())
            .padding(10)
            .foregroundColor(textColor)
            .transition(.opacity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(isEnabled ? .redditOrange : Color(.disabledControlTextColor))
                    .transition(.opacity)
            )
            .onHover { isHovered in
                withAnimation(.easeInOut) {
                    self.isHovered = isHovered
                }
            }
            .scaleEffect(calculateScale(with: configuration))
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
