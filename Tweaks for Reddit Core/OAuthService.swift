//
//  OAuthService.swift
//  Tweaks for Reddit Core
//
//  Created by Michael Rippe on 6/22/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import AppKit
import Combine
import Foundation

extension AnyPublisher {
    public init(value: Output) {
        self.init(Just(value).setFailureType(to: Failure.self))
    }

    public static var none: AnyPublisher<Output, Failure> {
        Empty(completeImmediately: true)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
}

/// A client that communicates with the Reddit OAuth-based API.
public protocol OAuthClient {
    func begin(state: String) -> AnyPublisher<Never, Never>
    func exchangeCodeForTokens(code: String) -> AnyPublisher<Tokens, OAuthError>
    func refresh(refreshToken: String) -> AnyPublisher<Tokens, OAuthError>
    func request(tokens: Tokens, endpoint: Endpoint, isRetry: Bool) -> AnyPublisher<Data, OAuthError>
}

class OAuthClientMock: OAuthClient {

    func begin(state: String) -> AnyPublisher<Never, Never> {
        Empty(completeImmediately: true, outputType: Never.self, failureType: Never.self).eraseToAnyPublisher()
    }

    func exchangeCodeForTokens(code: String) -> AnyPublisher<Tokens, OAuthError> {
        Just(Tokens(accessToken: "mocked", refreshToken: "mocked"))
            .setFailureType(to: OAuthError.self)
            .eraseToAnyPublisher()
    }

    func refresh(refreshToken: String) -> AnyPublisher<Tokens, OAuthError> {
        Just(Tokens(accessToken: "mocked2", refreshToken: "mocked2"))
            .setFailureType(to: OAuthError.self)
            .eraseToAnyPublisher()
    }

    func request(tokens: Tokens, endpoint: Endpoint, isRetry: Bool = false) -> AnyPublisher<Data, OAuthError> {
        switch endpoint {
            default:
                return Just("".data(using: .utf8)!)
                    .setFailureType(to: OAuthError.self)
                    .eraseToAnyPublisher()
        }
    }

}

class OAuthClientLive: OAuthClient {

    func begin(state: String) -> AnyPublisher<Never, Never> {
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
        return .none
    }

    func exchangeCodeForTokens(code: String) -> AnyPublisher<Tokens, OAuthError> {
        let request: URLRequest = {
            var request = URLRequest(url: .accessToken)
            request.httpMethod = "POST"
            request.addValue("rdtwks", forHTTPHeaderField: "User-Agent")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("Basic " + "CLhgpMcqOhskvA:".data(using: .utf8)!.base64EncodedString(), forHTTPHeaderField: "Authorization")
            request.httpBody = "grant_type=authorization_code&code=\(code)&redirect_uri=rdtwks://oauth".data(using: .utf8)
            return request
        }()
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let res = response as? HTTPURLResponse else {
                    throw OAuthError.badResponse()
                }
                guard res.statusCode == 200 else {
                    throw OAuthError.badResponse(code: res.statusCode)
                }
                return data
            }
            .decode(type: Tokens.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? OAuthError {
                    return error
                }
                return OAuthError.wrapping(message: "\(error)")
            }
            .eraseToAnyPublisher()
    }

    func refresh(refreshToken: String) -> AnyPublisher<Tokens, OAuthError> {
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
                guard let res = response as? HTTPURLResponse else {
                    throw OAuthError.badResponse()
                }
                switch res.statusCode {
                    case 200: break
                    case 401: throw OAuthError.unauthorized
                    case 403: throw OAuthError.forbidden(token: refreshToken)
                    default: break
                }
                return data
            }
            .decode(type: OAuthResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let accessToken = response.accessToken, let refreshToken = response.refreshToken else {
                    throw OAuthError.noToken
                }
                return Tokens(accessToken: accessToken, refreshToken: refreshToken)
            }
            .mapError { error in
                if let error = error as? OAuthError {
                    return error
                }
                return OAuthError.wrapping(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func request(tokens: Tokens, endpoint: Endpoint, isRetry: Bool = false) -> AnyPublisher<Data, OAuthError> {
        guard let accessToken = tokens.accessToken else {
            return Fail(error: OAuthError.noToken).eraseToAnyPublisher()
        }
        let request: URLRequest = {
            var request = URLRequest(url: endpoint.url)
            request.httpMethod = endpoint.method
            request.addValue("Tweaks for Reddit v1.13.0 (by /u/thebermudalocket)", forHTTPHeaderField: "User-Agent")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            return request
        }()
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let res = response as? HTTPURLResponse else {
                    throw OAuthError.badResponse()
                }
                switch res.statusCode {
                    case 401: throw OAuthError.unauthorized
                    case 403: throw OAuthError.forbidden(token: accessToken)
                    default: break
                }
                return data
            }
            .tryCatch { (error) -> AnyPublisher<Data, OAuthError> in
                if let error = error as? OAuthError, error == .unauthorized, let refreshToken = tokens.refreshToken {
                    return self.refresh(refreshToken: refreshToken)
                        .map { newTokens in
                            self.request(tokens: newTokens, endpoint: endpoint, isRetry: true)
                        }
                        .switchToLatest()
                        .eraseToAnyPublisher()
                    } else {
                    if let error = error as? OAuthError {
                        return Fail(error: error).eraseToAnyPublisher()
                    } else {
                        return Fail(error: OAuthError.wrapping(message: "\(error)")).eraseToAnyPublisher()
                    }
                }
            }
            .mapError { error in
                if let error = error as? OAuthError {
                    return error
                }
                return OAuthError.wrapping(message: "\(error)")
            }
            .eraseToAnyPublisher()
    }

}
