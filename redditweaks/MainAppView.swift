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
    @Published var isPresentingRedditAuthView = false
    @Published var isRedditAuthorized = false
    @Published var isWaitingForRedditAuthToken = false

    var cancellables = [AnyCancellable]()

    init() {
        // check to see if we already have a valid token
        Reddit.checkIfTokenIsValid(token: RedditAuthState.shared.accessToken)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure(let error):
                        print("Error: \(error)")
                        Reddit.refreshAccessToken(RedditAuthState.shared.accessToken.refreshToken)
                    case .finished: print("finished")
                }
            } receiveValue: { valid in
                if valid {
                    print("Token exists and is valid")
                    self.isRedditAuthorized = true
                    self.isWaitingForRedditAuthToken = false
                } else {
                    print("Token exists but is invalid")
                    Reddit.refreshAccessToken(RedditAuthState.shared.accessToken.refreshToken)
                }
            }.store(in: &cancellables)

        // reddit auth callback
        NotificationCenter.default
            .publisher(for: .RDTWKSVerificationNotification)
            .sink { notification in
                self.isWaitingForRedditAuthToken = true
                self.isPresentingRedditAuthView = false
                guard let response = notification.userInfo?["response"] as? RedditAuthResponse else {
                    // TODO
                    return
                }
                if response.error || response.state == "" || response.state != UserDefaults.standard.string(forKey: "lastRandomCode") {
                    // TODO
                    return
                }
                Reddit.askForAccessToken(code: response.code)
                    .sink(receiveCompletion: { completion in
                        // TODO
                    }, receiveValue: { response in
                        let expires = Date().addingTimeInterval(Double(response.lifetime))
                        let token = Reddit.AccessToken(accessToken: response.accessToken, refreshToken: response.refreshToken, expires: expires)
                        if let data = try? JSONEncoder().encode(token) {
                            UserDefaults.standard.setValue(data, forKey: Reddit.ACCESS_TOKEN_KEY)
                        }
                        self.isWaitingForRedditAuthToken = false
                        self.isRedditAuthorized = true
                    }).store(in: &self.cancellables)
            }.store(in: &cancellables)

        // Safari extension checker
        Timer.publish(every: 1, tolerance: 1, on: .main, in: .common, options: nil)
            .autoconnect()
            .receive(on: RunLoop.main)
            .zip(
                Future { promise in
                    SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: EXTENSION_ID) { (state, error) in
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

    @EnvironmentObject var redditAuthState: RedditAuthState
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
                Text("There are a few things we have to do before you can get started.")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                  .foregroundColor(.white))

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
                        .foregroundColor(.white)
                )

                VStack {
                    HStack {
                        if onboardingEnvironment.isRedditAuthorized {
                            self.successIcon
                        } else {
                            Image("2.square")
                                .font(.system(size: 28, weight: .regular, design: .rounded))
                        }
                        Text("Sign in with Reddit")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Spacer()
                    }
                    Text("This step is optional. Allowing Redditweaks to access certain parts of the Reddit API, such as your comment history, make it easier and more accurate for us to tell you information like your comment karma.")
                    if onboardingEnvironment.isWaitingForRedditAuthToken {
                        if #available(macOS 10.16, *) {
                            ProgressView()
                        } else {
                            SpinnerView()
                        }
                    } else {
                        Button("Authorize via Reddit") {
                            onboardingEnvironment.isPresentingRedditAuthView = true
                        }.disabled(onboardingEnvironment.isRedditAuthorized)
                    }
                }.padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundColor(.white)
                )
            }
        }
        .frame(width: 300, height: 570)
        .padding()
        .sheet(isPresented: $onboardingEnvironment.isPresentingRedditAuthView) {
            RedditAuthView()
        }
    }

}

struct RedditAuthView: View {

    // https://stackoverflow.com/a/26845710
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let random = String((0 ..< length).map { _ in
            letters.randomElement()!
        })
        UserDefaults.standard.setValue(random, forKey: "lastRandomCode")
        return random
    }

    var body: some View {
        WebViewRepresentable(url: URL(string: "https://www.reddit.com/api/v1/authorize.compact?client_id=\(CLIENT_ID)&response_type=code&state=\(randomString(length: 16))&redirect_uri=rdtwks://verify&duration=permanent&scope=identity,edit,flair,history,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote")!)
            .frame(width: 500, height: 800)
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
