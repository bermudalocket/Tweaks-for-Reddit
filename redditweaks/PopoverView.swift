//
//  ScriptsView.swift
//  redditweaks
//
//  Created by Michael Rippe on 1/10/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import SwiftUI

@available(OSX 10.15, *)
struct PopoverView: View {

    @State private var hideAd = false
    @State private var filter = false
        @State private var allFilter = false
        @State private var homeFilter = false
        @State private var subsFilter = false
    @State private var detectScripts = true
    @State private var scripts: [String] = [String]()

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Text("redditweaks").font(.largeTitle).fontWeight(.heavy)
                    Spacer()
                }
                Text("by bermudalocket (1.1.0-SwiftUI)").font(.caption)
            }
            Toggle(isOn: self.$hideAd, label: {
                Text("Hide Reddit premium ads")
            }).padding(.top, 4)
            Toggle(isOn: self.$filter, label: {
                Text("Filter NSFW content")
            }).padding(.top)
            HStack {
                Toggle(isOn: self.$allFilter, label: {
                    Text("r/All").foregroundColor(self.filter ? .black : .gray)
                })
                .disabled(self.filter)
                Toggle(isOn: self.$homeFilter, label: {
                    Text("Home").foregroundColor(self.filter ? .black : .gray)
                })
                .disabled(self.filter)
                Toggle(isOn: self.$subsFilter, label: {
                    Text("Subreddits").foregroundColor(self.filter ? .black : .gray)
                })
                .disabled(self.filter)
            }
            Toggle(isOn: self.$detectScripts, label: {
                Text("Detect scripts")
            })
            .padding(.top)
            Spacer()
        }
        .frame(width: 250, height: 450)
        .padding()
    }
}

@available(OSX 10.15, *)
struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
    }
}
