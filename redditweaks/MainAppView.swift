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

let APP_ID = "com.bermudalocket.redditweaks"
let EXTENSION_ID = "com.bermudalocket.redditweaks-Extension"
let CLIENT_ID = "H6S3-yPygNPNfA"

extension Notification.Name {
    public static let RDTWKSVerificationNotification = Notification.Name("redditweaks.verify")
}

struct RedditTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
    let refresh_token: String
}

class OnboardingEnvironment: ObservableObject {

    @Published var isSafariExtensionEnabled = false
    @Published var isPresentingRedditAuthView = false
    @Published var isRedditAuthorized = false
    @Published var isWaitingForRedditAuthToken = false

    @Published var checkForExtensionTimer: AnyCancellable?
    @Published var isRedditAuthorizedListener: AnyCancellable?

    private var cancellables = [AnyCancellable]()

    init() {
        NotificationCenter.default
            .publisher(for: .RDTWKSVerificationNotification)
            .sink { notification in
                guard let response = notification.userInfo?["response"] as? RedditAuthResponse else {
                    return
                }
                if response.error || response.state == "" || response.state != UserDefaults.standard.string(forKey: "lastRandomCode") {
                    // handle bad state
                    return
                }
                let login = "\(CLIENT_ID):"
                    .data(using: .utf8)!
                    .base64EncodedString()
                print(login)
                var request = URLRequest(url: URL(string: "https://www.reddit.com/api/v1/access_token")!)
                let data = "grant_type=authorization_code&code=\(response.code)&redirect_uri=rdtwks://token".data(using: .utf8)
                request.httpMethod = "POST"
                request.setValue("Basic \(login)", forHTTPHeaderField: "Authorization")
                request.setValue("redditweaks", forHTTPHeaderField: "User-Agent")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = data
                print(String(data: data!, encoding: .utf8)!)
                URLSession.shared.dataTaskPublisher(for: request)
                    .compactMap { (data, response) in
                        guard let resp = response as? HTTPURLResponse, resp.statusCode == 200 else {
                            return nil
                        }
                        print(String(data: data, encoding: .utf8)!)
                        return data
                    }.decode(type: RedditTokenResponse.self, decoder: JSONDecoder())
                    .sink(receiveCompletion: { completion in
                        print(completion)
                    }, receiveValue: { response in
                        print(response)
                    }).store(in: &self.cancellables)

                self.isWaitingForRedditAuthToken = true
                self.isPresentingRedditAuthView = false
            }.store(in: &cancellables)
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

    @EnvironmentObject var onboardingEnvironment: OnboardingEnvironment

    var successIcon: some View {
        Image("checkmark.square.fill")
            .foregroundColor(.green)
            .font(.system(size: 28, weight: .regular, design: .rounded))
    }

    private var checkForExtensionTimer: AnyCancellable?

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
                    Button("Authorize via Reddit") {
                        onboardingEnvironment.isPresentingRedditAuthView = true
                    }.disabled(onboardingEnvironment.isRedditAuthorized)
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
        WebViewRepresentable(url: URL(string: "https://www.reddit.com/api/v1/authorize.compact?client_id=\(CLIENT_ID)&response_type=code&state=\(randomString(length: 16))&redirect_uri=rdtwks://verify&duration=temporary&scope=identity,edit,flair,history,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote")!)
            .frame(width: 500, height: 800)
    }
}

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

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
