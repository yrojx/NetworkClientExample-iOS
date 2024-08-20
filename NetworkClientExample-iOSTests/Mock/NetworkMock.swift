//
//  NetworkMock.swift
//  NetworkClientExample-iOSTests
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (Data, URLResponse))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("handler not implemented")
        }
        
        do {
            let (data, response) = try handler(request)
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowedInMemoryOnly)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

final class MockURLCache: URLCache {
    var storedResponses: [URLRequest: CachedURLResponse] = [:]
    var isCacheUsed: Bool = false
    
    override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        if let storedResponse = storedResponses[request] {
            isCacheUsed = true
            return storedResponse
        }
        
        return nil
    }
    
    override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        storedResponses[request] = cachedResponse
    }
}

struct MockValidEndpoint: Endpoint {
    var host: String = "example.com"
    var path: String = "/"
    var method: HTTPMethod = .get
}

struct MockBadURLEndpoint: Endpoint {
    var host: String = "example.com"
    var path: String = "-"
    var method: HTTPMethod = .get
}

struct MockUnsupportedContentTypeEndpoint: Endpoint {
    var host: String = "example.com"
    var path: String = "/"
    var method: HTTPMethod = .get
    var header: [String : String]? = ["Content-Type": "application/xml"]
}

struct MockDecodable: Decodable {
    let key: String
}
