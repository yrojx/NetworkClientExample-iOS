//
//  Endpoint.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

protocol Endpoint {
    // For URLComponents
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    
    // For URLRequest
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
    var method: HTTPMethod { get }
    var header: [String: String]? { get }
    
    var retries: Int { get }
}

extension Endpoint {
    var scheme: String {
        "https"
    }
    var queryItems: [URLQueryItem]? {
        nil
    }

    var cachePolicy: URLRequest.CachePolicy {
        .useProtocolCachePolicy
    }
    var timeoutInterval: TimeInterval {
        10
    }
    var header: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    var retries: Int {
        3
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
