//
//  SpinnerView.swift
//  redditweaks
//  5.0
//  10.16
//
//  Created by bermudalocket on 6/28/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import SwiftUI

struct SpinnerView: NSViewRepresentable {

    func makeNSView(context: Context) -> NSProgressIndicator {
        let progress = NSProgressIndicator()
        progress.isIndeterminate = true
        return progress
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
        nsView.isIndeterminate = true
    }

    typealias NSViewType = NSProgressIndicator

}
