//
//  WhatsNewView.swift
//  WhatsNewView
//
//  Created by Michael Rippe on 9/2/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import TFRCore

public struct WhatsNewView: View {

    @Binding var isPresented: Bool

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    func item(title: String, description: String, symbol: String) -> some View {
        HStack(alignment: .center) {
            Image(systemName: symbol)
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundColor(.redditOrange)
                .frame(width: 30)
                .padding(5)
            (Text(title).font(.headline)
             + Text("\n\(description)"))
                .frame(width: 300)
        }
    }

    public var body: some View {
        VStack {
            Text("What's New?")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.top)
                .frame(width: 300)
            Text("Tweaks for Reddit v\(TweaksForReddit.version)")
                .font(.callout)
                .foregroundColor(.gray)
                .padding(.bottom)

            VStack(alignment: .leading, spacing: 10) {
                self.item(
                    title: "Menu bar access",
                    description: "TFR now lives in your menu bar providing quick access to your favorite subreddits.",
                    symbol: "menubar.arrow.up.rectangle"
                )
            }
            Button("Cool!   \(Image(systemName: "checkmark"))") {
                isPresented = false
                TweaksForReddit.defaults.set(TweaksForReddit.version, forKey: "lastWhatsNewVersion")
            }
            .buttonStyle(RedditweaksButtonStyle())
            .padding(.top, 30)
        }
        .frame(width: 400, height: 300)
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(isPresented: .constant(true))
    }
}
