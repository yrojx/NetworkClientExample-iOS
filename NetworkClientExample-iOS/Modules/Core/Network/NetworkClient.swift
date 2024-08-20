//
//  NetworkClient.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(target: Endpoint) async throws -> T
}

final class NetworkClient: NetworkClientProtocol {
    private let urlSession: URLSession
    
    init(urlSessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }
    
    func request<T: Decodable>(target: Endpoint) async throws -> T {
        let urlRequest = try createUrlRequest(target: target)
        let (data, urlResponse) = try await handleRequest(urlRequest: urlRequest, retries: target.retries)
        try handleStatusCode(response: urlResponse)
        let decodedData: T = try decode(data: data, contentType: urlResponse.mimeType)
        
        return decodedData
    }
    
    private func createUrlRequest(target: Endpoint) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = target.scheme
        components.host = target.host
        components.path = target.path
        components.queryItems = target.queryItems
        
        guard let url = components.url else {
            throw NetworkError.badURL
        }
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: target.cachePolicy,
            timeoutInterval: target.timeoutInterval
        )
        urlRequest.httpMethod = target.method.rawValue
        urlRequest.allHTTPHeaderFields = target.header
        return urlRequest
    }
    
    private func handleRequest(urlRequest: URLRequest, retries: Int = 3) async throws -> (Data, URLResponse) {
        var attempts = 0
        
        while attempts < retries {
            do {
                return try await urlSession.data(for: urlRequest)
            } catch {
                attempts += 1
                if attempts >= retries {
                    throw NetworkError.requestFailed(error)
                }
                
                try await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
        
        // Should never reach here because of the loop, but required by compiler
        throw NetworkError.requestFailed(NSError(domain: "", code: 0))
    }
    
    private func handleStatusCode(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 404:
            throw NetworkError.notFound
        case 500:
            throw NetworkError.internalServerError
        default:
            throw NetworkError.unknownError(statusCode: httpResponse.statusCode)
        }
    }

    private func decode<T: Decodable>(data: Data, contentType: String?) throws -> T {
        guard let safeContentType = contentType, safeContentType.contains("application/json") else {
            throw NetworkError.unsupportedContentType
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch let decodingError {
            throw NetworkError.decodingFailed(decodingError)
        }
    }
}
