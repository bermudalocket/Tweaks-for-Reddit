//
//  SafariToolbarView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/20/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct SafariToolbarView: View {

    @Environment(\.colorScheme) private var colorScheme

    private var background: Color {
        switch colorScheme {
            case .light: return Color(red: 0.933, green: 0.913, blue: 0.918, opacity: 1.0)
            case .dark: return Color(red: 0.213, green: 0.179, blue: 0.188, opacity: 1.0)
            @unknown default:
                return Color(red: 0.933, green: 0.913, blue: 0.918, opacity: 1.0)
        }
    }

    private var urlBar: Color {
        switch colorScheme {
            case .light: return Color(red: 0.882, green: 0.862, blue: 0.867, opacity: 1.0)
            case .dark: return Color(red: 0.264, green: 0.23, blue: 0.239, opacity: 1.0)
            @unknown default:
                return Color(red: 0.882, green: 0.862, blue: 0.867, opacity: 1.0)
        }
    }

    private var refresh: Color {
        switch colorScheme {
            case .light: return Color(red: 0.449, green: 0.439, blue: 0.443, opacity: 1.0)
            case .dark: return Color(red: 0.891, green: 0.886, blue: 0.886, opacity: 1.0)
            @unknown default:
                return Color(red: 0.449, green: 0.439, blue: 0.443, opacity: 1.0)
        }
    }

    @State private var isShowingPopover = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(background)
                .frame(height: 52)
            HStack {
                ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(urlBar)
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(refresh)
                            .padding(.trailing, 10)
                            .opacity(0.75)
                    }
                }
                Image("Icon")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .padding(.leading, 10)
                    .onTapGesture {
                        isShowingPopover.toggle()
                    }
                    .popover(isPresented: $isShowingPopover) {
                        ArtPopoverView()
                    }
            }
            .frame(height: 28)
            .offset(x: -250, y: 0)
        }
    }
}

struct SafariToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        SafariToolbarView()
            .frame(width: 700, height: 400)
    }
}
