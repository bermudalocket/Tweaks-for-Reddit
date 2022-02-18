//
//  OAuthService.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/22/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import AppKit
import Combine
import TFRCompose
import Foundation
import KeychainAccess

public enum Endpoint: Equatable {
    case me
    case unreadMessages
    case hidden(user: String, after: String? = nil, before: String? = nil)
    case unhide(posts: [Post])

    public enum Method: String { case GET, POST }

    public var url: URL {
        switch self {
            case .me:
                return URL(string: "https://oauth.reddit.com/api/v1/me")!

            case .unreadMessages:
                return URL(string: "https://oauth.reddit.com/message/unread")!

            case .unhide(posts: _):
                return URL(string: "https://oauth.reddit.com/api/unhide")!

            case .hidden(user: let user, after: let after, before: let before):
                if let after = after {
                    return URL(string: "https://oauth.reddit.com/user/\(user)/hidden?limit=25&after=\(after)")!
                } else if let before = before {
                    return URL(string: "https://oauth.reddit.com/user/\(user)/hidden?limit=25&before=\(before)")!
                } else {
                    return URL(string: "https://oauth.reddit.com/user/\(user)/hidden?limit=25")!
                }
        }
    }

    public var postData: Data? {
        guard self.method == .POST else {
            return nil
        }
        switch self {
            case .unhide(let posts):
                var postIdString = ""
                if posts.count > 1 {
                    postIdString = posts.map(\.name).joined(separator: ",")
                } else if posts.count == 1, let post = posts.first {
                    postIdString = post.name
                }
                return "id=\(postIdString)".data(using: .utf8)

            default: return nil
        }
    }

    public var method: Method {
        switch self {
            case .unhide(posts: _):
                return .POST

            default:
                return .GET
        }
    }
}

public protocol RedditServiceProtocol {
    func begin(state: String)
    func exchangeCodeForTokens(code: String) -> AnyPublisher<Tokens, RedditError>
    func getUserData(tokens: Tokens) -> AnyPublisher<UserData, RedditError>
    func getMessages(tokens: Tokens) -> AnyPublisher<[UnreadMessage], RedditError>
    func getHiddenPosts(tokens: Tokens, username: String, after: Post?, before: Post?) -> AnyPublisher<[Post], RedditError>
    func unhide(tokens: Tokens, posts: [Post]) -> AnyPublisher<Bool, RedditError>
}

public struct RedditService: RedditServiceProtocol {

    public func begin(state: String) {
        var comps = URLComponents(string: "https://www.reddit.com/api/v1/authorize")!
        comps.queryItems = [
            URLQueryItem(name: "client_id", value: "CLhgpMcqOhskvA"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "redirect_uri", value: "rdtwks://oauth"),
            URLQueryItem(name: "duration", value: "permanent"),
            URLQueryItem(name: "scope", value: "identity edit flair history privatemessages read report save submit subscribe vote")
        ]
        if let url = comps.url {
            NSWorkspace.shared.open(url)
        }
    }

    public func exchangeCodeForTokens(code: String) -> AnyPublisher<Tokens, RedditError> {
        var request: URLRequest {
            var request = URLRequest(url: .accessToken)
            request.httpMethod = "POST"
            request.addValue("rdtwks", forHTTPHeaderField: "User-Agent")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("Basic " + "CLhgpMcqOhskvA:".data(using: .utf8)!.base64EncodedString(), forHTTPHeaderField: "Authorization")
            request.httpBody = "grant_type=authorization_code&code=\(code)&redirect_uri=rdtwks://oauth".data(using: .utf8)
            return request
        }
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let res = response as? HTTPURLResponse else {
                    throw RedditError.badResponse()
                }
                guard res.statusCode == 200 else {
                    throw RedditError.badResponse(code: res.statusCode)
                }
                return data
            }
            .decode(type: Tokens.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? RedditError {
                    return error
                }
                return RedditError.wrapping(message: "\(error)")
            }
            .eraseToAnyPublisher()
    }

    private func refresh(refreshToken: String) -> AnyPublisher<Tokens, RedditError> {
        let request: URLRequest = {
            var request = URLRequest(url: .refreshToken)
            request.httpMethod = "POST"
            request.addValue("rdtwks", forHTTPHeaderField: "User-Agent")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("Basic " + "CLhgpMcqOhskvA:".data(using: .utf8)!.base64EncodedString(), forHTTPHeaderField: "Authorization")
            request.httpBody = "grant_type=refresh_token&refresh_token=\(refreshToken)".data(using: .utf8)
            return request
        }()
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) throws -> Data in
                guard let res = response as? HTTPURLResponse, res.statusCode == 200 else {
                    throw RedditError.badResponse()
                }
                return data
            }
            .decode(type: Tokens.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let accessToken = response.accessToken, let refreshToken = response.refreshToken else {
                    throw RedditError.noToken
                }
                return Tokens(accessToken: accessToken, refreshToken: refreshToken)
            }
            .mapError { error in
                if let error = error as? RedditError {
                    return error
                }
                return RedditError.wrapping(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    public func getUserData(tokens: Tokens) -> AnyPublisher<UserData, RedditError> {
        request(tokens: tokens, endpoint: .me)
            .decode(type: UserData.self, decoder: JSONDecoder())
            .catch { error in
                AnyPublisher(error: RedditError.wrapping(message: "\(error)"))
            }
            .eraseToAnyPublisher()
    }

    /// Returns unread messages.
    ///
    /// - Parameter tokens: access and refresh token pair
    /// - Returns: a publisher
    public func getMessages(tokens: Tokens) -> AnyPublisher<[UnreadMessage], RedditError> {
        request(tokens: tokens, endpoint: .unreadMessages)
            .decode(type: Listing<UnreadMessage>.self, decoder: JSONDecoder())
            .map {
                $0.data.contents.map(\.data)
            }
            .catch { error in
                AnyPublisher(error: RedditError.wrapping(message: "\(error)"))
            }
            .eraseToAnyPublisher()
    }


    /// Returns the first 25 (or fewer) hidden posts.
    ///
    /// - Parameters:
    ///   - tokens: access and refresh token pair
    ///   - username: the username associated with the tokens
    ///   - after: (optional) starting point for pagination
    ///   - before: (optional) ending point for pagination
    /// - Returns: a publisher that will send the result
    public func getHiddenPosts(
        tokens: Tokens,
        username: String,
        after: Post? = nil,
        before: Post? = nil
    ) -> AnyPublisher<[Post], RedditError> {
        request(tokens: tokens, endpoint: .hidden(user: username, after: after?.name, before: before?.name))
            .decode(type: Listing<Post>.self, decoder: JSONDecoder())
            .map {
                $0.data.contents.map(\.data)
            }
            .catch { error in
                AnyPublisher(error: RedditError.wrapping(message: "\(error)"))
            }
            .eraseToAnyPublisher()
    }

    public func unhide(tokens: Tokens, posts: [Post]) -> AnyPublisher<Bool, RedditError> {
        request(tokens: tokens, endpoint: .unhide(posts: posts))
            .map { _ in true }
            .catch { _ in AnyPublisher(value: false) }
            .eraseToAnyPublisher()
    }

    private func request(tokens: Tokens, endpoint: Endpoint) -> AnyPublisher<Data, RedditError> {
        guard let accessToken = tokens.accessToken else {
            return AnyPublisher(error: RedditError.noToken)
        }
        let request: URLRequest = {
            var request = URLRequest(url: endpoint.url)
            request.httpMethod = endpoint.method.rawValue
            request.addValue("Tweaks for Reddit v1.13.0 (by u/thebermudalocket)", forHTTPHeaderField: "User-Agent")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = endpoint.postData
            return request
        }()
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let res = response as? HTTPURLResponse else {
                    throw RedditError.badResponse()
                }
                guard res.statusCode == 200 else {
                    if res.statusCode == 401 {
                        throw RedditError.unauthorized
                    }
                    throw RedditError.badResponse(code: res.statusCode)
                }
                return data
            }
            .tryCatch { (error) -> AnyPublisher<Data, RedditError> in
                if let error = error as? RedditError, error == .unauthorized, let refreshToken = tokens.refreshToken {
                    return self.refresh(refreshToken: refreshToken)
                        .map { newTokens in
                            self.request(tokens: newTokens, endpoint: endpoint)
                        }
                        .switchToLatest()
                        .eraseToAnyPublisher()
                    } else {
                    if let error = error as? RedditError {
                        return Fail(error: error).eraseToAnyPublisher()
                    } else {
                        return Fail(error: RedditError.wrapping(message: "\(error)")).eraseToAnyPublisher()
                    }
                }
            }
            .mapError { error in
                if let error = error as? RedditError {
                    return error
                }
                return RedditError.wrapping(message: "\(error)")
            }
            .eraseToAnyPublisher()
    }

}
