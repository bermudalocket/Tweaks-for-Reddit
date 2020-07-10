//
//  WebViewRepresentable.swift
//  redditweaks
//  5.0
//  10.16
//
//  Created by bermudalocket on 6/28/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import SwiftUI
import WebKit

struct WebViewRepresentable: NSViewRepresentable {

    var url: URL?

    func makeNSView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.load(URLRequest(url: self.url!))
        return view
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        guard let url = self.url else { return }
        nsView.load(URLRequest(url: url))
    }

    typealias NSViewType = WKWebView

}
