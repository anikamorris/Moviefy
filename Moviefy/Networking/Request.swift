//
//  Request.swift
//  Moviefy
//
//  Created by Anika Morris on 7/6/20.
//  Copyright © 2020 Adriana González Martínez. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public enum Route: String {
    case movies = "discover/movie"
    case token = "authentication/token/new"
    case session = "authentication/session/new"
    case account = "account"
}

struct Request {
    
    static let headers = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "\(Constants().authToken)"
    ]
    
    public static let baseImageURL = URL(string: "https://image.tmdb.org/t/p/w500")!
    
    static func configureRequest(from route: Route, with parameters: [String: Any], and method: HTTPMethod, contains body: Data?) throws -> URLRequest {

        guard let url = URL(string: "https://api.themoviedb.org/3/\(route.rawValue)") else { fatalError("Error while unwrapping url")}
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.httpMethod = method.rawValue
        request.httpBody = body
        try configureParametersAndHeaders(parameters: parameters, headers: headers, request: &request)
        print(request, request.allHTTPHeaderFields ?? "")
        return request
    }
    
    static func configureParametersAndHeaders(parameters: [String: Any]?,
                                                  headers: [String: String]?,
                                                  request: inout URLRequest) throws {
        do {
            if let headers = headers, let parameters = parameters {
                try Encoder.encodeParameters(for: &request, with: parameters)
                try Encoder.setHeaders(for: &request, with: headers)
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }
}
