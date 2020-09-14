//
//  ViewController.swift
//  redditweaks2
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import Combine
import SwiftUI
import SafariServices
import WebKit

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
                    SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: "com.bermudalocket.redditweaks-Extension") { (state, error) in
                        promise(.success((state, error)))
                    }
                }
            )
            .sink { _, safariResponse in
                guard let state = safariResponse.0, safariResponse.1 == nil else {
                    let error = safariResponse.1
                    print("Error fetching extension state: \(error?.localizedDescription ?? "(no description)")")
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

struct MainAppView: View {

    @EnvironmentObject var onboardingEnvironment: OnboardingEnvironment

    var successIcon: some View {
        Image("checkmark.square.fill")
            .foregroundColor(.green)
            .font(.system(size: 28, weight: .regular, design: .rounded))
    }

    var body: some View {
        VStack {
            VStack {
                Image("Icon")
                Text("redditweaks").font(.largeTitle).fontWeight(.heavy)
            }.padding()
            VStack(spacing: 12) {
                Text("There's just one thing you have to do before you can get started.")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                  .foregroundColor(Color(.textBackgroundColor)))

                VStack {
                    HStack {
                        if onboardingEnvironment.isSafariExtensionEnabled {
                            self.successIcon
                        } else {
                            Image("1.square")
                                .font(.system(size: 28, weight: .regular, design: .rounded))
                        }
                        Text("Activate the extension")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Spacer()
                    }
                    Text("You have to manually activate the extension in Safari, otherwise we can't work our magic on Reddit.")
                    Button("Open in Safari") {
                        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.bermudalocket.redditweaks-Extension") {
                            if let error = $0 {
                                NSLog("Error opening Safari: \(error).")
                            }
                        }
                    }.disabled(onboardingEnvironment.isSafariExtensionEnabled)
                    .focusable()
                }.padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundColor(Color(.textBackgroundColor))
                )
            }
        }
        .frame(width: 300, height: 400)
        .padding()
        .background(Color(.windowBackgroundColor))
    }

}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainAppView()
                .environment(\.colorScheme, ColorScheme.dark)
                .environmentObject(OnboardingEnvironment())
            MainAppView()
                .environment(\.colorScheme, ColorScheme.light)
                .environmentObject(OnboardingEnvironment())
        }
    }
}
