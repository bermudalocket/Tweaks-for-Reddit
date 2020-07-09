//
//  API.swift
//  redditweaks
//  5.0
//  10.16
//
//  Created by bermudalocket on 6/28/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class Reddit {

    private static let CLIENT_ID = "H6S3-yPygNPNfA"

    private static let basicAuth = "\(CLIENT_ID):".data(using: .utf8)!.base64EncodedString()

    static let ACCESS_TOKEN_KEY = "reddit_access_token"
    static let REFRESH_TOKEN_KEY = "reddit_refresh_token"

    struct AccessToken: Codable, Equatable {
        let accessToken: String
        let refreshToken: String
        let expires: Date

        static let empty = AccessToken(accessToken: "", refreshToken: "", expires: .distantPast)
    }

    enum EndpointPostBody {
        case accessToken(code: String)
        case refreshToken(refreshToken: String)
        case none

        var body: String {
            switch self {
                case .accessToken(let code):
                    return "grant_type=authorization_code&code=\(code)&redirect_uri=rdtwks://verify"
                case .refreshToken(let token):
                    return "grant_type=refresh_token&refresh_token=\(token)"
                default:
                    return ""
            }
        }
    }

    struct Endpoint {
        let url: String
        let httpMethod: HTTPMethod
        let postBody: EndpointPostBody?

        static func accessTokenEndpointForCode(_ code: String) -> Endpoint {
            Endpoint(url: "/access_token", httpMethod: .post, postBody: .accessToken(code: code))
        }

        static func refreshTokenEndpointForRefreshToken(_ refreshToken: String) -> Endpoint {
            Endpoint(url: "/access_token", httpMethod: .post, postBody: .refreshToken(refreshToken: refreshToken))
        }

        static let karma = Endpoint(url: "/me/karma", httpMethod: .get, postBody: nil)
    }

    enum APIError: Error {
        case needsInitialSetup
        case genericNetworkError
        case decodingError
        case basicAuthError
        case tokenExpired
    }

    static var cancelBag = [AnyCancellable]()

    static var mostRecentToken: AccessToken {
        guard let data = UserDefaults.standard.data(forKey: ACCESS_TOKEN_KEY),
              let token = try? JSONDecoder().decode(AccessToken.self, from: data) else {
            return .empty
        }
        return token
    }

    struct RedditKarmaResponse: Codable {
        let kind: String
        let data: [RedditKarmaInfo]
    }

    struct RedditKarmaInfo: Codable {
        let sr: String
        let comment_karma: Int
        let link_karma: Int
    }

    public class func countKarma() -> AnyPublisher<[RedditKarmaInfo], Error> {
        URLSession.shared
            .dataTaskPublisher(for: urlRequestBuilder(endpoint: .karma))
            .tryMap(verifyNetworkResponse(_:))
            .decode(type: RedditKarmaResponse.self, decoder: JSONDecoder())
            .map { $0.data }
            .eraseToAnyPublisher()
    }

    class func refreshAccessToken(_ refreshToken: String) {
        URLSession.shared
            .dataTaskPublisher(for: urlRequestBuilder(endpoint: Endpoint.refreshTokenEndpointForRefreshToken(refreshToken)))
            .receive(on: RunLoop.main)
            .tryMap(verifyNetworkResponse(_:))
            .decode(type: RedditRefreshTokenResponse.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                    case .finished: print("Finished")
                    case .failure(let error): print("Error: \(error)")
                }
            } receiveValue: { response in
                let expires = Date().addingTimeInterval(Double(response.lifetime))
                let token = AccessToken(accessToken: response.accessToken, refreshToken: refreshToken, expires: expires)
                if let data = try? JSONEncoder().encode(token) {
                    UserDefaults.standard.setValue(data, forKey: ACCESS_TOKEN_KEY)
                }
                print("Successfully refreshed token")
                print("New expiry: \(token.expires)")
            }.store(in: &cancelBag)
    }

    private class func urlRequestBuilder(endpoint: Endpoint) -> URLRequest {
        let subdomain = endpoint.httpMethod == .get ? "oauth" : "www"
        var request = URLRequest(url: URL(string: "https://\(subdomain).reddit.com/api/v1\(endpoint.url)")!)
        request.httpMethod = endpoint.httpMethod.rawValue
        request.setValue("redditweaks", forHTTPHeaderField: "User-Agent")
        if endpoint.httpMethod == .post {
            request.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("bearer \(RedditAuthState.shared.accessToken.accessToken)", forHTTPHeaderField: "Authorization")
        }
        if let body = endpoint.postBody {
            request.httpBody = body.body.data(using: .utf8)!
            print(String(data: body.body.data(using: .utf8)!, encoding: .utf8)!)
        }
        return request
    }

    private class func verifyNetworkResponse(_ dataResponse: (Data, URLResponse)) throws -> Data {
        let data = dataResponse.0
        let urlResponse = dataResponse.1
        guard let response = urlResponse as? HTTPURLResponse else {
            throw APIError.genericNetworkError
        }
        print(data.prettyPrintedJSONString ?? "no data to print")
        switch response.statusCode {
            case 200: break // ok
            case 401: throw APIError.tokenExpired // unauthorized
            default: break
        }
        return data
    }

    class func askForAccessToken(code: String) -> AnyPublisher<RedditTokenResponse, Error> {
        URLSession.shared
            .dataTaskPublisher(for: urlRequestBuilder(endpoint: .accessTokenEndpointForCode(code)))
            .receive(on: RunLoop.main)
            .tryMap { (data, response) in
                guard let resp = response as? HTTPURLResponse else {
                    throw APIError.genericNetworkError
                }
                if resp.statusCode == 401 {
                    throw APIError.basicAuthError
                }
                //print(data.prettyPrintedJSONString ?? "no data")
                return data
            }
            .decode(type: RedditTokenResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    class func checkIfTokenIsValid(token: AccessToken) -> Future<Bool, Error> {
        Future { promise in
            URLSession.shared
                .dataTaskPublisher(for: urlRequestBuilder(endpoint: .karma))
                .tryMap(verifyNetworkResponse(_:))
                .sink { completion in
                    switch completion {
                        case .finished:
                            return promise(.success(true))
                        case .failure(let error):
                            return promise(.failure(error))
                    }
                } receiveValue: { _ in }
                .store(in: &cancelBag)
        }
    }

}
