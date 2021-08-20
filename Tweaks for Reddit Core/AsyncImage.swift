//
//  AsyncImage.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/18/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import SwiftUI

public class AsyncImageLoader: ObservableObject {

    let publisher = PassthroughSubject<Image, Never>()

    private var cancellables = Set<AnyCancellable>()

    private var cache = [Int: Data]()

    func load(url: URL, fallbackSymbol: String) {
        let fm = FileManager.default
        let hash = url.absoluteString.hashValue
        guard let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        let sub = base.appendingPathComponent("Tweaks for Reddit")
        if !fm.fileExists(atPath: sub.path) {
            try? fm.createDirectory(at: sub, withIntermediateDirectories: true, attributes: nil)
        }
        let path = sub.appendingPathComponent("snoovatar.png").path

        Future<Data, Error> { [self] promise in
            if FileManager.default.fileExists(atPath: path) {
                if let data = FileManager.default.contents(atPath: path) {
                    return promise(.success(data))
                }
            }
            if let cachedData = self.cache[hash] {
                return promise(.success(cachedData))
            }
            URLSession.shared.downloadTask(with: url) { location, _, error in
                if let error = error {
                    return promise(.failure(error))
                }
                guard let location = location, let data = fm.contents(atPath: location.path) else {
                    return promise(.failure(OAuthError.internalError))
                }
                self.cache[hash] = data
                fm.createFile(atPath: path, contents: data, attributes: nil)
                return promise(.success(data))
            }.resume()
        }
        .compactMap(NSImage.init(data:))
        .map(Image.init(nsImage:))
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
                case .finished: break
                case .failure(_):
                    self.publisher.send(Image(systemName: "xmark"))
            }
        } receiveValue: {
            self.publisher.send($0)
        }
        .store(in: &cancellables)
    }

}

public struct AsyncImage: View {

    @StateObject private var imageLoader = AsyncImageLoader()

    @State private var image: Image?

    public let url: URL
    public let fallbackSymbol: String

    public init(url: URL, fallbackSymbol: String) {
        self.url = url
        self.fallbackSymbol = fallbackSymbol
    }

    public var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            imageLoader.load(url: url, fallbackSymbol: fallbackSymbol)
        }
        .onReceive(imageLoader.publisher) {
            self.image = $0
        }
    }
}

struct AsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImage(
            url: URL(string: "https://i.redd.it/snoovatar/snoovatars/2d193ec6-03ef-4a80-a651-637f7ed0dd93.png")!,
            fallbackSymbol: "xmark.octagon.fill"
        )
        .frame(width: 500, height: 500)
    }
}
