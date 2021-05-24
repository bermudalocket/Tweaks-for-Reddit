//
//  OnboardingEnvironment.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Foundation.NSTimer
import SafariServices.SFSafariExtensionManager
import Combine

class OnboardingEnvironment: ObservableObject {

    @Published var isSafariExtensionEnabled = false

    var cancellables = [AnyCancellable]()

    init() {
        // Safari extension checker
        Timer.publish(every: 1, tolerance: 1, on: .main, in: .common, options: nil)
            .autoconnect()
            .receive(on: RunLoop.main)
            .zip(
                Future { promise in
                    SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: "com.bermudalocket.redditweaks.extension") { (state, error) in
                        promise(.success((state, error)))
                    }
                }
            )
            .sink { _, safariResponse in
                guard let state = safariResponse.0, safariResponse.1 == nil else {
                    print("Error fetching extension state: \(safariResponse.1?.localizedDescription ?? "(no description)")")
                    return
                }
                if state.isEnabled != self.isSafariExtensionEnabled {
                    self.isSafariExtensionEnabled = state.isEnabled
                }
            }.store(in: &cancellables)
    }

    deinit {
        self.cancellables.forEach { $0.cancel() }
    }

}
